import 'package:date_spark_app/app_colors.dart';
import 'package:date_spark_app/services/secure_storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

final List<MapEntry<String, ColorScheme>> themes = [
  const MapEntry('popsicle', popsicleColorScheme),
  const MapEntry('berryBliss', berryBlissColorScheme),
  const MapEntry('tropicalSunset', tropicalSunsetColorScheme),
  const MapEntry('midnight', midnightColorScheme),
];

class ThemeCubit extends Cubit<ColorScheme> {
  final SecureStorage _secureStorage = SecureStorage();

  ThemeCubit() : super(popsicleColorScheme) {
    loadSavedTheme();
  }

  Future<void> updateTheme(ColorScheme newTheme) async {
    emit(newTheme);
    await _saveThemePreference(newTheme); // Persist theme
  }

  Future<void> loadSavedTheme() async {
    final themeString =
        await _secureStorage.read(key: 'selectedTheme') ?? 'tropicalSunset';

    final theme = _getThemeFromString(themeString);
    emit(theme);
  }

  ColorScheme _getThemeFromString(String themeString) {
    final theme = themes.firstWhere(
      (entry) => entry.key == themeString,
      orElse: () => const MapEntry('tropicalSunset', tropicalSunsetColorScheme),
    );
    return theme.value;
  }

  Future<void> _saveThemePreference(ColorScheme theme) async {
    final themeString = themes
        .firstWhere(
          (entry) => entry.value == theme,
          orElse: () =>
              const MapEntry('tropicalSunset', tropicalSunsetColorScheme),
        )
        .key;

    await _secureStorage.write(key: 'selectedTheme', value: themeString);
  }
}
