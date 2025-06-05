import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:date_spark_app/services/api/utils/exceptions.dart';

enum HttpStatus {
  success(200),
  created(201),
  noContent(204),
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  requestTimeout(408),
  internalServerError(500),
  networkError(0);

  final int code;

  const HttpStatus(this.code);
}

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  bool get isSuccess => error == null;

  ApiResponse({this.data, this.error, this.statusCode});
}

class ApiService {
  static const String _baseUrl = 'http://192.168.0.207:5000';

  // Private constructor
  ApiService._privateConstructor();

  // Singleton instance
  static final ApiService _instance = ApiService._privateConstructor();

  // Public getter for the instance
  static ApiService get instance => _instance;

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    log('POST URL: $url');

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 5));
      log('Response: ${response.body}');
      log('Response status code: ${response.statusCode}');
      if (response.statusCode == 429) {
        return ApiResponse<T>(
          error: 'Too many requests. Please try again later.',
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode == 401) {
        return ApiResponse<T>(
          error: 'Token expired. Please log in again.',
          statusCode: response.statusCode,
        );
      }

      final data = json.decode(response.body) as T;
      return ApiResponse<T>(data: data, statusCode: 200);
    } on SocketException catch (_) {
      throw NetworkException('Network error: Could not connect to server');
    } on TimeoutException catch (_) {
      throw NetworkException('Request timed out. Server may not be running');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final defaultHeaders = {
      'Content-Type': 'application/json',
    };
    final combinedHeaders = {
      ...defaultHeaders,
      if (headers != null) ...headers,
    };

    try {
      final response = await http
          .get(url, headers: combinedHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == HttpStatus.unauthorized.code) {
        throw ApiException('Unauthorized access');
      } else if (response.statusCode == 200 ||
          response.statusCode == HttpStatus.noContent.code) {
        final data = json.decode(response.body) as T;
        return ApiResponse<T>(data: data);
      } else {
        throw ApiException('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Network Error');
    }
  }
}
