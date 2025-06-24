import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';

class FileLogWriter {
  IOSink? _sink;
  static const int maxAgeDays = 60;

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/app_logs.txt');

    if (await logFile.exists()) {
      final lastModified = await logFile.lastModified();
      final age = DateTime.now().difference(lastModified).inDays;

      if (age >= maxAgeDays) {
        await logFile.delete();
      }
    }

    _sink = logFile.openWrite(mode: FileMode.append);
  }

  void write(LogRecord record) {
    final logEntry =
        '${record.level.name} | ${record.time.toIso8601String()} | ${record.loggerName}: ${record.message}\n';
    _sink?.write(logEntry);
  }

  Future<void> close() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
