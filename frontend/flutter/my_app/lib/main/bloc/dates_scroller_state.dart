import 'package:equatable/equatable.dart';

abstract class DatesScrollerState extends Equatable {
  final List<Map<String, dynamic>> dateIdeas;

  const DatesScrollerState(this.dateIdeas);

  @override
  List<Object> get props => [dateIdeas];
}

class DatesScrollerResetRequested extends DatesScrollerState {
  const DatesScrollerResetRequested(super.dateIdeas);

  @override
  List<Object> get props => [dateIdeas];
}

class DatesScrollerIdle extends DatesScrollerState {
  const DatesScrollerIdle(super.dateIdeas);
}

class DatesScrollerSpinning extends DatesScrollerState {
  const DatesScrollerSpinning(super.dateIdeas);
}

class DatesScrollerSpinTo extends DatesScrollerState {
  final double position;

  const DatesScrollerSpinTo(this.position, List<Map<String, dynamic>> dateIdeas)
      : super(dateIdeas);

  @override
  List<Object> get props => [position, dateIdeas];
}

class DatesScrollerResult extends DatesScrollerState {
  final Map<String, dynamic> selectedDateIdea;

  const DatesScrollerResult(
      this.selectedDateIdea, List<Map<String, dynamic>> dateIdeas)
      : super(dateIdeas);

  @override
  List<Object> get props => [selectedDateIdea, dateIdeas];
}

class DatesScrollerFiltered extends DatesScrollerState {
  final bool isFiltered;

  const DatesScrollerFiltered(
      this.isFiltered, List<Map<String, dynamic>> dateIdeas)
      : super(dateIdeas);

  @override
  List<Object> get props => [isFiltered, dateIdeas];
}

class DatesPackSelected extends DatesScrollerState {
  final String packName;

  const DatesPackSelected(this.packName, List<Map<String, dynamic>> dateIdeas)
      : super(dateIdeas);

  @override
  List<Object> get props => [packName, dateIdeas];
}
