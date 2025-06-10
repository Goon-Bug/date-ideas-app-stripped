import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DateIdeasData {
  static final DateIdeasData _instance = DateIdeasData._internal();

  List<Map<String, dynamic>> dateIdeasMap = [];
  List<String> dateIdeasTitles = [];
  List<String> tagsList = [];
  List<Map<String, dynamic>> dateIdeasMapOriginal = [];

  DateIdeasData._internal();

  static DateIdeasData get instance => _instance;

  /// Load a .db file (e.g., downloaded or asset-based) into memory
  Future<void> loadData(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    log('Loading database from: $path');
    final db = await openDatabase(path);

    final List<Map<String, dynamic>> data = await db.rawQuery('''
      SELECT di.id, di.title, di.pack, di.description, di.location, di.duration, di.cost, 
             GROUP_CONCAT(t.name) AS tags
      FROM date_ideas di
      LEFT JOIN date_idea_tags dit ON di.id = dit.date_idea_id
      LEFT JOIN tags t ON dit.tag_id = t.id
      GROUP BY di.id
    ''');

    dateIdeasMap = data.map((idea) {
      final tags = (idea['tags'] as String?)?.split(',') ?? [];
      return {
        'id': idea['id'],
        'title': idea['title'],
        'pack': idea['pack'],
        'description': idea['description'],
        'location': idea['location'],
        'duration': idea['duration'],
        'cost': idea['cost'],
        'tags': tags,
      };
    }).toList();

    dateIdeasMapOriginal = List.from(dateIdeasMap);
    dateIdeasTitles =
        dateIdeasMap.map((idea) => idea['title'] as String).toList();

    final List<Map<String, dynamic>> tagsData =
        await db.rawQuery('SELECT DISTINCT name FROM tags ORDER BY name');

    tagsList = tagsData.map((tag) => tag['name'] as String).toList();

    log("Loaded ${dateIdeasMap.length} date ideas and tags: $tagsList");
  }

  /// Copy a .db file from assets (e.g., for built-in city packs)
  Future<void> copyAssetDatabase({
    bool overwrite = false,
    required String assetPath,
    required String dbName,
  }) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);
    final fileExists = await File(path).exists();

    if (fileExists && !overwrite) {
      log("Database $dbName already exists. Skipping copy.");
      return;
    }

    try {
      if (fileExists) {
        await File(path).delete();
        log("Overwriting existing database...");
      }

      final byteData = await rootBundle.load(assetPath);
      final buffer = byteData.buffer.asUint8List();
      await File(path).writeAsBytes(buffer);
      log("Asset database copied to: $path");
    } catch (e) {
      log("Error copying asset database: $e");
    }
  }

  /// Copy a downloaded city pack (.db file) into the app's database folder
  Future<void> copyDownloadedDatabase({
    required String dbName,
    required File downloadedFile,
  }) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);
    final fileExists = await File(path).exists();

    if (fileExists) {
      log("Database $dbName already exists. Deleting...");
      await File(path).delete();
    }

    try {
      await downloadedFile.copy(path);
      log("Downloaded database copied successfully to: $path");
    } catch (e) {
      log("Error copying downloaded database: $e");
    }
  }

  /// Filter loaded ideas by a list of tags
  bool filterDateIdeasByTags(List<String> requiredTags) {
    final filteredIdeas = dateIdeasMap.where((idea) {
      final ideaTags = idea['tags'] as List<String>;
      return requiredTags.every((tag) =>
          ideaTags.map((t) => t.toLowerCase()).contains(tag.toLowerCase()));
    }).toList();

    if (filteredIdeas.isNotEmpty) {
      dateIdeasMap = filteredIdeas;
      dateIdeasTitles =
          dateIdeasMap.map((idea) => idea['title'] as String).toList();
      return true;
    } else {
      return false;
    }
  }

  /// Reset back to the full unfiltered list
  void resetDateIdeas() {
    dateIdeasMap = List.from(dateIdeasMapOriginal);
    dateIdeasTitles =
        dateIdeasMapOriginal.map((idea) => idea['title'] as String).toList();
  }

  /// Utility: Check if a specific pack database is already installed
  Future<bool> isPackInstalled(String dbName) async {
    final databasePath = await getDatabasesPath();
    final fullPath = join(databasePath, dbName);
    return File(fullPath).exists();
  }
}
