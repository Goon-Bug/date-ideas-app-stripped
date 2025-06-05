import 'package:date_spark_app/authentication/authentication_bloc.dart';
import 'package:date_spark_app/authentication/authentication_repository.dart';
import 'package:date_spark_app/login/view/login_page.dart';
import 'package:date_spark_app/main_common.dart';
import 'package:date_spark_app/main/cubit/token_cubit.dart';
import 'package:date_spark_app/main/view/dates_wheel_page.dart';
import 'package:date_spark_app/register/view/register_page.dart';
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
import 'package:date_spark_app/user/bloc/user_bloc.dart';
import 'package:date_spark_app/user/index.dart';
import 'package:date_spark_app/user/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await getIt<AuthenticationRepository>().isAccessTokenValid();
      getIt<TokenCubit>().updateBackendTokenCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: GetIt.instance<AuthenticationRepository>(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (_) => AuthenticationBloc(
              authenticationRepository:
                  GetIt.instance<AuthenticationRepository>(),
              userRepository: GetIt.instance<UserRepository>(),
            )..add(AuthenticationSubscriptionRequested()),
          ),
          BlocProvider(
            create: (_) => UserBloc(
              userRepository: GetIt.instance<UserRepository>(),
            ),
          ),
          BlocProvider(
            create: (_) => ThemeCubit(),
          ),
          BlocProvider(
            lazy: true,
            create: (_) => TimelineCubit(),
          ),
          BlocProvider(
            lazy: true,
            create: (_) => TokenCubit(),
          ),
        ],
        child: const AppView(),
      ),
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
            '/home': (context) => const DateIdeasWheelPage(),
            '/splash': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
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
          builder: (context, child) {
            return BlocListener<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) async {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                }
                switch (state.status) {
                  case AuthenticationStatus.authenticated:
                    await Future.delayed(const Duration(seconds: 3));

                    navigator.pushAndRemoveUntil<void>(
                      DateIdeasWheelPage.route(),
                      (route) => false,
                    );
                  case AuthenticationStatus.unauthenticated:
                    context.read<TimelineCubit>().clearTimeline();
                    if (context.mounted) {
                      context.read<UserBloc>().add(ClearUserBlocState());
                      await GetIt.instance<UserRepository>().clearUserCache();
                    }
                    await Future.delayed(const Duration(milliseconds: 2950));
                    navigator.push<void>(
                      LoginPage.route(),
                    );
                  case AuthenticationStatus.unknown:
                    break;
                }
              },
              child: child!,
            );
          },
        );
      },
    );
  }
}
