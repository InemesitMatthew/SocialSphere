import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
    @Default(false) bool emailVerified,
    @Default({}) Map<String, dynamic> additionalData,
    @Default(AuthProvider.email) AuthProvider provider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Create a UserModel from Firebase Auth User
  factory UserModel.fromFirebase(dynamic firebaseUser,
      {Map<String, dynamic>? userData}) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      additionalData: userData ?? {},
      provider: _determineProvider(firebaseUser.providerData),
      createdAt: firebaseUser.metadata?.creationTime,
      lastLoginAt: firebaseUser.metadata?.lastSignInTime,
    );
  }

  /// Determine the authentication provider based on Firebase providerData
  static AuthProvider _determineProvider(List<dynamic>? providerData) {
    if (providerData == null || providerData.isEmpty) {
      return AuthProvider.email;
    }

    final providerIds =
        providerData.map((provider) => provider.providerId).toSet();

    if (providerIds.contains('google.com')) {
      return AuthProvider.google;
    } else if (providerIds.contains('password')) {
      return AuthProvider.email;
    }

    return AuthProvider.email;
  }
}

/// Enum representing supported authentication providers
enum AuthProvider {
  email,
  google,
  // Add other providers as needed
}
