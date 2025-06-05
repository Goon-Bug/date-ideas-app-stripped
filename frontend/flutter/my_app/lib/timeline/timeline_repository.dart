import 'dart:developer';
import 'dart:io';
import 'package:date_spark_app/services/secure_storage_service.dart';
import 'package:date_spark_app/timeline/models/timeline.dart';
import 'package:date_spark_app/user/models/user.dart';
import 'package:date_spark_app/user/user_repository.dart';
import 'package:get_it/get_it.dart';

class TimelineRepository {
  final UserRepository userRepository;
  final SecureStorage storage;

  TimelineRepository()
      : userRepository = GetIt.instance<UserRepository>(),
        storage = SecureStorage();

  Future<List<TimelineItem>> getTimelineEntries() async {
    log('Fetching timeline entries...');

    final User? currentUser = await userRepository.getUser();
    if (currentUser == null) {
      log('User not found');
      throw Exception("User not found");
    }

    final key = 'timelineEntries_${currentUser.id}';
    final timelineJson = await storage.read(key: key);
    if (timelineJson != null) {
      log('Fetched timeline entries from storage for user: ${currentUser.id}');
      final timelineEntries = TimelineItem.decodeList(timelineJson);
      return timelineEntries;
    }

    log('No timeline entries in storage, falling back to current user data');
    return currentUser.timelineEntries;
  }

  Future<void> addTimelineEntry(TimelineItem newEntry) async {
    log('Adding new timeline entry: ${newEntry.id}');

    final User? currentUser = await userRepository.getUser();
    if (currentUser == null) {
      log('User not found');
      throw Exception("User not found");
    }

    final updatedEntries = List<TimelineItem>.from(currentUser.timelineEntries)
      ..add(newEntry);

    log('Updated timeline entries count: ${updatedEntries.length}');

    final updatedUser = currentUser.copyWith(timelineEntries: updatedEntries);
    await userRepository.updateUserInStorage(updatedUser);

    log('Timeline entry added successfully');
  }

  Future<void> removeTimelineEntry(String entryId) async {
    log('Removing timeline entry with ID: $entryId');

    final User? currentUser = await userRepository.getUser();
    if (currentUser == null) {
      log('User not found');
      throw Exception("User not found");
    }

    final entryToRemove =
        currentUser.timelineEntries.firstWhere((entry) => entry.id == entryId);
    log('Found entry to remove: ${entryToRemove.id}');

    if (entryToRemove.imagePath.isNotEmpty) {
      final imageFile = File(entryToRemove.imagePath);
      log('Checking if image exists at: ${entryToRemove.imagePath}');

      try {
        if (await imageFile.exists()) {
          await imageFile.delete();
          log('Image deleted at path: ${entryToRemove.imagePath}');
        } else {
          log('Image not found at path: ${entryToRemove.imagePath}');
        }
      } catch (e) {
        log("Image path error: $e");
      }
    }

    final updatedEntries = List<TimelineItem>.from(currentUser.timelineEntries)
      ..removeWhere((entry) => entry.id == entryId);

    log('Updated timeline entries count: ${updatedEntries.length}');

    final updatedUser = currentUser.copyWith(timelineEntries: updatedEntries);
    await userRepository.updateUserInStorage(updatedUser);
    log('Updated User Timeline Entries: ${updatedUser.timelineEntries.toString()}');

    log('Timeline entry successfully removed');
  }
}
