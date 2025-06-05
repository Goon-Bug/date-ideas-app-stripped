import 'dart:developer';

import 'package:date_spark_app/authentication/authentication_bloc.dart';
import 'package:date_spark_app/authentication/authentication_repository.dart';
import 'package:date_spark_app/main/bloc/dates_scroller_bloc.dart';
import 'package:date_spark_app/main/bloc/dates_scroller_state.dart';
import 'package:date_spark_app/main/cubit/token_cubit.dart';
import 'package:date_spark_app/main/view/tags_widget.dart';
import 'package:date_spark_app/services/ad_manager.dart';
import 'package:date_spark_app/services/date_ideas_service.dart';
import 'package:date_spark_app/timeline/bloc/timeline_cubit.dart';
import 'package:date_spark_app/user/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:date_spark_app/services/navigation_service.dart';
import 'package:date_spark_app/main/tags/tags_cubit.dart';

// Utility extension for string capitalization
extension StringCasingExtension on String {
  String toTitleCase() {
    return split(' ')
        .map((word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}

NavigatorState get navigator => navigatorKey.currentState!;

class DateIdeasWheelPage extends StatelessWidget {
  const DateIdeasWheelPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const DateIdeasWheelPage());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TokenCubit, TokenState>(
          listener: (context, state) {
            if (state.tokenLimitReached) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You have reached the token limit!'),
                  duration: Duration(seconds: 3),
                ),
              );
            } else if (state.tokenUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tokens updated: ${state.tokenCount}'),
                  duration: const Duration(seconds: 3),
                ),
              );
              context.read<UserBloc>().add(UpdateUserTokens(state.tokenCount));
            }
          },
        ),
      ],
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => DatesScrollerBloc()),
              BlocProvider(
                  create: (_) => TagsCubit(DateIdeasData.instance.tagsList)),
            ],
            child: BlocBuilder<DatesScrollerBloc, DatesScrollerState>(
              builder: (context, state) {
                final bool isSpinning = state is DatesScrollerSpinTo;

                return Scaffold(
                  appBar: AppBar(
                    title: Text(authState.user.username,
                        style: const TextStyle(fontSize: 32)),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: isSpinning
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/settings');
                              },
                      ),
                    ],
                    leading: Builder(
                      builder: (context) {
                        return IconButton(
                          icon: CircleAvatar(
                            backgroundImage:
                                AssetImage(authState.user.iconImage),
                            backgroundColor: Colors.transparent,
                            radius: 30,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        );
                      },
                    ),
                  ),
                  body: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 45,
                              width: 95,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 5,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () {
                                  AdManager().showRewardedAd(
                                    onRewarded: (reward) async {
                                      log(reward.amount.toString());
                                      await context
                                          .read<TokenCubit>()
                                          .addTokens(reward.amount as int);
                                    },
                                    context: context,
                                  );
                                },
                                child: Text(
                                  'Watch Ad',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                    height: 0.9,
                                    letterSpacing: 0.1,
                                    fontFamily: 'RetroTitle',
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Token Count: ${context.watch<TokenCubit>().state.tokenCount}',
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Expanded(flex: 2, child: DateIdeasWheelContent()),
                      Expanded(
                        flex: 2,
                        child: TagsCheckboxGrid(
                          tagNames: DateIdeasData.instance.tagsList
                              .map((tag) => tag.toTitleCase())
                              .toList(),
                          enabled: !isSpinning,
                        ),
                      ),
                    ],
                  ),
                  drawer: (authState.status == AuthenticationStatus.unknown ||
                          isSpinning)
                      ? null
                      : Drawer(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              UserAccountsDrawerHeader(
                                accountName: Text(authState.user.username,
                                    style: const TextStyle(fontSize: 22)),
                                accountEmail: Text(authState.user.email,
                                    style: const TextStyle(fontSize: 18)),
                                currentAccountPicture: CircleAvatar(
                                  backgroundImage:
                                      AssetImage(authState.user.iconImage),
                                ),
                              ),
                              DefaultTextStyle(
                                style: const TextStyle(fontSize: 28),
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: const Text('My Timeline'),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/timeline');
                                      },
                                    ),
                                    ListTile(
                                      title: const Text('Settings'),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/settings');
                                      },
                                    ),
                                    ListTile(
                                      title: const Text('Logout'),
                                      enabled: authState.status !=
                                          AuthenticationStatus.unknown,
                                      onTap: authState.status ==
                                              AuthenticationStatus.unknown
                                          ? null
                                          : () async {
                                              context
                                                  .read<AuthenticationBloc>()
                                                  .add(
                                                      AuthenticationLogoutPressed());
                                              Navigator.of(context).pop();
                                            },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DateIdeasWheelContent extends StatefulWidget {
  const DateIdeasWheelContent({super.key});

  @override
  State<DateIdeasWheelContent> createState() => _DateIdeasWheelContentState();
}

class _DateIdeasWheelContentState extends State<DateIdeasWheelContent> {
  final ScrollController scrollController = ScrollController();
  bool isSpinning = false;

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: SizedBox(
              height: 200,
              child: BlocConsumer<DatesScrollerBloc, DatesScrollerState>(
                listener: (context, state) {
                  if (state is DatesScrollerSpinTo) {
                    setState(() {
                      isSpinning = true;
                    });
                    scrollController.animateTo(
                      state.position,
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOut,
                    );
                  } else if (state is DatesScrollerIdle) {
                    setState(() {
                      isSpinning = false;
                    });
                    scrollController.animateTo(
                      0.0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                    );
                  } else if (state is DatesScrollerResult) {
                    setState(() {
                      isSpinning = false;
                    });
                    showResultDialog(context, state.selectedDateIdea);
                  } else if (state is DatesScrollerFiltered) {
                    if (!state.isFiltered) {
                      showSnackBar(
                          context, 'No date ideas match the selected tags.');
                      context
                          .read<DatesScrollerBloc>()
                          .add(DatesScrollerResetRequested());
                      context.read<TagsCubit>().resetTags();
                    } else {
                      showSnackBar(context,
                          'Date Ideas have been filtered with selected tags');
                    }
                  }
                },
                builder: (context, state) {
                  final List<Map<String, String>> dateIdeas = [
                    {'title': 'Spin the Wheel!'},
                    ...state.dateIdeas.map((idea) => {
                          'title': idea['title'].toString(),
                        })
                  ];
                  return SizedBox(
                    height: 200.0,
                    child: ListWheelScrollView.useDelegate(
                      overAndUnderCenterOpacity: 0.2,
                      controller: scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemExtent: 50,
                      perspective: 0.003,
                      diameterRatio: 1.5,
                      childDelegate: ListWheelChildLoopingListDelegate(
                        children: dateIdeas.map((idea) {
                          return Center(
                            child: Text(
                              idea['title']!,
                              style: const TextStyle(
                                fontFamily: 'RetroTitle',
                                fontSize: 40,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 10),
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: isSpinning
                ? null
                : () {
                    final tokenCount =
                        context.read<TokenCubit>().state.tokenCount;
                    if (tokenCount < 1) {
                      showSnackBar(context,
                          'Not enough tokens to spin the wheel! Watch an ad to gain more tokens');
                      return;
                    }
                    context
                        .read<DatesScrollerBloc>()
                        .add(DatesScrollerSpinRequested());
                    context
                        .read<TokenCubit>()
                        .useTokens(10); //NOTE: 0 for testing
                  },
            child: Text(
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24),
                'Spin the Wheel!'),
          ),
        ),
      ],
    );
  }

  void showResultDialog(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  result['title'],
                  style: const TextStyle(
                    fontFamily: 'RetroTitle',
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  result['description'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    navigator.pop(dialogContext);
                    context
                        .read<DatesScrollerBloc>()
                        .add(DatesScrollerResetRequested());
                    context.read<TagsCubit>().resetTags();
                    await context.read<TimelineCubit>().resetSelectedDateIdea();
                  },
                  child: const Text('OK',
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    context
                        .read<DatesScrollerBloc>()
                        .add(DatesScrollerResetRequested());
                    await context.read<TimelineCubit>().selectDateIdea(result);
                    navigator.pushReplacementNamed('/timeline');
                    navigator.pushNamed('/addTimelineEntry');
                  },
                  child: const Text('Add date to timeline',
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DateIdeasWheelPage(),
  ));
}
