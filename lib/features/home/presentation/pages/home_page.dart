import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../../../core/presentation/widgets/season_mode_picker.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/repositories/home_repository.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/find_route_cta.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_route_tile.dart';
import '../widgets/season_toggle_card.dart';
import '../widgets/weather_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenRoutes, required this.onOpenProfile});

  /// Both are shell-tab switches, not pushed routes — see [MainShellPage].
  final VoidCallback onOpenRoutes;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        context.read<ProfileRepository>(),
        context.read<HomeRepository>(),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final profile = state.profile;
              final weather = state.weather;

              if (state.status == HomeStatus.error && weather == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(state.errorMessage ?? 'Could not load the home screen.'),
                  ),
                );
              }
              if (profile == null || weather == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final cubit = context.read<HomeCubit>();
              final isSummerActive = profile.defaultSeasonMode == SeasonMode.summer;

              return RefreshIndicator(
                onRefresh: cubit.refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    WeatherCard(
                      greeting: _greeting(),
                      firstName: profile.fullName.split(' ').first,
                      weather: weather,
                      modeLabel: '${profile.defaultSeasonMode.label} Mode Active',
                      onAvatarTap: onOpenProfile,
                    ),
                    const SizedBox(height: 20),
                    Text('QUICK ACTIONS',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: Colors.grey[500])),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        QuickActionCard(
                          icon: Icons.map_rounded,
                          label: 'Find Route',
                          color: const Color(0xFF1E5B3D),
                          onTap: onOpenRoutes,
                        ),
                        const SizedBox(width: 10),
                        QuickActionCard(
                          icon: Icons.wb_sunny_rounded,
                          label: 'Season Mode',
                          color: const Color(0xFFE0A83C),
                          onTap: () => showSeasonModePicker(
                            context,
                            current: profile.defaultSeasonMode,
                            onSelected: (mode) =>
                                context.read<ProfileRepository>().updateDefaultSeasonMode(mode),
                          ),
                        ),
                        const SizedBox(width: 10),
                        QuickActionCard(
                          icon: Icons.person_rounded,
                          label: 'My Profile',
                          color: const Color(0xFF4C6FE0),
                          onTap: onOpenProfile,
                        ),
                      ],
                    ),
                    if (isSummerActive) ...[
                      const SizedBox(height: 16),
                      SeasonToggleCard(value: isSummerActive, onChanged: cubit.toggleSummerMode),
                    ],
                    const SizedBox(height: 16),
                    FindRouteCta(onTap: onOpenRoutes),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('RECENT ROUTES',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: Colors.grey[500])),
                        InkWell(
                          onTap: onOpenRoutes,
                          child: const Text('See All',
                              style: TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E5B3D))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (state.recentRoutes.isEmpty)
                      Text('No routes yet — try Find Route above.',
                          style: TextStyle(fontSize: 13, color: Colors.grey[500]))
                    else
                      ...state.recentRoutes.map((route) => RecentRouteTile(route: route)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
