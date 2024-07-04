// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password, String fullName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // Update the user's display name
      if (user != null) {
        await user.updateDisplayName(fullName);
        // Reload the user to get the updated information
        await user.reload();
        user = _auth.currentUser;
      }

      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Sign out from Google
      await FacebookAuth.instance.logOut(); // Sign out from Facebook
      await _auth.signOut(); // Sign out from Firebase
    } catch (e) {
      print(e.toString());
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Sign out to allow account selection
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // if user cancels the sign-in
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithFacebook() async {
    // try {
    //   await FacebookAuth.instance.logOut(); // Log out to allow account selection
    //   final LoginResult result = await FacebookAuth.instance.login();
    //   if (result.status != LoginStatus.success) return null;
    //   final AuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.accessToken);
    //   UserCredential userCredential = await _auth.signInWithCredential(credential);
    //   return userCredential.user;
    // } catch (e) {
    //   print(e.toString());
      return null;
    }

}