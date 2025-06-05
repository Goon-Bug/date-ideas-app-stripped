import 'package:formz/formz.dart';

enum UsernameValidationError {
  empty,
  tooShort,
  tooLong,
  containsSpaces,
}

class Username extends FormzInput<String, UsernameValidationError> {
  const Username.pure() : super.pure('');
  const Username.dirty([super.value = '']) : super.dirty();

  static String? getErrorMessage(UsernameValidationError? error) {
    switch (error) {
      case UsernameValidationError.empty:
        return 'Username cannot be empty';
      case UsernameValidationError.tooShort:
        return 'Username must be more than 4 characters long';
      case UsernameValidationError.tooLong:
        return 'Username must be at most 15 characters long';
      case UsernameValidationError.containsSpaces:
        return 'Username must not contain spaces';
      default:
        return null;
    }
  }

  @override
  UsernameValidationError? validator(String value) {
    if (value.isEmpty) return UsernameValidationError.empty;
    if (value.length <= 4) return UsernameValidationError.tooShort;
    if (value.length > 15) return UsernameValidationError.tooLong;
    if (value.contains(' ')) return UsernameValidationError.containsSpaces;
    return null;
  }
}
