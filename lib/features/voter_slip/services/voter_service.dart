import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/voter_model.dart';

class VoterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<VoterModel?> getVoterById(String voterId) async {
    try {
      // Because the Document ID is the Voter ID, this is an O(1) direct read.
      // It is the fastest possible way to get data out of Firestore.
      DocumentSnapshot doc = await _firestore
          .collection('voters')
          .doc(voterId)
          .get();

      if (doc.exists) {
        return VoterModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print("Error fetching voter: $e");
    }
    return null; // Returns null if the voter ID doesn't exist
  }
}
