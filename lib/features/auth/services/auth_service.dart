import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login with email and password
  /// Returns the authenticated User if successful, null otherwise
  Future<User?> login(String email, String password) async {
    try {
      print("🔐 Attempting login for: $email");
      
      // Authenticate with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        print("✅ Firebase Auth successful for UID: ${userCredential.user!.uid}");
        return userCredential.user;
      }
      
      print("❌ Login failed: No user returned");
      return null;
    } on FirebaseAuthException catch (e) {
      print("❌ Auth Error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("❌ Unexpected Error: $e");
      return null;
    }
  }

  /// Get current logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user exists in a specific collection
  Future<bool> userExistsInCollection(String uid, String collection) async {
    try {
      final doc = await _firestore.collection(collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      print("Error checking collection $collection: $e");
      return false;
    }
  }

  /// Log out
  Future<void> logout() async {
    await _auth.signOut();
    print("👋 User logged out");
  }
}
