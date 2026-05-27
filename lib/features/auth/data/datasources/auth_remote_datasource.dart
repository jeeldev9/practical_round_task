import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes mapped to UserModel
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
          (User? user) => user != null ? UserModel.fromFirebaseUser(user) : null,
        );
  }

  // Sign in with Email and Password
  Future<UserModel> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw 'Failed to sign in. User is null.';
      }

      // Check and fetch user record from Firestore
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      final UserModel userModel;
      if (userDoc.exists) {
        userModel = UserModel.fromFirestore(userDoc);
      } else {
        userModel = UserModel.fromFirebaseUser(firebaseUser);
        // Create the user document if it somehow doesn't exist in Firestore yet
        await _firestore.collection('users').doc(firebaseUser.uid).set(
              userModel.toFirestore(),
            );
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
          throw 'No account found with this email';
        case 'wrong-password':
          throw 'Incorrect password';
        case 'too-many-requests':
          throw 'Too many attempts. Try again later';
        case 'user-disabled':
          throw 'This account has been disabled';
        default:
          throw e.message ?? 'An unknown authentication error occurred';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Register with Email, Password, and Display Name
  Future<UserModel> registerWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw 'Failed to create user account. User is null.';
      }

      // Update user display name in Firebase Auth
      await firebaseUser.updateDisplayName(name);
      await firebaseUser.reload();

      final User? updatedUser = _firebaseAuth.currentUser;
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: email,
        displayName: name,
        photoUrl: updatedUser?.photoURL,
        fcmToken: null,
        createdAt: DateTime.now(),
      );

      // Create document in Firestore users/{uid}
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'email': email,
        'displayName': name,
        'photoUrl': userModel.photoUrl,
        'fcmToken': userModel.fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userModel;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'An account already exists with this email';
        case 'weak-password':
          throw 'Password is too weak';
        case 'invalid-email':
          throw 'Invalid email address';
        default:
          throw e.message ?? 'An error occurred during registration';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Send password reset link
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No account found with this email';
        default:
          throw e.message ?? 'An error occurred while trying to send the reset link';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign out from Firebase
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw e.toString();
    }
  }

  // Fetch current user from Firebase & Firestore
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final DocumentSnapshot doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      return UserModel.fromFirebaseUser(firebaseUser);
    } catch (e) {
      // Return null or throw depending on how offline sync is configured
      return null;
    }
  }
}
