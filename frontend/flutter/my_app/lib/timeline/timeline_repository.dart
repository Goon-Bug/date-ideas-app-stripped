import 'dart:io';
import 'package:date_spark_app/logger.dart';
import 'package:date_spark_app/services/secure_storage_service.dart';
import 'package:date_spark_app/timeline/models/timeline.dart';
import 'package:logging/logging.dart';

final Logger _log = taggedLogger('TimelineRepository');

class TimelineRepository {
  final SecureStorage storage;
  final String storageKey = 'timelineEntries';

  TimelineRepository() : storage = SecureStorage();

  Future<List<TimelineItem>> getTimelineEntries() async {
    _log.fine('Fetching timeline entries...');

    final timelineJson = await storage.read(key: storageKey);

    if (timelineJson != null) {
      _log.fine('Fetched timeline entries from storage');
      final timelineEntries = TimelineItem.decodeList(timelineJson);
      return timelineEntries;
    }

    _log.fine('No timeline entries found');
    return [];
  }

  Future<void> addTimelineEntry(TimelineItem newEntry) async {
    _log.fine('Adding new timeline entry: ${newEntry.id}');

    final currentJson = await storage.read(key: storageKey);
    final currentEntries = currentJson != null
        ? TimelineItem.decodeList(currentJson)
        : <TimelineItem>[];

    final updatedEntries = [...currentEntries, newEntry];
    await storage.write(
      key: storageKey,
      value: TimelineItem.encodeList(updatedEntries),
    );

    _log.fine('Updated timeline entries count: ${updatedEntries.length}');
  }

  Future<void> removeTimelineEntry(String entryId) async {
    _log.fine('Removing timeline entry with ID: $entryId');

    final currentJson = await storage.read(key: storageKey);
    final currentEntries = currentJson != null
        ? TimelineItem.decodeList(currentJson)
        : <TimelineItem>[];

    final entryToRemove =
        currentEntries.firstWhere((entry) => entry.id == entryId);

    if (entryToRemove.imagePath.isNotEmpty) {
      final imageFile = File(entryToRemove.imagePath);
      try {
        if (await imageFile.exists()) {
          await imageFile.delete();
          _log.fine('Image deleted at path: ${entryToRemove.imagePath}');
        } else {
          _log.fine('Image not found at path: ${entryToRemove.imagePath}');
        }
      } catch (e) {
        _log.warning('Image deletion error: $e');
      }
    }

    final updatedEntries =
        currentEntries.where((entry) => entry.id != entryId).toList();

    await storage.write(
      key: storageKey,
      value: TimelineItem.encodeList(updatedEntries),
    );

    _log.fine('Updated timeline entries count: ${updatedEntries.length}');
  }

  Future<void> updateTimelineEntry(TimelineItem updatedEntry) async {
    _log.fine('Updating timeline entry with ID: ${updatedEntry.id}');

    final currentJson = await storage.read(key: storageKey);
    final currentEntries = currentJson != null
        ? TimelineItem.decodeList(currentJson)
        : <TimelineItem>[];

    final index =
        currentEntries.indexWhere((entry) => entry.id == updatedEntry.id);

    if (index == -1) {
      _log.warning(
          'Timeline entry with ID ${updatedEntry.id} not found for update.');
      return;
    }

    currentEntries[index] = updatedEntry;

    await storage.write(
      key: storageKey,
      value: TimelineItem.encodeList(currentEntries),
    );

    _log.fine(
        'Successfully updated timeline entry with ID: ${updatedEntry.id}');
  }
}
