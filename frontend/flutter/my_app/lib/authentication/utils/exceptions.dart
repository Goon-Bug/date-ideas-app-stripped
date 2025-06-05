class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}

class InvalidCredentialsException extends AuthenticationException {
  InvalidCredentialsException() : super('Invalid credentials');
}

class LoginFailedException extends AuthenticationException {
  LoginFailedException(String? error) : super('Login failed: $error');
}

class NetworkException extends AuthenticationException {
  NetworkException() : super('Network error: Please check your connection.');
}
