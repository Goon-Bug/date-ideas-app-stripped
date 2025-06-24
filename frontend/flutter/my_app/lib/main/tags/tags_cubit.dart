import 'package:bloc/bloc.dart';
import 'package:date_spark_app/logger.dart';
import 'package:logging/logging.dart';

final Logger _log = taggedLogger('TagsCubit');

class TagsCubit extends Cubit<Map<String, bool>> {
  TagsCubit(List<String> tagNames)
      : super({for (var tag in tagNames) tag: false}) {
    _log.fine('Initialized with tags: ${tagNames.join(', ')}');
  }

  void toggleTag(String tag) {
    final newState = {...state, tag: !(state[tag] ?? false)};
    _log.fine('Toggled tag "$tag" to ${newState[tag]}');
    emit(newState);
  }

  void resetTags() {
    _log.fine('Resetting all tags to false');
    emit({for (var tag in state.keys) tag: false});
  }
}
