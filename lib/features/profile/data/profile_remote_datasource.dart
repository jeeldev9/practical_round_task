import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Updates display name in Firebase Auth and Cloud Firestore
  Future<void> updateDisplayName(String displayName) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in';
      }

      // 1. Update Firebase Auth display name
      await user.updateDisplayName(displayName);
      await user.reload();

      // 2. Update Firestore users collection document
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayName,
      });
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred while updating profile in Firebase';
    } catch (e) {
      throw e.toString();
    }
  }
}
