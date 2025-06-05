import 'package:formz/formz.dart';

enum PasswordVerifyValidationError {
  empty,
  noMatch,
}

class PasswordVerification
    extends FormzInput<String, PasswordVerifyValidationError> {
  final String password;

  const PasswordVerification.pure({this.password = ''}) : super.pure('');
  const PasswordVerification.dirty({required this.password, String value = ''})
      : super.dirty(value);

  @override
  PasswordVerifyValidationError? validator(String value) {
    if (value.isEmpty) return PasswordVerifyValidationError.empty;
    if (value != password) return PasswordVerifyValidationError.noMatch;
    return null;
  }

  static String? getErrorMessage(PasswordVerifyValidationError? error) {
    switch (error) {
      case PasswordVerifyValidationError.empty:
        return 'Field cannot be empty';
      case PasswordVerifyValidationError.noMatch:
        return 'Passwords do not match';
      default:
        return null;
    }
  }
}
