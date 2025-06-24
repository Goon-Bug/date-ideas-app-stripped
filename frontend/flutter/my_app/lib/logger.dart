import 'package:date_spark_app/file_log_writer.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final Logger appLogger = Logger('DateSparkApp');
final FileLogWriter fileLogWriter = FileLogWriter();

final bool isProduction = bool.fromEnvironment('dart.vm.product');

/// Initializes global logger configuration
Future<void> configureLogger() async {
  await fileLogWriter.init();

  Logger.root.level = isProduction ? Level.WARNING : Level.ALL;

  Logger.root.onRecord.listen((record) {
    final logMessage =
        '${record.level.name} | ${record.time.toIso8601String()} | ${record.loggerName}: ${record.message}';

    if (kDebugMode) {
      print(logMessage);
    }

    fileLogWriter.write(record);
  });
}

/// Returns a logger instance tagged with the provided name.
/// Example: final log = taggedLogger('TokenCubit');
Logger taggedLogger(String name) => Logger('DateSparkApp.$name');
