import 'dart:developer';
import 'dart:io';
import 'package:date_spark_app/main/bloc/dates_scroller_bloc.dart';
import 'package:date_spark_app/main/tags/tags_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:date_spark_app/timeline/bloc/timeline_cubit.dart';
import 'package:date_spark_app/timeline/models/timeline.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const TimelinePage());
  }

  @override
  Widget build(BuildContext context) {
    context.read<TimelineCubit>().loadTimelineEntries();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // If already popped, just return
        if (didPop) return;
        context.read<DatesScrollerBloc>().add(DatesScrollerResetRequested());
        context.read<TagsCubit>().resetTags();

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Timeline'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return BlocConsumer<TimelineCubit, TimelineState>(
              listener: (context, state) {
                log("$state");

                if (state.status == TimelineStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage ?? 'Error')),
                  );
                } else if (state.status == TimelineStatus.added) {
                  context.read<TimelineCubit>().loadTimelineEntries();
                }
              },
              builder: (context, state) {
                if (state.status == TimelineStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == TimelineStatus.failure) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? 'Failed to load timeline entries.',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                } else {
                  if (state.timelineEntries.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: constraints.maxHeight * 0.1,
                      ),
                      child: const Center(
                        child: Text('No timeline entries available.'),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.015,
                    ),
                    itemCount: state.timelineEntries.length,
                    itemBuilder: (context, index) {
                      final entry = state.timelineEntries[index];
                      return TimelineEntry(
                        timelineItem: entry,
                        isLast: index == state.timelineEntries.length - 1,
                      );
                    },
                  );
                }
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await context.read<TimelineCubit>().resetAddEntryFields();
            if (context.mounted) {
              Navigator.pushNamed(context, '/addTimelineEntry');
            }
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          tooltip: "Add to Timeline",
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class TimelineEntry extends StatelessWidget {
  final TimelineItem timelineItem;
  final bool isLast;

  const TimelineEntry({
    super.key,
    required this.timelineItem,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.135,
            child: Center(
              child: Text(
                timelineItem.date,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          SizedBox(
            width: 20,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: 5,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Center(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 5,
                      width: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TimelineItemCard(timelineItem: timelineItem),
          ),
        ],
      ),
    );
  }
}

class TimelineItemCard extends StatelessWidget {
  final TimelineItem timelineItem;

  const TimelineItemCard({super.key, required this.timelineItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final file = File(timelineItem.imagePath);
                final exists = await file.exists();

                if (!context.mounted) return;

                if (!exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Image not found at the specified path."),
                    ),
                  );
                  return;
                }

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InteractiveViewer(
                        child: Image.file(
                          file,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: MediaQuery.of(context).size.width * 0.2,
                width: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: timelineItem.imagePath.isNotEmpty
                        ? FileImage(File(timelineItem.imagePath))
                        : const AssetImage('assets/images/sample1.jpg')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timelineItem.dateTitle,
                    style:
                        const TextStyle(fontFamily: 'RetroTitle', fontSize: 24),
                  ),
                  Text(
                    timelineItem.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this timeline entry?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                context
                    .read<TimelineCubit>()
                    .removeTimelineEntry(timelineItem.id);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}
