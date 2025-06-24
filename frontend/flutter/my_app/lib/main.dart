// lib/main.dart

import 'package:date_spark_app/app.dart';
import 'package:date_spark_app/logger.dart';
import 'package:date_spark_app/main/cubit/token_cubit.dart';
import 'package:date_spark_app/services/ad_manager.dart';
import 'package:date_spark_app/services/date_ideas_service.dart';
import 'package:date_spark_app/services/secure_storage_service.dart';
import 'package:date_spark_app/timeline/timeline_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/widgets.dart';

import 'package:date_spark_app/helper_functions.dart' as hp;

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<TimelineRepository>(() => TimelineRepository());
  getIt.registerLazySingleton<TokenCubit>(() => TokenCubit());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureLogger();
  appLogger.info('Starting app initialization');

  final storage = SecureStorage();

  AdManager().initializeAds();

  await hp.logSystemFiles();

  // Uncomment this line if you want to clear storage at startup for dev/testing
  if (!const bool.fromEnvironment('dart.vm.product')) {
    await storage.deleteAll();
  }

  hp.addDefaultsToStorage();

  storage.printAllSecureStorage();

  setupDependencies();
  appLogger.info('App dependencies set up');

  await DateIdeasData.instance.copyAllDatabasesFromManifest(
    overwrite: true,
    manifestAssetPath: 'assets/db/manifest.json',
    assetsFolderPath: 'assets/db',
  );

  await DateIdeasData.instance.loadAllDatabasesFromManifest(
    manifestAssetPath: 'assets/db/manifest.json',
  );

  appLogger.info('Databases loaded, running app');

  runApp(const App());
}
