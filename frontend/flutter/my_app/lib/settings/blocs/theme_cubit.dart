import 'package:date_spark_app/app_colors.dart';
import 'package:date_spark_app/logger.dart';
import 'package:date_spark_app/services/secure_storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final Logger _log = taggedLogger('ThemeCubit');

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
    _log.info('Theme updated to: ${_getThemeKey(newTheme)}');
    await _saveThemePreference(newTheme); // Persist theme
  }

  Future<void> loadSavedTheme() async {
    try {
      final themeString =
          await _secureStorage.read(key: 'selectedTheme') ?? 'tropicalSunset';
      _log.info('Loaded saved theme string: $themeString');

      final theme = _getThemeFromString(themeString);
      emit(theme);
      _log.info('Emitted theme: ${_getThemeKey(theme)}');
    } catch (e, stackTrace) {
      _log.severe('Failed to load saved theme: $e', e, stackTrace);
    }
  }

  ColorScheme _getThemeFromString(String themeString) {
    final theme = themes.firstWhere(
      (entry) => entry.key == themeString,
      orElse: () => const MapEntry('tropicalSunset', tropicalSunsetColorScheme),
    );
    return theme.value;
  }

  String _getThemeKey(ColorScheme theme) {
    return themes
        .firstWhere(
          (entry) => entry.value == theme,
          orElse: () =>
              const MapEntry('tropicalSunset', tropicalSunsetColorScheme),
        )
        .key;
  }

  Future<void> _saveThemePreference(ColorScheme theme) async {
    final themeString = _getThemeKey(theme);
    try {
      await _secureStorage.write(key: 'selectedTheme', value: themeString);
      _log.info('Saved theme preference: $themeString');
    } catch (e, stackTrace) {
      _log.severe('Failed to save theme preference: $e', e, stackTrace);
    }
  }
}
