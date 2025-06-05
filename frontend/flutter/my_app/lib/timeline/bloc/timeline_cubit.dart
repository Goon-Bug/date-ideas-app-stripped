import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:date_spark_app/services/date_ideas_service.dart';
import 'package:date_spark_app/timeline/models/timeline.dart';
import 'package:date_spark_app/timeline/timeline_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

part 'timeline_state.dart';

class TimelineCubit extends Cubit<TimelineState> {
  final TimelineRepository timelineRepository =
      GetIt.instance<TimelineRepository>();
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  TimelineCubit() : super(const TimelineState()) {
    loadDateIdeas();
  }

  Future<void> loadTimelineEntries() async {
    try {
      log('Loading timeline entries...');
      emit(state.copyWith(status: TimelineStatus.loading));
      final timelineEntries = await timelineRepository.getTimelineEntries();
      log('Successfully loaded timeline entries: ${timelineEntries.length} entries');
      emit(state.copyWith(
        status: TimelineStatus.success,
        timelineEntries: timelineEntries,
      ));
    } catch (error) {
      log('Failed to load timeline entries: $error');
      emit(state.copyWith(
        status: TimelineStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> loadDateIdeas() async {
    try {
      log('Loading date ideas...');

      final dateIdeas = DateIdeasData.instance.dateIdeasMap;

      final rawDateIdeas = dateIdeas.map<Map<String, dynamic>>((entry) {
        return entry;
      }).toList();

      emit(state.copyWith(
        dateIdeaEntries: rawDateIdeas,
      ));

      log('Successfully loaded date ideas: ${rawDateIdeas.length} entries');
    } catch (error) {
      log('Failed to load date ideas: $error');
      emit(state.copyWith(
        errorMessage: error.toString(),
      ));
    }
  }

  Future<String> saveImage(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = '${directory.path}/$imageName';
      final imageBytes = await image.readAsBytes();
      await File(imagePath).writeAsBytes(imageBytes);
      return imagePath;
    } catch (e) {
      log('Failed to save image: $e');
      rethrow;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      updateSelectedImage(image);
    }
  }

  Future<void> updateSelectedImage(File image) async {
    emit(state.copyWith(selectedImage: image));
  }

  Future<void> updateSelectedDate(String date) async {
    emit(state.copyWith(selectedDate: date));
  }

  Future<void> selectDateIdea(Map<String, dynamic> dateIdea) async {
    log('Selecting a Date Idea...');
    emit(state.copyWith(selectedDateIdea: dateIdea));
    log('Selected Date Idea is now ${state.selectedDateIdea}');
  }

  Future<void> resetSelectedDateIdea() async {
    log('Resetting selectedDateIdea to null');
    state.copyWith(selectedDateIdea: null, resetSelectedDateIdea: true);
  }

  Future<void> resetAddEntryFields() async {
    emit(state.copyWith(
      selectedDate: '',
      selectedDateIdea: null,
      resetSelectedDateIdea: true,
      selectedImage: null,
    ));
    log('$state');
  }

  Future<void> addTimelineEntry({
    required String description,
    File? image,
    required String userId,
    required String date,
    required String dateId,
    required String dateTitle,
  }) async {
    try {
      log('Adding new timeline entry...');
      emit(state.copyWith(status: TimelineStatus.loading));

      String imagePath = '';
      if (image != null) {
        imagePath = await saveImage(image);
      }
      final randomId = math.Random().nextInt(100000);

      final newEntry = TimelineItem(
        id: randomId.toString(),
        dateId: dateId,
        imagePath: imagePath,
        description: description,
        userId: userId,
        dateTitle: dateTitle,
        date: date.isNotEmpty
            ? date
            : DateFormat('dd/MM/yyyy').format(DateTime.now()),
      );

      await timelineRepository.addTimelineEntry(newEntry);
      log('Successfully added new timeline entry: $newEntry');

      emit(state.copyWith(
        status: TimelineStatus.added,
        timelineEntries: List.from(state.timelineEntries)..add(newEntry),
      ));
    } catch (error) {
      log('Failed to add new timeline entry: $error');
      emit(state.copyWith(
        status: TimelineStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> removeTimelineEntry(String entryId) async {
    try {
      log('Removing timeline entry with ID: $entryId');
      emit(state.copyWith(status: TimelineStatus.loading));
      await timelineRepository.removeTimelineEntry(entryId);
      log('Successfully removed timeline entry with ID: $entryId');
      emit(state.copyWith(
        status: TimelineStatus.success,
        timelineEntries: state.timelineEntries
            .where((entry) => entry.id != entryId)
            .toList(),
      ));
    } catch (error) {
      log('Failed to remove timeline entry: $error');
      emit(state.copyWith(
        status: TimelineStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void resetErrorMessage() {
    log('Resetting error message');
    emit(state.copyWith(errorMessage: null));
  }

  void clearTimeline() {
    emit(const TimelineState());
  }
}
