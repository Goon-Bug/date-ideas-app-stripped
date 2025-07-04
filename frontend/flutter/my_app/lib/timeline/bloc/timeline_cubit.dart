import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:date_spark_app/logger.dart';
import 'package:date_spark_app/services/date_ideas_service.dart';
import 'package:date_spark_app/timeline/models/timeline.dart';
import 'package:date_spark_app/timeline/timeline_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

part 'timeline_state.dart';

final Logger _log = taggedLogger('TimelineCubit');

class TimelineCubit extends Cubit<TimelineState> {
  final TimelineRepository timelineRepository =
      GetIt.instance<TimelineRepository>();
  final ImagePicker _picker = ImagePicker();

  TimelineCubit() : super(const TimelineState()) {
    loadDateIdeas();
  }

  Future<void> loadTimelineEntries() async {
    try {
      _log.info('Loading timeline entries...');
      emit(state.copyWith(status: TimelineStatus.loading));
      final timelineEntries = await timelineRepository.getTimelineEntries();
      _log.info(
          'Successfully loaded timeline entries: ${timelineEntries.length} entries');
      emit(state.copyWith(
        status: TimelineStatus.success,
        timelineEntries: timelineEntries,
      ));
    } catch (error, stackTrace) {
      _log.severe('Failed to load timeline entries', error, stackTrace);
      emit(state.copyWith(
        status: TimelineStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> loadDateIdeas() async {
    try {
      _log.info('Loading date ideas...');
      final dateIdeas = DateIdeasData.instance.dateIdeasMap;
      final rawDateIdeas = dateIdeas.map<Map<String, dynamic>>((entry) {
        return entry;
      }).toList();
      emit(state.copyWith(dateIdeaEntries: rawDateIdeas));
      _log.info(
          'Successfully loaded date ideas: ${rawDateIdeas.length} entries');
    } catch (error, stackTrace) {
      _log.severe('Failed to load date ideas', error, stackTrace);
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<String> saveImage(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = '${directory.path}/$imageName';
      final imageBytes = await image.readAsBytes();
      await File(imagePath).writeAsBytes(imageBytes);
      _log.info('Image saved at path: $imagePath');
      return imagePath;
    } catch (e, stackTrace) {
      _log.severe('Failed to save image', e, stackTrace);
      rethrow;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      _log.info('Image picked: ${pickedFile.path}');
      updateSelectedImage(image);
    } else {
      _log.info('No image picked.');
    }
  }

  Future<void> updateSelectedImage(File image) async {
    _log.info('Updating selected image');
    emit(state.copyWith(selectedImage: image));
  }

  Future<void> updateSelectedDate(String date) async {
    _log.info('Updating selected date: $date');
    emit(state.copyWith(selectedDate: date));
  }

  Future<void> selectDateIdea(Map<String, dynamic> dateIdea) async {
    _log.info('Selecting a Date Idea: $dateIdea');
    emit(state.copyWith(selectedDateIdea: dateIdea));
    _log.info('Selected Date Idea is now ${state.selectedDateIdea}');
  }

  Future<void> resetSelectedDateIdea() async {
    _log.info('Resetting selectedDateIdea to null');
    emit(state.copyWith(selectedDateIdea: null, resetSelectedDateIdea: true));
  }

  Future<void> resetAddEntryFields() async {
    _log.info('Resetting add entry fields');

    emit(state.copyWith(
      selectedDate: '',
      selectedDateIdea: {},
      resetSelectedDateIdea: true,
      resetSelectedImage: true,
      selectedImage: null,
    ));
  }

  Future<void> addTimelineEntry({
    required String description,
    File? image,
    required String date,
    required String dateId,
    required String dateTitle,
  }) async {
    try {
      _log.info('Adding new timeline entry...');
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
        dateTitle: dateTitle,
        date: date.isNotEmpty
            ? date
            : DateFormat('dd/MM/yyyy').format(DateTime.now()),
      );

      await timelineRepository.addTimelineEntry(newEntry);
      _log.info('Successfully added new timeline entry: $newEntry');

      emit(state.copyWith(
        status: TimelineStatus.added,
        timelineEntries: List.from(state.timelineEntries)..add(newEntry),
      ));
    } catch (error, stackTrace) {
      _log.severe('Failed to add new timeline entry', error, stackTrace);
      emit(state.copyWith(
        status: TimelineStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> removeTimelineEntry(String entryId) async {
    try {
      _log.info('Removing timeline entry with ID: $entryId');
      emit(state.copyWith(status: TimelineStatus.loading));
      await timelineRepository.removeTimelineEntry(entryId);
      _log.info('Successfully removed timeline entry with ID: $entryId');
      emit(state.copyWith(
        status: TimelineStatus.success,
        timelineEntries: state.timelineEntries
            .where((entry) => entry.id != entryId)
            .toList(),
      ));
    } catch (error, stackTrace) {
      _log.severe('Failed to remove timeline entry', error, stackTrace);
      emit(state.copyWith(
        status: TimelineStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> updateTimelineEntry({
    required String id,
    String? newDescription,
    String? newImagePath,
    String? newDate,
  }) async {
    try {
      _log.info('Updating timeline entry ID: $id');
      emit(state.copyWith(status: TimelineStatus.loading));

      final index = state.timelineEntries.indexWhere((entry) => entry.id == id);
      if (index == -1) throw Exception('Timeline entry not found');

      final oldEntry = state.timelineEntries[index];
      final updatedEntry = oldEntry.copyWith(
        description: newDescription ?? oldEntry.description,
        imagePath: newImagePath ?? oldEntry.imagePath,
        date: newDate ?? oldEntry.date,
      );

      await timelineRepository.updateTimelineEntry(updatedEntry);

      final updatedEntries = List<TimelineItem>.from(state.timelineEntries)
        ..[index] = updatedEntry;

      _log.info('Successfully updated entry ID: $id');

      emit(state.copyWith(
        status: TimelineStatus.success,
        timelineEntries: updatedEntries,
      ));
    } catch (error, stackTrace) {
      _log.severe('Failed to update timeline entry', error, stackTrace);
      emit(state.copyWith(
        status: TimelineStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void resetErrorMessage() {
    _log.info('Resetting error message');
    emit(state.copyWith(errorMessage: null));
  }

  void clearTimeline() {
    _log.info('Clearing timeline state');
    emit(const TimelineState());
  }
}
