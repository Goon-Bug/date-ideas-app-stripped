import 'dart:async';
import 'dart:math';
import 'dart:developer' as dl;
import 'package:bloc/bloc.dart';
import 'package:date_spark_app/main/bloc/dates_scroller_state.dart';
import 'package:date_spark_app/services/date_ideas_service.dart';
import 'package:equatable/equatable.dart';

part 'dates_scroller_event.dart';

class DatesScrollerBloc extends Bloc<DatesScrollerEvent, DatesScrollerState> {
  List<Map<String, dynamic>> _dateIdeas = [];

  DatesScrollerBloc()
      : super(DatesScrollerIdle(DateIdeasData.instance.dateIdeasMap)) {
    _dateIdeas = List.from(DateIdeasData.instance.dateIdeasMap);
    on<DatesScrollerSpinRequested>(_onSpinRequested);
    on<DatesScrollerResetRequested>(_onResetRequested);
    on<DatesFilterRequested>(_onFilterRequested);
    on<DatesTagsReset>(_onTagsResetRequested);
    on<DatesPackSelected>(_onPackSelected);
  }

  Future<void> _onPackSelected(
    DatesPackSelected event,
    Emitter<DatesScrollerState> emit,
  ) async {
    dl.log('Received DatesPackSelected: ${event.packName}');

    final allDateIdeas = DateIdeasData.instance.dateIdeasMapOriginal;

    List<Map<String, dynamic>> filteredIdeas;

    if (event.packName == 'all') {
      // If 'all' is selected, show all date ideas without filtering
      filteredIdeas = List.from(allDateIdeas);
    } else {
      // Otherwise filter by pack name
      filteredIdeas =
          allDateIdeas.where((idea) => idea['pack'] == event.packName).toList();
    }

    _dateIdeas = List.from(filteredIdeas);

    dl.log('Filtered Ideas Count: ${filteredIdeas.length}');

    emit(DatesScrollerFiltered(
        filteredIdeas.isNotEmpty, List.from(filteredIdeas)));
  }

  Future<void> _onSpinRequested(
    DatesScrollerSpinRequested event,
    Emitter<DatesScrollerState> emit,
  ) async {
    emit(DatesScrollerSpinning(_dateIdeas));

    final random = Random();
    if (_dateIdeas.isEmpty) return;

    final randomIndex = random.nextInt(_dateIdeas.length);
    const fullRotations = 1;
    const itemHeight = 50.0;
    final totalItems = _dateIdeas.length;
    final rotationDistance = fullRotations * totalItems * itemHeight;
    final targetPosition = rotationDistance + ((randomIndex + 2) * itemHeight);

    emit(DatesScrollerSpinTo(targetPosition, _dateIdeas));
    await Future.delayed(const Duration(seconds: 2));

    final selectedIdea = _dateIdeas[randomIndex];
    emit(DatesScrollerResult(selectedIdea, _dateIdeas));
  }

  void _onResetRequested(
    DatesScrollerResetRequested event,
    Emitter<DatesScrollerState> emit,
  ) {
    _dateIdeas = List.from(DateIdeasData.instance.dateIdeasMapOriginal);
    dl.log('Resetting to original date ideas count: ${_dateIdeas.length}');
    emit(DatesScrollerIdle(_dateIdeas));
  }

  void _onTagsResetRequested(
    DatesTagsReset event,
    Emitter<DatesScrollerState> emit,
  ) {
    _dateIdeas = List.from(DateIdeasData.instance.dateIdeasMap);
    dl.log('Resetting date ideas count: ${_dateIdeas.length}');
    emit(DatesScrollerIdle(_dateIdeas));
  }

  void _onFilterRequested(
    DatesFilterRequested event,
    Emitter<DatesScrollerState> emit,
  ) {
    dl.log('Received DatesFilterRequested: ${event.tags}');

    final allDateIdeas = List.from(DateIdeasData.instance.dateIdeasMap);

    final filteredIdeas = allDateIdeas
        .where((idea) =>
            event.tags.every((tag) => idea['tags']?.contains(tag) ?? false))
        .toList();

    _dateIdeas = List.from(filteredIdeas);

    dl.log('Filtered Ideas Count: ${filteredIdeas.length}');

    emit(DatesScrollerFiltered(
        filteredIdeas.isNotEmpty, List.from(filteredIdeas)));
  }
}
