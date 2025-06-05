import 'package:formz/formz.dart';

enum PasswordValidationError {
  empty,
  tooShort,
  tooLong,
  noUppercase,
  noNumber,
  noSpecialChar
}

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  static String? getErrorMessage(PasswordValidationError? error) {
    switch (error) {
      case PasswordValidationError.empty:
        return 'Password cannot be empty';
      case PasswordValidationError.tooShort:
        return 'Password must be at least 8 characters long';
      case PasswordValidationError.tooLong:
        return 'Password must not be more than 20 characters long';
      case PasswordValidationError.noUppercase:
        return 'Password must contain at least one uppercase letter';
      case PasswordValidationError.noNumber:
        return 'Password must contain at least one number';
      case PasswordValidationError.noSpecialChar:
        return 'Password must contain at least one special character (!@#\$&*~)';
      default:
        return null;
    }
  }

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (value.length < 8) return PasswordValidationError.tooShort;
    if (value.length > 20) return PasswordValidationError.tooLong;
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return PasswordValidationError.noUppercase;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return PasswordValidationError.noNumber;
    }
    if (!value.contains(RegExp(r'[!@#\$&*~-]'))) {
      return PasswordValidationError.noSpecialChar;
    }
    return null;
  }
}
