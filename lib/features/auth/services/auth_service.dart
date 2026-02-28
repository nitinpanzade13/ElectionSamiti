import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Log In Function
  // We are using Email/Password here because it's the easiest for an Admin to generate and hand to a worker.
  Future<WorkerModel?> login(String email, String password) async {
    try {
      // Step A: Authenticate with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step B: Fetch their specific Role and Ward data from Firestore
      if (userCredential.user != null) {
        return await getWorkerDetails(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      // Here you can handle specific errors like 'user-not-found' or 'wrong-password'
      print("Auth Error: ${e.message}");
      return null;
    }
    return null;
  }

  // 2. Fetch Worker Data Function
  Future<WorkerModel?> getWorkerDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('workers')
          .doc(uid)
          .get();

      if (doc.exists) {
        // We use the model you built earlier to convert the database JSON into a Dart Object!
        return WorkerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print("Firestore Error: $e");
    }
    return null;
  }

  // 3. Log Out Function
  Future<void> logout() async {
    await _auth.signOut();
  }
}
