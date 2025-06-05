import 'dart:developer';
import 'package:date_spark_app/services/date_ideas_service.dart';
import 'package:date_spark_app/timeline/bloc/timeline_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AddTimelineEntryPage extends StatelessWidget {
  const AddTimelineEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddTimelineEntryForm();
  }
}

class AddTimelineEntryForm extends StatelessWidget {
  const AddTimelineEntryForm({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController searchController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Add Timeline Entry')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: BlocBuilder<TimelineCubit, TimelineState>(
              builder: (context, state) {
                log('Selected Date Idea UI: ${state.selectedDateIdea}');
                if (state.status == TimelineStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.hasError) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? 'An error occurred',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                log('Selected Date Idea: ${state.selectedDateIdea}');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Searchable Dropdown
                    SizedBox(
                      height: 60,
                      child: DropdownButtonFormField2<Map<String, dynamic>>(
                        isExpanded: true,
                        value: state.selectedDateIdea,
                        onChanged: (dateIdea) async {
                          await context
                              .read<TimelineCubit>()
                              .selectDateIdea(dateIdea!);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a Date Idea';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Select the Date that you went on',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                        ),
                        dropdownSearchData: DropdownSearchData(
                          searchController: searchController,
                          searchInnerWidgetHeight: 50,
                          searchInnerWidget: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search date ideas...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          searchMatchFn: (item, searchValue) {
                            return item.value!['title']
                                .toString()
                                .toLowerCase()
                                .contains(searchValue.toLowerCase());
                          },
                        ),
                        items: DateIdeasData.instance.dateIdeasMap
                            .map((dateIdea) =>
                                DropdownMenuItem<Map<String, dynamic>>(
                                  value: dateIdea,
                                  child: Text(
                                    dateIdea['title'] ?? 'No Title',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description Field
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Image Picker
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Pick an image from your date:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        context.read<TimelineCubit>().pickImage();
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: state.selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(state.selectedImage!),
                                  fit: BoxFit.scaleDown,
                                )
                              : const DecorationImage(
                                  image: AssetImage(
                                      'assets/images/lightbulb_logo.png'),
                                  fit: BoxFit.scaleDown,
                                ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date Picker
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller:
                                TextEditingController(text: state.selectedDate),
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a Date';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Select Date',
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              border: InputBorder.none,
                            ),
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null && context.mounted) {
                                context
                                    .read<TimelineCubit>()
                                    .updateSelectedDate(DateFormat('yyyy-MM-dd')
                                        .format(pickedDate));
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null && context.mounted) {
                              context.read<TimelineCubit>().updateSelectedDate(
                                  DateFormat('yyyy-MM-dd').format(pickedDate));
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 20),
                    Center(
                        child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          await context.read<TimelineCubit>().addTimelineEntry(
                                description: descriptionController.text,
                                image: state.selectedImage,
                                userId:
                                    'Delete this field!', // TODO: Delete this field
                                date: state.selectedDate,
                                dateId:
                                    state.selectedDateIdea?['id'].toString() ??
                                        '',
                                dateTitle:
                                    state.selectedDateIdea?['title'] ?? '',
                              );
                          if (context.mounted) {
                            Navigator.pop(context);
                            await context
                                .read<TimelineCubit>()
                                .resetAddEntryFields();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Add Entry',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ))
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
