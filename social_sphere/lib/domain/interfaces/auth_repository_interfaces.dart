import '../models/user_model.dart';

abstract class IAuthRepository {
  /// Get the current authenticated user
  UserModel? get currentUser;

  /// Stream of auth state changes
  Stream<UserModel?> get authStateChanges;

  /// Sign in with email and password
  Future<UserModel> signInWithEmailPassword(String email, String password);

  /// Create a new account with email and password
  Future<UserModel> createUserWithEmailPassword(String email, String password);

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign out the current user
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Update user profile data
  Future<UserModel> updateUserProfile({
    String? displayName,
    String? photoURL,
  });

  /// Check if user is authenticated
  bool isAuthenticated();
}
