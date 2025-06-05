import 'dart:async';
import 'dart:developer';

import 'package:date_spark_app/authentication/authentication_repository.dart';
import 'package:date_spark_app/services/api/api_service.dart';
import 'package:date_spark_app/services/secure_storage_service.dart';
import 'package:date_spark_app/timeline/models/timeline.dart';
import 'package:date_spark_app/user/models/user.dart';

class UserRepository {
  User? _user;
  final storage = SecureStorage();
  final _authenticationRepository = AuthenticationRepository();

  Future<void> clearUserCache() async {
    _user = null;
  }

  Future<User?> getUser() async {
    if (_user != null) {
      return _user;
    }
    try {
      final username = await storage.read(key: 'username');
      final idString = await storage.read(key: 'id');
      final email = await storage.read(key: 'email');
      final iconImage = await storage.read(key: 'iconImage');
      final tokenCount = await storage.read(key: 'tokenCount');

      if (username == null || idString == null || email == null) {
        return null;
      }

      final id = int.tryParse(idString);
      if (id == null) {
        return null;
      }

      final timelineKey = 'timelineEntries_$id';
      final timelineEntriesString = await storage.read(key: timelineKey);

      final timelineEntries = timelineEntriesString != null
          ? (TimelineItem.decodeList(timelineEntriesString))
          : <TimelineItem>[];

      _user = User(
        id: id,
        username: username,
        email: email,
        iconImage: iconImage ?? 'assets/profile_icons/icon_1.png',
        timelineEntries: timelineEntries,
        tokenCount: int.tryParse(tokenCount!)!,
      );
      log('Got user : $_user');
      return _user;
    } catch (e) {
      log('Get user failed: $e');
      return null;
    }
  }

  Future<User?> getUserWithTokenCheck() async {
    final tokenValid = await _authenticationRepository.isAccessTokenValid();

    if (tokenValid) {
      return await getUser();
    }
    return null;
  }

  Future<void> updateUserInStorage(User user) async {
    try {
      log('Updating user: $user');

      _user = user;

      await storage.write(key: 'id', value: user.id.toString());
      await storage.write(key: 'username', value: user.username);
      await storage.write(key: 'email', value: user.email);
      await storage.write(key: 'iconImage', value: user.iconImage);
      await storage.write(key: 'tokenCount', value: user.tokenCount.toString());

      // Persist timeline entries to storage
      final timelineKey = 'timelineEntries_${user.id}';
      final timelineJson = TimelineItem.encodeList(user.timelineEntries);
      await storage.write(key: timelineKey, value: timelineJson);

      log('User updated successfully in storage and cache.');
    } catch (e) {
      log('Failed to update user: $e');
      rethrow;
    }
  }

  Future<void> updateProfileIcon(String picturePath) async {
    try {
      log('Attempting to update profile icon with path: $picturePath');
      await storage.write(key: 'iconImage', value: picturePath);
      _user = _user?.copyWith(iconImage: picturePath);
      log('Successfully updated "iconImage" in storage and cache.');
    } catch (e) {
      log('Failed to update profile icon: $e');
    }
  }

  Future<ApiResponse<bool>> updateUsername(String newUsername) async {
    final userId = _user?.id.toString() ?? await storage.read(key: 'id');

    if (userId != null) {
      final valid = await _authenticationRepository.isAccessTokenValid();

      if (valid == false) {
        log('Access or refresh token is expired');
        return ApiResponse(
            error:
                'Access or refresh token is expired. Please log out and log back in.',
            statusCode: 401);
      }
      final accessToken = await storage.read(key: 'accessToken');
      final headers = {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json"
      };
      final body = {'username': newUsername, 'id': userId};

      log('Attempting to update username for user ID: $userId to $newUsername');
      final response = await ApiService.instance.post(
        "updateusername",
        body: body,
        headers: headers,
      );
      log(response.toString());

      if (response.isSuccess) {
        log('Successfully updated username on server for user ID: $userId');
        try {
          await storage.write(key: 'username', value: newUsername);
          _user = _user?.copyWith(username: newUsername);
          log('Successfully updated username in storage and cache.');
          return ApiResponse(data: true, statusCode: 200);
        } catch (e) {
          log('Failed to update username in local storage: $e');
          return ApiResponse(
              error: 'Failed to update username in storage: $e',
              statusCode: 500);
        }
      } else {
        log('Username update failed on server: ${response.error}');
        return ApiResponse(
            error: 'API request failed', statusCode: 400); // (New)
      }
    } else {
      log('Username update failed: User ID or Access token not found');
      return ApiResponse(
          error: 'User ID or Access token not found', statusCode: 401);
    }
  }

  Future<ApiResponse<bool>> updatePassword(String password) async {
    final userEmail =
        _user?.email.toString() ?? await storage.read(key: 'email');

    if (userEmail != null) {
      final valid = await _authenticationRepository.isAccessTokenValid();

      if (valid == false) {
        log('Access or refresh token is expired');
        return ApiResponse(
            error:
                'Access or refresh token is expired. Please log out and log back in.',
            statusCode: 401);
      }
      final accessToken = await storage.read(key: 'accessToken');
      final headers = {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json"
      };
      final body = {'email': userEmail, 'password': password};

      log('Attempting to update password for user email: $userEmail');
      final response = await ApiService.instance
          .post('updatepassword', body: body, headers: headers);

      if (response.isSuccess) {
        log('Password update successful for user email: $userEmail');
        return ApiResponse(data: true, statusCode: 200);
      } else {
        log('Password update failed: ${response.error}');
        return ApiResponse(
          error: response.error ?? 'API request failed',
          statusCode: response.statusCode,
        );
      }
    } else {
      log('Password update failed: User email or Access token not found');
      return ApiResponse(
          error: 'User email or Access token not found', statusCode: 401);
    }
  }

  Future<void> updateTimelineEntries(List<TimelineItem> entries) async {
    try {
      log('Attempting to update timeline entries: $entries');

      final userId = _user?.id ?? await storage.read(key: 'id');

      if (userId == null) {
        log('User ID not found');
        return;
      }

      final timelineKey = 'timelineEntries_$userId';
      final entriesJson = TimelineItem.encodeList(entries);

      await storage.write(key: timelineKey, value: entriesJson);
      _user = _user?.copyWith(timelineEntries: entries);

      log('Successfully updated timeline entries for user $userId in storage and cache.');
    } catch (e) {
      log('Failed to update timeline entries: $e');
    }
  }
}
