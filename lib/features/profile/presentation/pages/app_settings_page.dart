import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/cubit/app_settings_cubit.dart';
import '../../../../core/presentation/cubit/app_settings_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/section_label.dart';
import '../widgets/settings_tile.dart';

/// Reached from the "App Settings" tile. `ProfileCubit` and
/// `AppSettingsCubit` are both provided once in `main.dart`, above
/// `MaterialApp`, so no special wrapping is needed to reach them from a
/// pushed route — see the comment on that tile in `profile_page.dart`.
///
/// Language and Voice Guidance are real, Firestore-backed preferences
/// (`UserProfile.preferredLanguage` / `voiceEnabled`, via
/// `ProfileCubit.updatePreferences`) — picking a language here updates
/// both the account (so it follows the user across devices) and the
/// app's live `Locale` immediately (via `AppSettingsCubit`, no waiting
/// on the Firestore round-trip). Theme is real too, but local-only by
/// design — see `AppSettingsCubit`'s doc comment for why.
class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  static const Color primaryGreen = Color(0xFF1E5B3D);

  static const _languages = [
    _LanguageOption(code: 'en', label: 'English'),
    _LanguageOption(code: 'ar', label: 'العربية (Arabic)'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appSettingsTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final profile = state.profile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final cubit = context.read<ProfileCubit>();
          final currentLanguage = _languages.firstWhere(
            (l) => l.code == profile.preferredLanguage,
            orElse: () => _languages.first,
          );

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                SectionLabel(l10n.sectionLanguageVoice),
                SettingsTile(
                  icon: Icons.translate_rounded,
                  iconColor: const Color(0xFF4C6FE0),
                  iconBg: const Color(0xFFEAEEFD),
                  title: l10n.appLanguage,
                  subtitle: currentLanguage.label,
                  onTap: () => _pickLanguage(context, cubit, profile.preferredLanguage),
                ),
                SettingsTile(
                  icon: Icons.record_voice_over_rounded,
                  iconColor: primaryGreen,
                  iconBg: const Color(0xFFEAF3EE),
                  title: l10n.voiceGuidance,
                  subtitle: profile.voiceEnabled ? l10n.voiceGuidanceOn : l10n.voiceGuidanceOff,
                  trailing: Switch(
                    value: profile.voiceEnabled,
                    activeColor: primaryGreen,
                    onChanged: (value) => cubit.updatePreferences(voiceEnabled: value),
                  ),
                  onTap: () => cubit.updatePreferences(voiceEnabled: !profile.voiceEnabled),
                ),
                SectionLabel(l10n.sectionAppearance),
                const _ThemeTile(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _pickLanguage(BuildContext context, ProfileCubit cubit, String currentCode) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text(l10n.appLanguage, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              ..._languages.map(
                (lang) => RadioListTile<String>(
                  value: lang.code,
                  groupValue: currentCode,
                  activeColor: primaryGreen,
                  title: Text(lang.label),
                  onChanged: (value) {
                    if (value != null) {
                      // Firestore (cross-device source of truth)...
                      cubit.updatePreferences(preferredLanguage: value);
                      // ...and the live app locale, immediately — don't
                      // wait on the Firestore snapshot round-trip for the
                      // UI to actually switch language/direction.
                      context.read<AppSettingsCubit>().setLocale(Locale(value));
                    }
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageOption {
  const _LanguageOption({required this.code, required this.label});
  final String code;
  final String label;
}

/// Local-only theme preference, hooked to the real [AppSettingsCubit] —
/// see that class's doc comment for why theme doesn't go through
/// Firestore the way language does.
class _ThemeTile extends StatelessWidget {
  const _ThemeTile();

  static const Color primaryGreen = Color(0xFF1E5B3D);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, settings) {
        return SettingsTile(
          icon: Icons.dark_mode_outlined,
          iconColor: Colors.grey[700]!,
          iconBg: const Color(0xFFF1F3F2),
          title: l10n.theme,
          subtitle: _label(l10n, settings.themeMode),
          onTap: () => _openPicker(context, l10n),
        );
      },
    );
  }

  String _label(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeSystem;
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
    }
  }

  void _openPicker(BuildContext context, AppLocalizations l10n) {
    final cubit = context.read<AppSettingsCubit>();
    final current = cubit.state.themeMode;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        final options = [
          (ThemeMode.system, l10n.themeSystem),
          (ThemeMode.light, l10n.themeLight),
          (ThemeMode.dark, l10n.themeDark),
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text(l10n.theme, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              ...options.map(
                (option) => RadioListTile<ThemeMode>(
                  value: option.$1,
                  groupValue: current,
                  activeColor: primaryGreen,
                  title: Text(option.$2),
                  onChanged: (value) {
                    if (value != null) cubit.setThemeMode(value);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
