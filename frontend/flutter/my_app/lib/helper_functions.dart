import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:date_spark_app/services/secure_storage_service.dart';

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
    log('Couldn not get secret key environment variable: $e');
    return null;
  }
}

Future<void> addTestUserToStorage() async {
  final storage = SecureStorage();
  await storage.deleteAllExceptTimelineEntries();
  await storage.write(key: 'username', value: 'testuser');
  log('Added test user to storage');
  await storage.write(key: 'id', value: '99');
  try {
    final token = createJwtToken('user').toString();
    await storage.write(key: 'accessToken', value: token);
    await storage.write(key: 'username', value: 'user');
    await storage.write(key: 'email', value: 'user@email.com');
    await storage.write(key: 'tokenCount', value: '100');
  } catch (e) {
    log('No test access token saved');
  }
}

// Future<void> addTestTimelineEntriesToStorage() async {
//   final List<TimelineItem> testEntries = [
//     TimelineItem(
//       id: '1',
//       dateId: '101',
//       date: '2025-01-01',
//       imagePath: 'assets/images/sample1.jpg',
//       userId: '5',
//       description: 'New Year Celebration',
//     ),
//     TimelineItem(
//       id: '2',
//       dateId: '102',
//       date: '2025-01-15',
//       imagePath: 'assets/images/sample2.jpg',
//       userId: '5',
//       description: 'Winter Wonderland Date',
//     ),
//     TimelineItem(
//       id: '3',
//       dateId: '103',
//       date: '2025-02-14',
//       imagePath: 'assets/images/sample3.jpg',
//       userId: '5',
//       description: 'Valentine\'s Day Dinner',
//     ),
//   ];

//   try {
//     // Copy each image from assets to the file system
//     for (var entry in testEntries) {
//       final imagePath = await _copyAssetToFileSystem(entry.imagePath);
//       if (imagePath.isNotEmpty) {
//         // Update the image path in the timeline entry
//         final updatedEntry = entry.copyWith(imagePath: imagePath);
//         // Update the entry in the list with the new image path
//         final index = testEntries.indexOf(entry);
//         if (index != -1) {
//           testEntries[index] = updatedEntry; // Update the original entry
//         }
//       }
//     }

//     final String encodedEntries = TimelineItem.encodeList(testEntries);
//     await storage.write(key: 'timelineEntries', value: encodedEntries);
//     log('Test timeline entries added to storage');
//   } catch (e) {
//     log('Failed to add test timeline entries: $e');
//   }
// }

// Future<String> _copyAssetToFileSystem(String assetPath) async {
//   try {
//     final ByteData data = await rootBundle.load(assetPath);
//     final buffer = data.buffer.asUint8List();
//     final directory =
//         await getApplicationDocumentsDirectory(); // Get the app's documents directory
//     final filePath =
//         '${directory.path}/${assetPath.split('/').last}'; // Get a unique file path
//     final file = File(filePath);

//     await file.writeAsBytes(buffer); // Write the asset to the file system
//     return file.path;
//   } catch (e) {
//     log('Failed to copy asset to file system: $e');
//     return '';
//   }
// }

Future<void> addDefaultsToStorage() async {
  final allStorageData = await storage.readAll();
  log('All storage data: $allStorageData');
  if (allStorageData.isEmpty) {
    log('Storage is empty, adding defaults');
    await storage.write(key: 'tokenCount', value: '10');
    await storage.write(
        key: 'iconImage', value: 'assets/profile_icons/icon_0.png');
  } else {
    log('Storage already has data, skipping defaults');
  }
}

Future<void> logSystemFiles() async {
  final directory = await getApplicationDocumentsDirectory();
  final dirPath = directory.path;

  try {
    final dir = Directory(dirPath);
    final files = dir.listSync();
    log('Files in the directory $dirPath:');

    for (var file in files) {
      log(file.path);
    }
  } catch (e) {
    log('Error accessing directory: $e');
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
            log('Deleted file: ${file.path}');
          } catch (e) {
            log('Failed to delete file: ${file.path}, error: $e');
          }
        } else if (file is Directory) {
          log('Skipping subdirectory: ${file.path}');
        }
      }
      log('All files in directory deleted');
    } else {
      log('Directory does not exist: $directoryPath');
    }
  } catch (e) {
    log('Failed to delete files in directory: $e');
  }
}

Future<void> deleteAllAppFiles() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    await deleteAllFilesInDirectory(directory.path);
    log('App files Deleted');
  } catch (e) {
    log('Failed to delete all app files: $e');
  }
}
