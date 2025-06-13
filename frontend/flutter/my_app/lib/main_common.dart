// lib/main_common.dart

import 'package:date_spark_app/app.dart';
import 'package:date_spark_app/main/cubit/token_cubit.dart';
import 'package:date_spark_app/services/ad_manager.dart';
import 'package:date_spark_app/services/date_ideas_service.dart';
import 'package:date_spark_app/services/secure_storage_service.dart';
import 'package:date_spark_app/timeline/timeline_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/widgets.dart';

import 'package:date_spark_app/helper_functions.dart' as hp;

//FIXME: Fix warning for source 8

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<TimelineRepository>(() => TimelineRepository());
  getIt.registerLazySingleton<TokenCubit>(() => TokenCubit());
}

Future<void> mainCommon({required bool isTestMode}) async {
  final storage = SecureStorage();
  WidgetsFlutterBinding.ensureInitialized();
  AdManager().initializeAds();
  await hp.logSystemFiles();
  // SecureStorage().deleteAll();
  hp.addDefaultsToStorage();
  storage.printAllSecureStorage();

  setupDependencies();

  await DateIdeasData.instance.copyAllDatabasesFromManifest(
    overwrite: true,
    manifestAssetPath: 'assets/db/manifest.json',
    assetsFolderPath: 'assets/db',
  );

  await DateIdeasData.instance.loadAllDatabasesFromManifest(
      manifestAssetPath: 'assets/db/manifest.json');

  runApp(const App());
}
