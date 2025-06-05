import 'package:date_spark_app/main/cubit/token_cubit.dart';
import 'package:date_spark_app/main/view/dates_wheel_page.dart';
import 'package:date_spark_app/services/navigation_service.dart';
import 'package:date_spark_app/settings/blocs/theme_cubit.dart';
import 'package:date_spark_app/settings/view/accounts_page.dart';
import 'package:date_spark_app/settings/view/change_theme_page.dart';
import 'package:date_spark_app/settings/view/main_settings_page.dart';
import 'package:date_spark_app/settings/view/privacy_policy_page.dart';
import 'package:date_spark_app/splash/splash_page.dart';
import 'package:date_spark_app/timeline/bloc/timeline_cubit.dart';
import 'package:date_spark_app/timeline/view/add_timeline_entry_page.dart';
import 'package:date_spark_app/timeline/view/timeline_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // Removed auth repo and token cubit logic here
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(lazy: true, create: (_) => TimelineCubit()),
        BlocProvider(lazy: true, create: (_) => TokenCubit()),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ColorScheme>(
      builder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/splash',
          routes: {
            '/home': (context) => DateIdeasWheelPage(),
            '/splash': (context) => const SplashPage(),
            '/settings': (context) => const SettingsPage(),
            '/accountManagement': (context) => const AccountManagementScreen(),
            '/changeTheme': (context) => const ChangeThemePage(),
            '/privacyPolicy': (context) => const PrivacyPolicyPage(),
            '/addTimelineEntry': (context) => const AddTimelineEntryPage(),
            '/timeline': (context) => const TimelinePage(),
          },
          theme: ThemeData(
            fontFamily: 'RetroSmall',
            colorScheme: theme,
            useMaterial3: true,
          ),
          navigatorKey: navigatorKey,
          builder: (context, child) => child!,
        );
      },
    );
  }
}
