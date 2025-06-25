import 'dart:io';
import 'package:date_spark_app/logger.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:date_spark_app/services/secure_storage_service.dart';

final Logger _log = taggedLogger('HelperFunctions');

final storage = SecureStorage();

String? createJwtToken(String username) {
  final jwt = JWT(
    {
      'username': username,
      'exp': (DateTime.now()
                  .toUtc()
                  .add(const Duration(hours: 1))
                  .millisecondsSinceEpoch /
              1000)
          .round(),
    },
  );
  try {
    const secretKey =
        String.fromEnvironment('JWT_SECRET_KEY', defaultValue: '');
    final token = jwt.sign(SecretKey(secretKey));
    return token;
  } catch (e) {
    _log.warning('Could not get secret key environment variable: $e');
    return null;
  }
}

Future<void> addTestUserToStorage() async {
  final storage = SecureStorage();
  await storage.deleteAllExceptTimelineEntries();
  await storage.write(key: 'username', value: 'testuser');
  _log.fine('Added test user to storage');
  await storage.write(key: 'id', value: '99');
  try {
    final token = createJwtToken('user').toString();
    await storage.write(key: 'accessToken', value: token);
    await storage.write(key: 'username', value: 'user');
    await storage.write(key: 'email', value: 'user@email.com');
    await storage.write(key: 'tokenCount', value: '100');
  } catch (e) {
    _log.warning('No test access token saved: $e');
  }
}

Future<void> addDefaultsToStorage() async {
  final allStorageData = await storage.readAll();
  _log.fine('All storage data: $allStorageData');
  if (allStorageData.isEmpty) {
    _log.fine('Storage is empty, adding defaults');
    await storage.write(key: 'tokenCount', value: '1');
    await storage.write(
        key: 'iconImage', value: 'assets/profile_icons/icon_0.png');
  } else {
    _log.fine('Storage already has data, skipping defaults');
  }
}

Future<void> logSystemFiles() async {
  final directory = await getApplicationDocumentsDirectory();
  final dirPath = directory.path;

  try {
    final dir = Directory(dirPath);
    final files = dir.listSync();
    _log.fine('Files in the directory $dirPath:');

    for (var file in files) {
      _log.fine(file.path);
    }
  } catch (e) {
    _log.warning('Error accessing directory: $e');
  }
}

Future<void> deleteAllFilesInDirectory(String directoryPath) async {
  try {
    final directory = Directory(directoryPath);
    if (await directory.exists()) {
      final files = directory.listSync();
      for (var file in files) {
        if (file is File) {
          try {
            await file.delete();
            _log.fine('Deleted file: ${file.path}');
          } catch (e) {
            _log.warning('Failed to delete file: ${file.path}, error: $e');
          }
        } else if (file is Directory) {
          _log.fine('Skipping subdirectory: ${file.path}');
        }
      }
      _log.fine('All files in directory deleted');
    } else {
      _log.fine('Directory does not exist: $directoryPath');
    }
  } catch (e) {
    _log.warning('Failed to delete files in directory: $e');
  }
}

Future<void> deleteAllAppFiles() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    await deleteAllFilesInDirectory(directory.path);
    _log.fine('App files Deleted');
  } catch (e) {
    _log.warning('Failed to delete all app files: $e');
  }
}
