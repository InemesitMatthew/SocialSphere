import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_sphere/domain/interfaces/auth_repository_interfaces.dart';
import '../../../domain/models/user_model.dart';
import '../repository/firebase_auth_repository.dart';

// Provide the auth repository
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// Provide the auth state as a stream
final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Provide the current user
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provide authentication state notifier
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final IAuthRepository _authRepository;
  final String _userCacheKey = 'cached_user';

  AuthController(this._authRepository) : super(const AsyncValue.loading()) {
    // Initialize with cached user if available
    _initFromCache();

    // Subscribe to auth state changes
    _authRepository.authStateChanges.listen((user) {
      state = AsyncValue.data(user);

      // Cache user data on changes
      if (user != null) {
        _cacheUserData(user);
      } else {
        _clearUserCache();
      }
    });
  }

  // Load cached user data
  Future<void> _initFromCache() async {
    try {
      final box = await Hive.openBox('auth_cache');
      final userData = box.get(_userCacheKey);

      if (userData != null) {
        final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
        state = AsyncValue.data(user);
      } else {
        state = AsyncValue.data(_authRepository.currentUser);
      }
    } catch (e) {
      state = AsyncValue.data(_authRepository.currentUser);
    }
  }

  // Cache user data
  Future<void> _cacheUserData(UserModel user) async {
    try {
      final box = await Hive.openBox('auth_cache');
      await box.put(_userCacheKey, user.toJson());
    } catch (e) {
      // Handle cache error
      debugPrint('Error caching user data: $e');
    }
  }

  // Clear user cache
  Future<void> _clearUserCache() async {
    try {
      final box = await Hive.openBox('auth_cache');
      await box.delete(_userCacheKey);
    } catch (e) {
      // Handle cache error
      debugPrint('Error clearing user cache: $e');
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final user =
          await _authRepository.signInWithEmailPassword(email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Create account with email and password
  Future<void> createAccount(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final user =
          await _authRepository.createUserWithEmailPassword(email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final user = await _authRepository.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = await _authRepository.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      state = AsyncValue.data(user);
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _authRepository.isAuthenticated();
  }
}
