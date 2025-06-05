part of 'timeline_cubit.dart';

enum TimelineStatus { initial, loading, success, failure, added }

class TimelineState extends Equatable {
  final TimelineStatus status;
  final List<TimelineItem> timelineEntries;
  final String? errorMessage;
  final File? selectedImage;
  final String description;
  final String selectedDate;
  final Map<String, dynamic>? selectedDateIdea;
  final List<Map<String, dynamic>> dateIdeaEntries;

  const TimelineState({
    this.status = TimelineStatus.initial,
    this.timelineEntries = const [],
    this.errorMessage,
    this.selectedImage,
    this.description = '',
    this.selectedDate = '',
    this.selectedDateIdea,
    this.dateIdeaEntries = const [],
  });

  TimelineState copyWith({
    TimelineStatus? status,
    List<TimelineItem>? timelineEntries,
    String? errorMessage,
    File? selectedImage,
    String? selectedDate,
    Map<String, dynamic>? selectedDateIdea,
    bool resetSelectedDateIdea = false,
    List<Map<String, dynamic>>? dateIdeaEntries,
  }) {
    return TimelineState(
      status: status ?? this.status,
      timelineEntries: timelineEntries ?? this.timelineEntries,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedImage: selectedImage ?? this.selectedImage,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDateIdea: resetSelectedDateIdea
          ? null
          : selectedDateIdea ?? this.selectedDateIdea,
      dateIdeaEntries: dateIdeaEntries ?? this.dateIdeaEntries,
    );
  }

  @override
  List<Object?> get props => [
        status,
        timelineEntries,
        errorMessage,
        selectedImage,
        selectedDate,
        selectedDateIdea,
        dateIdeaEntries,
      ];

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
}
