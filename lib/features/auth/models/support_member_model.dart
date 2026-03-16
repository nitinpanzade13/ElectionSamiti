import 'package:cloud_firestore/cloud_firestore.dart';

class SupportMemberModel {
  final String uid;
  final String name;
  final String email;
  final String state;
  final String district;
  final String taluka;
  final String village;
  final String party;
  final int wardNumber;
  final String activationKey;
  final String linkedPartyMemberUid;
  final DateTime createdAt;

  SupportMemberModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.state,
    required this.district,
    required this.taluka,
    required this.village,
    required this.party,
    required this.wardNumber,
    required this.activationKey,
    required this.linkedPartyMemberUid,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory SupportMemberModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SupportMemberModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      state: map['state'] ?? '',
      district: map['district'] ?? '',
      taluka: map['taluka'] ?? '',
      village: map['village'] ?? '',
      party: map['party'] ?? '',
      wardNumber: map['wardNumber'] ?? 0,
      activationKey: map['activationKey'] ?? '',
      linkedPartyMemberUid: map['linkedPartyMemberUid'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'state': state,
      'district': district,
      'taluka': taluka,
      'village': village,
      'party': party,
      'wardNumber': wardNumber,
      'activationKey': activationKey,
      'linkedPartyMemberUid': linkedPartyMemberUid,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
