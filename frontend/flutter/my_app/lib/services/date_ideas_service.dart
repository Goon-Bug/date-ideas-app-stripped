import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DateIdeasData {
  static final DateIdeasData _instance = DateIdeasData._internal();

  List<Map<String, dynamic>> dateIdeasMap = [];
  List<String> dateIdeasTitles = [];
  List<String> tagsList = [];
  List<Map<String, dynamic>> dateIdeasMapOriginal = [];
  DateIdeasData._internal();

  static DateIdeasData get instance => _instance;

  Future<void> loadData(String jsonPath) async {
    final databasePath = await getDatabasesPath();
    log('Database path: $databasePath');
    final path = join(databasePath, jsonPath);

    final db = await openDatabase(path);
    log('Loading Database');

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
        'tags': tags, // Add tags as a list
      };
    }).toList();

    dateIdeasMapOriginal = dateIdeasMap;

    dateIdeasTitles = data.map((idea) => idea['title'] as String).toList();

    final List<Map<String, dynamic>> tagsData =
        await db.rawQuery('SELECT DISTINCT name FROM tags ORDER BY name');

    tagsList = tagsData.map((tag) => tag['name'] as String).toList();
    log("Loaded tags: $tagsList");
  }

  Future<void> copyDatabase(
      {bool overwrite = false, required String dbName}) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    final fileExists = await File(path).exists();

    if (fileExists) {
      if (overwrite) {
        log("Overwriting existing database...");
        await File(path).delete();
      } else {
        log("Database already exists. Skipping copy.");
        return;
      }
    }

    try {
      final byteData =
          await rootBundle.load('assets/date_ideas/liverpool_dates.db');
      final buffer = byteData.buffer.asUint8List();
      await File(path).writeAsBytes(buffer);
      log("Database copied successfully to: $path");
    } catch (e) {
      log("Error copying database: $e");
    }
  }

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

  void resetDateIdeas() {
    dateIdeasMap = dateIdeasMapOriginal;
    dateIdeasTitles =
        dateIdeasMapOriginal.map((idea) => idea['title'] as String).toList();
  }
}
