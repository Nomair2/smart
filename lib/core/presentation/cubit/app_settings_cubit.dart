import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings_state.dart';

/// Owns the app's active [Locale] and [ThemeMode]. Lives above
/// `MaterialApp` (see `main.dart`) so it's available before login too —
/// the Welcome/Login screens get dark mode and Arabic for free.
///
/// Theme is local-only by design (a device display preference, like most
/// apps treat it — not synced to Firestore). Locale starts from whatever
/// was cached locally (so it's instant and works offline/pre-login), then
/// [syncLocaleFromProfile] pulls it from the signed-in user's Firestore
/// profile once that loads, so language follows the account across
/// devices the same way `UserProfile.preferredLanguage` already does
/// everywhere else in the Profile feature.
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState()) {
    _loadCached();
  }

  static const _localeKey = 'app_locale';
  static const _themeModeKey = 'app_theme_mode';

  Future<void> _loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedLocale = prefs.getString(_localeKey);
    final cachedThemeMode = prefs.getString(_themeModeKey);
    emit(state.copyWith(
      locale: cachedLocale != null ? Locale(cachedLocale) : null,
      themeMode: cachedThemeMode != null ? _themeModeFromName(cachedThemeMode) : null,
    ));
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == state.locale) return;
    emit(state.copyWith(locale: locale));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state.themeMode) return;
    emit(state.copyWith(themeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  /// Called whenever the signed-in user's profile (re)loads — brings the
  /// app's language in line with the account if it differs from whatever
  /// was cached locally (e.g. first run on a new device).
  void syncLocaleFromProfile(String languageCode) {
    if (languageCode.isNotEmpty && languageCode != state.locale.languageCode) {
      setLocale(Locale(languageCode));
    }
  }

  static ThemeMode? _themeModeFromName(String name) {
    for (final mode in ThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }
}
