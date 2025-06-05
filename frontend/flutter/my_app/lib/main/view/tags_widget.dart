import 'dart:developer';

import 'package:date_spark_app/main/bloc/dates_scroller_bloc.dart';
import 'package:date_spark_app/main/tags/tags_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TagsCheckboxGrid extends StatelessWidget {
  final List<String> tagNames;
  final bool enabled; // NEW

  const TagsCheckboxGrid({
    super.key,
    required this.tagNames,
    this.enabled = true, // NEW
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Tags',
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: BlocBuilder<TagsCubit, Map<String, bool>>(
          builder: (context, selectedTags) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 3,
                childAspectRatio: 2.5,
              ),
              itemCount: tagNames.length,
              itemBuilder: (context, index) {
                final tag = tagNames[index];
                final isSelected = selectedTags[tag] ?? false;

                return GestureDetector(
                  onTap: enabled
                      ? () {
                          final tagsCubit = context.read<TagsCubit>();
                          tagsCubit.toggleTag(tag);

                          final updatedSelectedTags = tagsCubit.state.entries
                              .where((entry) => entry.value)
                              .map((entry) => entry.key.toLowerCase())
                              .toList();

                          log('Dispatching DatesFilterRequested with: $updatedSelectedTags');

                          context.read<DatesScrollerBloc>().add(
                                updatedSelectedTags.isNotEmpty
                                    ? DatesFilterRequested(updatedSelectedTags)
                                    : DatesScrollerResetRequested(),
                              );

                          log('Updated Filters: $updatedSelectedTags');
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                    padding: const EdgeInsets.only(left: 2),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IgnorePointer(
                          ignoring: !enabled, // disables checkbox
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (isChecked) {
                              final tagsCubit = context.read<TagsCubit>();
                              tagsCubit.toggleTag(tag);

                              final updatedSelectedTags = tagsCubit
                                  .state.entries
                                  .where((entry) => entry.value)
                                  .map((entry) => entry.key.toLowerCase())
                                  .toList();

                              context.read<DatesScrollerBloc>().add(
                                    updatedSelectedTags.isNotEmpty
                                        ? DatesFilterRequested(
                                            updatedSelectedTags)
                                        : DatesScrollerResetRequested(),
                                  );

                              log('Updated Filters: $updatedSelectedTags');
                            },
                            activeColor: Colors.white,
                            checkColor: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
