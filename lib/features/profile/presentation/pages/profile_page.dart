import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../../../core/presentation/widgets/season_mode_picker.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/section_label.dart';
import '../widgets/settings_tile.dart';
import '../widgets/stat_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color primaryGreen = Color(0xFF1E5B3D);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(context.read<ProfileRepository>()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage ?? 'Could not load your profile.',
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
                      onEditTap: () => _editPersonalInfo(context, cubit, profile),
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
                                label: 'Routes',
                              ),
                              const SizedBox(width: 10),
                              StatCard(
                                emoji: '🚶',
                                value: profile.kmWalkedTotal.toStringAsFixed(1),
                                label: 'km Walked',
                              ),
                              const SizedBox(width: 10),
                              StatCard(
                                emoji: '⭐',
                                value: '${profile.savedRoutesCount}',
                                label: 'Saved',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F8F7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.mail_outline_rounded, size: 18, color: primaryGreen),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('University Email',
                                          style: TextStyle(fontSize: 11.5, color: Colors.grey[500])),
                                      Text(profile.universityEmail,
                                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                if (profile.isEmailVerified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF3EE),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Verified',
                                        style: TextStyle(
                                            fontSize: 11, color: primaryGreen, fontWeight: FontWeight.w600)),
                                  ),
                              ],
                            ),
                          ),
                          const SectionLabel('Account'),
                          SettingsTile(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF4C6FE0),
                            iconBg: const Color(0xFFEAEEFD),
                            title: 'Personal Information',
                            subtitle: 'Name, email, phone',
                            onTap: () => _editPersonalInfo(context, cubit, profile),
                          ),
                          SettingsTile(
                            icon: Icons.menu_book_rounded,
                            iconColor: const Color(0xFF7B4CE0),
                            iconBg: const Color(0xFFF1EAFD),
                            title: 'Academic Details',
                            subtitle: 'College, major, year',
                            onTap: () => _editAcademicDetails(context, cubit, profile),
                          ),
                          const SectionLabel('Navigation'),
                          SettingsTile(
                            icon: Icons.map_rounded,
                            iconColor: primaryGreen,
                            iconBg: const Color(0xFFEAF3EE),
                            title: 'My Saved Routes',
                            subtitle: '${profile.savedRoutesCount} routes saved',
                            onTap: () {
                              // TODO: navigate to the saved routes list once
                              // the routing feature exists.
                            },
                          ),
                          SettingsTile(
                            icon: Icons.wb_sunny_rounded,
                            iconColor: const Color(0xFFE0A83C),
                            iconBg: const Color(0xFFFDF6E3),
                            title: 'Season Preferences',
                            subtitle: '${profile.defaultSeasonMode.label} Mode active',
                            onTap: () => showSeasonModePicker(
                              context,
                              current: profile.defaultSeasonMode,
                              onSelected: cubit.updateDefaultSeasonMode,
                            ),
                          ),
                          const SectionLabel('App'),
                          SettingsTile(
                            icon: Icons.notifications_none_rounded,
                            iconColor: const Color(0xFFE0574C),
                            iconBg: const Color(0xFFFDEBEA),
                            title: 'Notification Settings',
                            subtitle: 'Alerts & reminders',
                            onTap: () {
                              // TODO: build once the notifications feature exists.
                            },
                          ),
                          SettingsTile(
                            icon: Icons.settings_outlined,
                            iconColor: Colors.grey[700]!,
                            iconBg: const Color(0xFFF1F3F2),
                            title: 'App Settings',
                            subtitle: 'Language, voice, theme',
                            onTap: () {
                              // TODO: language/voice/theme settings screen.
                            },
                          ),
                          SettingsTile(
                            icon: Icons.help_outline_rounded,
                            iconColor: const Color(0xFF2FA7A7),
                            iconBg: const Color(0xFFE6F5F5),
                            title: 'Help & Support',
                            subtitle: 'FAQ, contact us',
                            onTap: () {
                              // TODO: help & support screen.
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => _logout(context),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFDEBEA),
                                foregroundColor: const Color(0xFFE0574C),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await fb.FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  void _editPersonalInfo(BuildContext context, ProfileCubit cubit, UserProfile profile) {
    final nameController = TextEditingController(text: profile.fullName);
    final phoneController = TextEditingController(text: profile.phone ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Personal Information',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
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
                    phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  );
                  Navigator.of(sheetContext).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editAcademicDetails(BuildContext context, ProfileCubit cubit, UserProfile profile) {
    final collegeController = TextEditingController(text: profile.college);
    String? selectedYear = profile.academicYear;
    const years = ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5+'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Academic Details',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: collegeController,
                    decoration: const InputDecoration(labelText: 'College / Major'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedYear,
                    decoration: const InputDecoration(labelText: 'Year'),
                    items: years
                        .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                        .toList(),
                    onChanged: (value) => setSheetState(() => selectedYear = value),
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
                      cubit.updateAcademicDetails(college: college, academicYear: selectedYear);
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Save'),
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
