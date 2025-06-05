import 'dart:async';
import 'dart:developer';
import 'package:date_spark_app/user/models/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:date_spark_app/services/api/index.dart';
import 'package:date_spark_app/services/secure_storage_service.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  final _apiService = ApiService.instance;
  final secureStorage = SecureStorage();

  Stream<AuthenticationStatus> get status async* {
    yield* _controller.stream;
  }

  Future<void> _storeUserData(Map<String, String> data) async {
    await Future.wait(
      data.entries.map((entry) async {
        await secureStorage.write(key: entry.key, value: entry.value);
      }),
    );
  }

  Future<User> logIn(String email, String password) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };
      final credentialsJson = {
        'email': email,
        'password': password,
      };

      final response = await _apiService.post('login',
          headers: headers, body: credentialsJson);

      if (response.isSuccess == false) {
        throw ApiException('Login failed. Please check your credentials.');
      }

      final data = response.data;

      if (data.containsKey('error')) {
        throw ApiException(data['error']);
      }

      await _storeUserData({
        'accessToken': data['access_token'],
        'refreshToken': data['refresh_token'],
        'email': data['email'],
        'username': data['username'],
        'id': data['id'],
        'tokenCount': data['token_count'] as String,
        'tokenUpdated': 'false',
      });

      final idString = data['id'];
      if (idString == null || idString.isEmpty) {
        throw ApiException('Missing user ID');
      }

      final id = int.tryParse(idString);
      if (id == null) {
        throw ApiException('Invalid user ID');
      }

      final user =
          User(id: id, username: data['username'], email: data['email']);
      return user;
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
      } else {
        throw ApiException('An error occurred: ${e.toString()}');
      }
    }
  }

  Future<void> logOut() async {
    final refreshToken = await secureStorage.read(key: 'refreshToken');
    log('Got users refresh token: $refreshToken');
    final headers = {
      'Authorization': 'Bearer $refreshToken',
      'Content-Type': 'application/json',
    };
    final userId = await secureStorage.read(key: 'id');

    if (refreshToken == null || userId == null) {
      log('Missing token or user ID. Clearing storage and exiting logout.');
      await secureStorage.deleteAllExceptTimelineEntries();
      return;
    }

    try {
      final themeString =
          await secureStorage.read(key: 'selectedTheme') ?? 'tropicalSunset';
      await _apiService.post('logout', body: {'id': userId}, headers: headers);
      log('Deleting user in storage...');
      await secureStorage.deleteAllExceptTimelineEntries();
      await secureStorage.write(key: 'selectedTheme', value: themeString);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getRefreshToken() async {
    final refreshToken = await secureStorage.read(key: 'refreshToken');
    if (refreshToken == null) {
      return null;
    }
    final isExpired = JwtDecoder.isExpired(refreshToken);
    if (isExpired == false) {
      return refreshToken;
    } else {
      return null;
    }
  }

  Future<bool> isAccessTokenValid() async {
    log('Checking if access token is valid');

    final accessToken = await secureStorage.read(key: 'accessToken');
    if (accessToken == null) {
      log('No access token found');
      return false;
    }

    if (!JwtDecoder.isExpired(accessToken)) {
      log('Access token is valid');
      return true;
    }

    log('Access token expired. Attempting to refresh.');

    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      log('No refresh token found');
      return false;
    }

    try {
      final headers = {'Authorization': 'Bearer $refreshToken'};
      final response = await _apiService.post('refresh', headers: headers);
      log(response.statusCode.toString());

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        await secureStorage.write(key: 'accessToken', value: newAccessToken);
        log('Access token refreshed successfully');
        return true;
      } else {
        log('Failed to refresh access token: ${response.data}');
        return false;
      }
    } catch (e) {
      log('Error during token refresh: $e');
      return false;
    }
  }

  void dispose() => _controller.close();
}
