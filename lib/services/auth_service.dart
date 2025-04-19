import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    String role,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Add user to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'email': email,
        'registrationDatetime': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } catch (e) {
      print('Error registering: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();
        return userData.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(
    String firstName,
    String lastName, {
    String? dob,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> updateData = {
          'firstName': firstName,
          'lastName': lastName,
        };

        if (dob != null) {
          updateData['dob'] = dob;
        }

        await _firestore.collection('users').doc(user.uid).update(updateData);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Update user email
  Future<bool> updateEmail(String newEmail, String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate user first
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updateEmail(newEmail);

        // Update email in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'email': newEmail,
        });

        return true;
      }
      return false;
    } catch (e) {
      print('Error updating email: $e');
      return false;
    }
  }

  // Update user password
  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate user first
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);

        return true;
      }
      return false;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }
}
