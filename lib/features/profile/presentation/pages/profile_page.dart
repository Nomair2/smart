import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/widgets/season_mode_picker.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/section_label.dart';
import '../widgets/settings_tile.dart';
import '../widgets/stat_card.dart';
import 'app_settings_page.dart';
import 'help_support_page.dart';
import 'notification_settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color primaryGreen = Color(0xFF1E5B3D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          if (state.status == ProfileStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? l10n.couldNotLoadProfile,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final profile = state.profile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final cubit = context.read<ProfileCubit>();
          return SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeader(
                      profile: profile,
                      onEditTap: () =>
                          _editPersonalInfo(context, cubit, profile),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              StatCard(
                                emoji: '📖',
                                value: '${profile.routesCount}',
                                label: l10n.statRoutes,
                              ),
                              const SizedBox(width: 10),
                              StatCard(
                                emoji: '🚶',
                                value: profile.kmWalkedTotal.toStringAsFixed(1),
                                label: l10n.statKmWalked,
                              ),
                              const SizedBox(width: 10),
                              StatCard(
                                emoji: '⭐',
                                value: '${profile.savedRoutesCount}',
                                label: l10n.statSaved,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.mail_outline_rounded,
                                  size: 18,
                                  color: primaryGreen,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.universityEmail,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      Text(
                                        profile.universityEmail,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (profile.isEmailVerified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF3EE),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      l10n.verified,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SectionLabel(l10n.sectionAccount),
                          SettingsTile(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF4C6FE0),
                            iconBg: const Color(0xFFEAEEFD),
                            title: l10n.personalInformation,
                            subtitle: l10n.personalInformationSubtitle,
                            onTap: () =>
                                _editPersonalInfo(context, cubit, profile),
                          ),
                          SettingsTile(
                            icon: Icons.menu_book_rounded,
                            iconColor: const Color(0xFF7B4CE0),
                            iconBg: const Color(0xFFF1EAFD),
                            title: l10n.academicDetails,
                            subtitle: l10n.academicDetailsSubtitle,
                            onTap: () =>
                                _editAcademicDetails(context, cubit, profile),
                          ),
                          SectionLabel(l10n.sectionNavigation),
                          // SettingsTile(
                          //   icon: Icons.map_rounded,
                          //   iconColor: primaryGreen,
                          //   iconBg: const Color(0xFFEAF3EE),
                          //   title: 'My Saved Routes',
                          //   subtitle:
                          //       '${profile.savedRoutesCount} routes saved',
                          //   onTap: () {
                          //     // TODO: navigate to the saved routes list once
                          //     // the routing feature exists.
                          //   },
                          // ),
                          SettingsTile(
                            icon: Icons.wb_sunny_rounded,
                            iconColor: const Color(0xFFE0A83C),
                            iconBg: const Color(0xFFFDF6E3),
                            title: l10n.seasonPreferences,
                            subtitle: l10n.seasonModeActive(profile.defaultSeasonMode.label),
                            onTap: () => showSeasonModePicker(
                              context,
                              current: profile.defaultSeasonMode,
                              onSelected: cubit.updateDefaultSeasonMode,
                            ),
                          ),
                          SectionLabel(l10n.sectionApp),
                          SettingsTile(
                            icon: Icons.notifications_none_rounded,
                            iconColor: const Color(0xFFE0574C),
                            iconBg: const Color(0xFFFDEBEA),
                            title: l10n.notificationSettings,
                            subtitle: l10n.notificationSettingsSubtitle,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const NotificationSettingsPage(),
                              ),
                            ),
                          ),
                          SettingsTile(
                            icon: Icons.settings_outlined,
                            iconColor: Colors.grey[700]!,
                            iconBg: const Color(0xFFF1F3F2),
                            title: l10n.appSettings,
                            subtitle: l10n.appSettingsSubtitle,
                            // Plain push now — ProfileCubit is provided once
                            // in main.dart, above MaterialApp, so it's
                            // already in scope for every pushed route. No
                            // BlocProvider.value carry-over needed anymore.
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AppSettingsPage()),
                            ),
                          ),
                          SettingsTile(
                            icon: Icons.help_outline_rounded,
                            iconColor: const Color(0xFF2FA7A7),
                            iconBg: const Color(0xFFE6F5F5),
                            title: l10n.helpSupport,
                            subtitle: l10n.helpSupportSubtitle,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HelpSupportPage(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => _logout(context),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: Text(l10n.logout),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFDEBEA),
                                foregroundColor: const Color(0xFFE0574C),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
  }

  Future<void> _logout(BuildContext context) async {
    await fb.FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  void _editPersonalInfo(
    BuildContext context,
    ProfileCubit cubit,
    UserProfile profile,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: profile.fullName);
    final phoneController = TextEditingController(text: profile.phone ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.personalInformation,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.fullName),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.phoneOptional),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  cubit.updatePersonalInfo(
                    fullName: name,
                    phone: phoneController.text.trim().isEmpty
                        ? null
                        : phoneController.text.trim(),
                  );
                  Navigator.of(sheetContext).pop();
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editAcademicDetails(
    BuildContext context,
    ProfileCubit cubit,
    UserProfile profile,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final collegeController = TextEditingController(text: profile.college);
    String? selectedYear = profile.academicYear;
    final years = l10n.academicYears;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.academicDetails,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: collegeController,
                    decoration: InputDecoration(labelText: l10n.collegeMajor),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedYear,
                    decoration: InputDecoration(labelText: l10n.year),
                    items: years
                        .map(
                          (year) =>
                              DropdownMenuItem(value: year, child: Text(year)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setSheetState(() => selectedYear = value),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      final college = collegeController.text.trim();
                      if (college.isEmpty) return;
                      cubit.updateAcademicDetails(
                        college: college,
                        academicYear: selectedYear,
                      );
                      Navigator.of(sheetContext).pop();
                    },
                    child: Text(l10n.save),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
