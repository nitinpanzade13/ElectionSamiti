class VoterModel {
  final String voterId;
  final String fullName;
  final String constituency;
  final int wardNumber;
  final int boothNumber;
  final String partNumber;

  VoterModel({
    required this.voterId,
    required this.fullName,
    required this.constituency,
    required this.wardNumber,
    required this.boothNumber,
    required this.partNumber,
  });

  factory VoterModel.fromMap(Map<String, dynamic> map, String documentId) {
    return VoterModel(
      voterId: documentId, // The Firestore Document ID is the Voter ID
      fullName: map['fullName'] ?? 'Unknown Name',
      constituency: map['constituency'] ?? 'Unknown',
      wardNumber: map['wardNumber'] ?? 0,
      boothNumber: map['boothNumber'] ?? 0,
      partNumber: map['partNumber'] ?? 'N/A',
    );
  }
}
