import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:social_sphere/domain/interfaces/auth_repository_interfaces.dart';
import '../../../domain/models/user_model.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  // Get the current authenticated user
  // This method returns the current user if authenticated, otherwise null.
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebase(user);
  }

  @override
  // Stream of authentication state changes
  // This stream emits the current user whenever the authentication state changes.
  // It maps the Firebase User to our custom UserModel.
  // If the user is null, it means the user is signed out.
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebase(user);
    });
  }

  @override
  // Sign in with email and password
  // This method handles the sign-in process using email and password.
  Future<UserModel> signInWithEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      // Get additional user data from Firestore if needed
      final userData = await _getUserData(userCredential.user!.uid);

      return UserModel.fromFirebase(userCredential.user!, userData: userData);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  // Create a new user with email and password
  // This method handles the registration process using email and password.
  Future<UserModel> createUserWithEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Registration failed: No user created');
      }

      // Create user document in Firestore
      final user = userCredential.user!;
      await _createUserDocument(user.uid, email, user.displayName);

      return UserModel.fromFirebase(user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  // Sign in with Google
  // This method handles the Google sign-in process.
  Future<UserModel> signInWithGoogle() async {
    try {
      // Begin Google sign in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign In was canceled by the user');
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if this is a new user
      // TODO: CAN BE USED TO DISPLAY ONBORDING SCREEN
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Create user document for new users
        await _createUserDocument(user.uid, user.email ?? '', user.displayName);
      }

      // Get additional user data
      final userData = await _getUserData(user.uid);

      return UserModel.fromFirebase(user, userData: userData);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on PlatformException catch (e) {
      throw Exception('Failed to sign in with Google: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  // Sign out the current user
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  //  Send password reset email to the user
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  // Update user profile data
  // This method allows the user to update their profile information.
  Future<UserModel> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      // Update Firebase Auth profile
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);

      // Update Firestore user data
      if (displayName != null || photoURL != null) {
        final updates = <String, dynamic>{};
        if (displayName != null) updates['displayName'] = displayName;
        if (photoURL != null) updates['photoURL'] = photoURL;

        await _firestore.collection('users').doc(user.uid).update(updates);
      }

      // Reload user to get updated info
      await user.reload();
      final refreshedUser = _firebaseAuth.currentUser;

      // Get updated Firestore data
      final userData = await _getUserData(refreshedUser!.uid);

      return UserModel.fromFirebase(refreshedUser, userData: userData);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  // Check if user is authenticated
  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  // Helper methods
  // These methods handle common tasks related to authentication.
  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (!docSnapshot.exists) {
        debugPrint('User document not found for uid: $uid');
        return null;
      }
      return docSnapshot.data();
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // Create a new user document in Firestore
  // This method creates a new document in the Firestore 'users' collection for a new user.
  Future<void> _createUserDocument(
      String uid, String email, String? displayName) async {
    try {
      debugPrint('Attempting to create user document for uid: $uid');
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName ?? email.split('@').first,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Successfully created user document for uid: $uid');

      // Verify document was created
      final docCheck = await _firestore.collection('users').doc(uid).get();
      debugPrint('Document exists after creation: ${docCheck.exists}');
    } catch (e) {
      debugPrint('Error creating user document: $e');
      // Re-throw to make the error visible
      throw Exception('Failed to create user document: $e');
    }
  }

  // Handle Firebase authentication exceptions
  // This method maps FirebaseAuthException codes to user-friendly error messages.
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('The email address is already in use.');
      case 'invalid-email':
        return Exception('The email address is invalid.');
      case 'weak-password':
        return Exception('The password is too weak.');
      case 'operation-not-allowed':
        return Exception('This sign-in method is not enabled.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'account-exists-with-different-credential':
        return Exception(
            'An account already exists with the same email address.');
      case 'invalid-credential':
        return Exception('The credential is invalid or expired.');
      case 'invalid-verification-code':
        return Exception('The verification code is invalid.');
      case 'invalid-verification-id':
        return Exception('The verification ID is invalid.');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }

  // Debugging method to print current user information
  /* void debugCurrentUser() {
    final user = currentUser;
    if (user != null) {
      debugPrint('=== CURRENT USER INFO ===');
      debugPrint('User ID: ${user.uid}');
      debugPrint('User Email: ${user.email}');
      debugPrint('User Display Name: ${user.displayName}');
      debugPrint('User Photo URL: ${user.photoURL}');
      debugPrint('User Created: ${user.createdAt}');
      debugPrint('========================');
    } else {
      debugPrint('=== NO USER SIGNED IN ===');
    }
  } */

  // TO TEST THE CURRENT USER IN A SCREEN
  /* void _printCurrentUser(WidgetRef ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final user = authRepository.currentUser;

  if (user != null) {
    debugPrint('Current User: ${user.toJson()}');
  } else {
    debugPrint('No user is currently signed in');
  }
} */

  // THE BUTTON
  // ElevatedButton(
  //               onPressed: () => _printCurrentUser(ref),
  //               child: Text('Print Current User'),
  //             ),
}
