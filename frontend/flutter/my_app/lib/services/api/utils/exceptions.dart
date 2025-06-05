class ApiException implements Exception {
  final String message;

  ApiException([this.message = 'An unknown error occurred']);

  @override
  String toString() {
    return message;
  }
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Unauthorized access']);
}

class ServerException extends ApiException {
  ServerException([super.message = 'Server error occurred']);
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'Network error occurred']);
}
