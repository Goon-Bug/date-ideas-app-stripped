import 'package:date_spark_app/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

final Logger _log = taggedLogger('SecureStorageService');

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory SecureStorage() {
    return _instance;
  }

  SecureStorage._internal();

  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    final value = await _storage.read(key: key);
    return value;
  }

  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
    _log.info('Deleted key: $key');
  }

  Future<void> deleteAllExceptTimelineEntries() async {
    final allItems = await _storage.readAll();
    final keysToDelete =
        allItems.keys.where((key) => !key.startsWith('timelineEntries_'));

    await Future.wait(keysToDelete.map((key) => _storage.delete(key: key)));

    _log.info('Deleted all keys except timeline-related ones.');
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
    _log.info('Deleted all keys.');
  }

  Future<Map<String, String>> readAll() async {
    final Map<String, String> allItems = await _storage.readAll();
    return allItems;
  }

  Future<void> printAllSecureStorage() async {
    final allData = await _storage.readAll();
    if (allData.isEmpty) {
      _log.info("SecureStorage is empty.");
    } else {
      _log.info("SecureStorage contents:");
      allData.forEach((key, value) {
        _log.info("$key: $value");
      });
    }
  }
}
