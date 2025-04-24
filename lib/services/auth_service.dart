import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '999995251444-fe88acrpll30l1mccsgtern7e9ln0kla.apps.googleusercontent.com' : null,
    scopes: [
      'email',
      'profile',
    ],
  );

  // Check if user is already signed in
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Email/Password Sign-In successful: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      print('Email/Password Sign-In Error: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Email/Password Sign-Up successful: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      print('Email/Password Sign-Up Error: $e');
      rethrow;
    }
  }

  // Check redirect result without starting new sign-in
  Future<User?> checkRedirectResult() async {
    if (kIsWeb) {
      try {
        // Get redirect result
        final userCredential = await _auth.getRedirectResult();
        print('Checking redirect result...');
        
        if (userCredential.user != null) {
          print('Redirect sign-in successful: ${userCredential.user?.email}');
          return userCredential.user;
        } else {
          print('No redirect result found');
          return null;
        }
      } catch (e) {
        print('Error checking redirect result: $e');
        return null;
      }
    }
    return null;
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web implementation using popup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        print('Starting web Google Sign-In with popup...');
        final userCredential = await _auth.signInWithPopup(googleProvider);
        
        if (userCredential.user != null) {
          print('Web Google Sign-In successful: ${userCredential.user?.email}');
          return userCredential.user;
        }
        return null;
      } else {
        // Mobile implementation
        print('Starting mobile Google Sign-In...');
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          print('Google Sign-In was cancelled by user');
          return null;
        }

        print('Google user obtained: ${googleUser.email}');
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        print('Google authentication successful');
        
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print('Signing in with Firebase...');
        final userCredential = await _auth.signInWithCredential(credential);
        print('Firebase Sign-In successful: ${userCredential.user?.email}');
        return userCredential.user;
      }
    } catch (e, stackTrace) {
      print('Google Sign-In Error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      if (kIsWeb) {
        await _auth.signOut();
      } else {
        await _googleSignIn.signOut();
        await _auth.signOut();
      }
      print('User signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
}
