import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn;
  
  // Optional: Pass clientId if not using meta tag in web/index.html
  // For web, it's recommended to use the meta tag approach instead
  AuthService({String? clientId})
      : _googleSignIn = GoogleSignIn(
          clientId: clientId,
        );

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<bool> setPassword(String password) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        debugPrint('No user is currently signed in');
        return false;
      }

      final email = user.email;
      if (email == null) {
        debugPrint('User email is null');
        return false;
      }

      // Check if user already has email/password provider
      final hasEmailPassword = user.providerData
          .any((provider) => provider.providerId == 'password');

      if (!hasEmailPassword) {
        // For Google-only users, linking email/password provider requires server-side handling
        // Firebase doesn't support directly adding a password to a Google-authenticated account
        // on the client side. The proper solution requires a Cloud Function.
        //
        // Workaround attempt: Try updatePassword (will likely fail but provides better error)
        try {
          await user.updatePassword(password);
          return true;
        } on FirebaseAuthException catch (e) {
          debugPrint('Cannot set password for Google-only user: ${e.code} - ${e.message}');
          // Error codes that indicate password provider is missing:
          // - 'requires-recent-login': User needs to re-authenticate
          // - Other errors: Provider doesn't exist
          return false;
        } catch (e) {
          debugPrint('Error setting password for Google user: $e');
          return false;
        }
      } else {
        // User already has email/password, just update password
        await user.updatePassword(password);
        return true;
      }
    } catch (e) {
      debugPrint('Error in setPassword: $e');
      return false;
    }
  }
}
