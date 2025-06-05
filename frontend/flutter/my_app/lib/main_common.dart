// lib/main_common.dart

import 'package:date_spark_app/app.dart';
import 'package:date_spark_app/main/cubit/token_cubit.dart';
import 'package:date_spark_app/services/ad_manager.dart';
import 'package:date_spark_app/services/date_ideas_service.dart';
import 'package:date_spark_app/services/secure_storage_service.dart';
import 'package:date_spark_app/timeline/timeline_repository.dart';
import 'package:date_spark_app/user/user_repository.dart';
import 'package:date_spark_app/authentication/authentication_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/widgets.dart';

import 'package:date_spark_app/helper_functions.dart' as hp;

//FIXME: Fix warning for source 8

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<AuthenticationRepository>(AuthenticationRepository());
  getIt.registerSingleton<UserRepository>(UserRepository());
  getIt.registerLazySingleton<TimelineRepository>(() => TimelineRepository());
  getIt.registerLazySingleton<TokenCubit>(() => TokenCubit());
}

Future<void> mainCommon({required bool isTestMode}) async {
  WidgetsFlutterBinding.ensureInitialized();
  AdManager().initializeAds();

  if (isTestMode) {
    await hp.logSystemFiles();
    SecureStorage().deleteAll();
    await hp.deleteAllAppFiles();
    await hp.logSystemFiles();
    await hp.addTestUserToStorage(); // keep only for test
  }

  setupDependencies();

  await DateIdeasData.instance.copyDatabase(overwrite: true);
  await DateIdeasData.instance.loadData();

  runApp(const App());
}
