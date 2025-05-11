/// Base class for authentication exceptions
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

/// Thrown when there is an issue with the network connection
class NetworkAuthException extends AuthException {
  NetworkAuthException()
      : super(
            'Network connection issue. Please check your internet connection.');
}

/// Thrown when user cancels authentication process
class UserCanceledAuthException extends AuthException {
  UserCanceledAuthException() : super('Authentication canceled by user.');
}

/// Thrown when user credentials are invalid
class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Invalid email or password.');
}

/// Thrown when trying to create an account with email already in use
class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException()
      : super('This email is already associated with an account.');
}

/// Thrown when the email format is invalid
class InvalidEmailException extends AuthException {
  InvalidEmailException() : super('Please enter a valid email address.');
}

/// Thrown when the password does not meet security requirements
class WeakPasswordException extends AuthException {
  WeakPasswordException()
      : super('Please use a stronger password (at least 6 characters).');
}

/// Thrown when user account is not found
class UserNotFoundException extends AuthException {
  UserNotFoundException() : super('No account found with this email.');
}

/// Thrown when user account has been disabled
class UserDisabledException extends AuthException {
  UserDisabledException()
      : super('This account has been disabled. Please contact support.');
}

/// Thrown for any other authentication error
class GenericAuthException extends AuthException {
  GenericAuthException(super.message);
}
