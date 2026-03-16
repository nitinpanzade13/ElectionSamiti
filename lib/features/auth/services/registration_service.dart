import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/party_member_model.dart';
import '../models/support_member_model.dart';

/// Handles all registration logic for Party Members and Support Members.
///
/// Firebase Collections Structure:
/// ┌─ partyMembers/{uid}         → Party member profiles + activation keys
/// ├─ supportMembers/{uid}       → Support member profiles linked to party members
/// ├─ admins/{uid}               → Admin accounts
/// └─ voterLists/
///    └─ {state}_{district}_{village}/
///       └─ wards/
///          └─ ward_{number}/
///             └─ voters/{voterId}  → Individual voter records
class RegistrationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ═══════════════════════════════════════════
  // Collection References
  // ═══════════════════════════════════════════
  CollectionReference get _partyMembersCol =>
      _firestore.collection('partyMembers');

  CollectionReference get _supportMembersCol =>
      _firestore.collection('supportMembers');

  CollectionReference get _adminsCol => _firestore.collection('admins');

  /// Generate a unique 8-character activation key
  String _generateActivationKey() {
    return _uuid.v4().replaceAll('-', '').substring(0, 8).toUpperCase();
  }

  // ═══════════════════════════════════════════
  // Party Member Registration
  // ═══════════════════════════════════════════

  /// Register a Party Member (main candidate).
  /// Returns the activation key on success, null on failure.
  Future<String?> registerPartyMember({
    required String name,
    required String email,
    required String password,
    required String state,
    required String district,
    required String taluka,
    required String village,
    required String party,
    required int wardNumber,
  }) async {
    try {
      // 1. Create Firebase Auth account
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) return null;

      // 2. Generate unique activation key
      String activationKey = _generateActivationKey();

      // 3. Ensure the key is unique
      bool keyExists = true;
      while (keyExists) {
        final query = await _partyMembersCol
            .where('activationKey', isEqualTo: activationKey)
            .get();
        if (query.docs.isEmpty) {
          keyExists = false;
        } else {
          activationKey = _generateActivationKey();
        }
      }

      // 4. Create the model
      final partyMember = PartyMemberModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        state: state,
        district: district,
        taluka: taluka,
        village: village,
        party: party,
        wardNumber: wardNumber,
        activationKey: activationKey,
        createdAt: DateTime.now(),
      );

      // 5. Save to Firestore → partyMembers/{uid}
      await _partyMembersCol
          .doc(userCredential.user!.uid)
          .set(partyMember.toMap());

      print("✅ Party member registered successfully");
      print("📧 Email: $email");
      print("🔑 Activation Key: $activationKey");
      print("👤 UID: ${userCredential.user!.uid}");

      // 6. Sign out — party member does NOT login, only registers
      await _auth.signOut();

      return activationKey;
    } on FirebaseAuthException catch (e) {
      print("Registration Error: ${e.message}");
      return null;
    } catch (e) {
      print("Registration Error: $e");
      return null;
    }
  }

  // ═══════════════════════════════════════════
  // Activation Key Validation
  // ═══════════════════════════════════════════

  /// Validate an activation key and return the linked party member data
  Future<PartyMemberModel?> validateActivationKey(String key) async {
    try {
      final trimmedKey = key.toUpperCase().trim();
      print("🔍 Validating activation key: '$trimmedKey'");
      
      final query = await _partyMembersCol
          .where('activationKey', isEqualTo: trimmedKey)
          .get();

      print("📊 Query returned ${query.docs.length} documents");
      
      if (query.docs.isEmpty) {
        print("❌ No party member found with activation key: '$trimmedKey'");
        return null;
      }

      final doc = query.docs.first;
      print("✅ Found party member: ${doc.data()}");
      return PartyMemberModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print("❌ Validation Error: $e");
      return null;
    }
  }

  // ═══════════════════════════════════════════
  // Support Member Registration
  // ═══════════════════════════════════════════

  /// Register a Support Member using an activation key.
  /// Returns true on success, false on failure.
  Future<bool> registerSupportMember({
    required String name,
    required String email,
    required String password,
    required String activationKey,
    required PartyMemberModel linkedPartyMember,
  }) async {
    try {
      // 1. Create Firebase Auth account
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) return false;

      // 2. Create the model using party member's location data
      final supportMember = SupportMemberModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        state: linkedPartyMember.state,
        district: linkedPartyMember.district,
        taluka: linkedPartyMember.taluka,
        village: linkedPartyMember.village,
        party: linkedPartyMember.party,
        wardNumber: linkedPartyMember.wardNumber,
        activationKey: activationKey.toUpperCase().trim(),
        linkedPartyMemberUid: linkedPartyMember.uid,
        createdAt: DateTime.now(),
      );

      // 3. Save to Firestore → supportMembers/{uid}
      await _supportMembersCol
          .doc(userCredential.user!.uid)
          .set(supportMember.toMap());

      // 4. Sign out — support member will login separately
      await _auth.signOut();

      return true;
    } on FirebaseAuthException catch (e) {
      print("Support Registration Error: ${e.message}");
      return false;
    } catch (e) {
      print("Support Registration Error: $e");
      return false;
    }
  }

  // ═══════════════════════════════════════════
  // Role Detection (for Login routing)
  // ═══════════════════════════════════════════

  /// Determine the role of a logged-in user.
  /// Returns 'admin', 'supportMember', or 'unknown'.
  Future<String> getUserRole(String uid) async {
    // Check admins collection first
    final adminDoc = await _adminsCol.doc(uid).get();
    if (adminDoc.exists) return 'admin';

    // Check support members
    final supportDoc = await _supportMembersCol.doc(uid).get();
    if (supportDoc.exists) return 'supportMember';

    // Check party members (they shouldn't login, but just in case)
    final partyDoc = await _partyMembersCol.doc(uid).get();
    if (partyDoc.exists) return 'partyMember';

    return 'unknown';
  }
}
