part of 'dates_scroller_bloc.dart';

abstract class DatesScrollerEvent extends Equatable {
  const DatesScrollerEvent();

  @override
  List<Object?> get props => [];
}

class DatesScrollerSpinRequested extends DatesScrollerEvent {}

class DatesFilterRequested extends DatesScrollerEvent {
  final List<String> tags;

  const DatesFilterRequested(this.tags);

  @override
  List<Object> get props => [tags];
}

class DatesScrollerResetRequested extends DatesScrollerEvent {}

class DatesTagsReset extends DatesScrollerEvent {}

class DatesPackSelected extends DatesScrollerEvent {
  final String packName;

  const DatesPackSelected(this.packName);

  @override
  List<Object> get props => [packName];
}
