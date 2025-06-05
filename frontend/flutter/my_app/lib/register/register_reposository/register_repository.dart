import 'dart:async';
import 'dart:developer';
import 'package:date_spark_app/services/api/api_service.dart';
import 'package:date_spark_app/services/api/utils/exceptions.dart';

class RegisterRepository {
  final _apiService = ApiService.instance;

  Future<void> register(String username, String password, String email) async {
    try {
      final credentialsJson = {
        'username': username,
        'password': password,
        'email': email,
      };
      final headers = {
        'Content-Type': 'application/json',
      };
      final response = await _apiService.post('register',
          headers: headers, body: credentialsJson);
      if (response.data.toString().contains("error")) {
        log("error: ${response.data}");
        throw ApiException('Failed to register: ${response.data}');
      }
      if (response.data == null) {
        throw ApiException('No data received from the server');
      }
      log("Register response: ${response.data}");
    } catch (e) {
      throw ApiException('An error occurred: ${e.toString()}');
    }
  }
}
