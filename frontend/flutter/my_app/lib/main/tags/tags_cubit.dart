import 'package:bloc/bloc.dart';

class TagsCubit extends Cubit<Map<String, bool>> {
  TagsCubit(List<String> tagNames)
      : super({for (var tag in tagNames) tag: false});

  void toggleTag(String tag) {
    emit({...state, tag: !(state[tag] ?? false)});
  }

  void resetTags() {
    emit({for (var tag in state.keys) tag: false});
  }
}
