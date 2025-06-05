import 'dart:developer';
import 'dart:io';
import 'package:date_spark_app/services/secure_storage_service.dart';
import 'package:date_spark_app/timeline/models/timeline.dart';

class TimelineRepository {
  final SecureStorage storage;
  final String storageKey = 'timelineEntries';

  TimelineRepository() : storage = SecureStorage();

  Future<List<TimelineItem>> getTimelineEntries() async {
    log('Fetching timeline entries...');

    final timelineJson = await storage.read(key: storageKey);

    if (timelineJson != null) {
      log('Fetched timeline entries from storage');
      final timelineEntries = TimelineItem.decodeList(timelineJson);
      return timelineEntries;
    }

    log('No timeline entries found');
    return [];
  }

  Future<void> addTimelineEntry(TimelineItem newEntry) async {
    log('Adding new timeline entry: ${newEntry.id}');

    final currentJson = await storage.read(key: storageKey);
    final currentEntries = currentJson != null
        ? TimelineItem.decodeList(currentJson)
        : <TimelineItem>[];

    final updatedEntries = [...currentEntries, newEntry];
    await storage.write(
      key: storageKey,
      value: TimelineItem.encodeList(updatedEntries),
    );

    log('Updated timeline entries count: ${updatedEntries.length}');
  }

  Future<void> removeTimelineEntry(String entryId) async {
    log('Removing timeline entry with ID: $entryId');

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
          log('Image deleted at path: ${entryToRemove.imagePath}');
        } else {
          log('Image not found at path: ${entryToRemove.imagePath}');
        }
      } catch (e) {
        log("Image deletion error: $e");
      }
    }

    final updatedEntries =
        currentEntries.where((entry) => entry.id != entryId).toList();

    await storage.write(
      key: storageKey,
      value: TimelineItem.encodeList(updatedEntries),
    );

    log('Updated timeline entries count: ${updatedEntries.length}');
  }
}
