import 'package:MasarKKU/features/home/domain/repositories/weather_repository.dart';
import 'package:MasarKKU/features/weather/domain/weather_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../../../core/localization/app_localizations.dart';
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
  const HomePage({
    super.key,
    required this.onOpenRoutes,
    required this.onOpenProfile,
  });

  /// Both are shell-tab switches, not pushed routes — see [MainShellPage].
  final VoidCallback onOpenRoutes;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        context.read<ProfileRepository>(),
        context.read<HomeRepository>(),
        context.read<WeatherRepository>(),
      ),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final l10n = AppLocalizations.of(context)!;
              final profile = state.profile;
              final weather = state.weather;

              if (state.status == HomeStatus.error && weather == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.errorMessage ?? l10n.couldNotLoadHome,
                    ),
                  ),
                );
              }
              if (profile == null || weather == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final cubit = context.read<HomeCubit>();
              final isSummerActive =
                  profile.defaultSeasonMode == SeasonMode.summer;

              return RefreshIndicator(
                onRefresh: cubit.refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    WeatherCard(
                      greeting: _greeting(l10n),
                      firstName: profile.fullName.split(' ').first,
                      weather: weather,
                      modeLabel: l10n.seasonModeActive(profile.defaultSeasonMode.label),
                      onAvatarTap: onOpenProfile,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.quickActions,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        QuickActionCard(
                          icon: Icons.map_rounded,
                          label: l10n.findRoute,
                          color: const Color(0xFF1E5B3D),
                          onTap: onOpenRoutes,
                        ),
                        const SizedBox(width: 10),
                        QuickActionCard(
                          icon: Icons.wb_sunny_rounded,
                          label: l10n.seasonModeAction,
                          color: const Color(0xFFE0A83C),
                          onTap: () => showSeasonModePicker(
                            context,
                            current: profile.defaultSeasonMode,
                            onSelected: (mode) => context
                                .read<ProfileRepository>()
                                .updateDefaultSeasonMode(mode),
                          ),
                        ),
                        const SizedBox(width: 10),
                        QuickActionCard(
                          icon: Icons.person_rounded,
                          label: l10n.myProfile,
                          color: const Color(0xFF4C6FE0),
                          onTap: onOpenProfile,
                        ),
                      ],
                    ),
                    if (isSummerActive) ...[
                      const SizedBox(height: 16),
                      SeasonToggleCard(
                        value: isSummerActive,
                        onChanged: cubit.toggleSummerMode,
                      ),
                    ],
                    const SizedBox(height: 16),
                    FindRouteCta(onTap: onOpenRoutes),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.recentRoutes,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: Colors.grey[500],
                          ),
                        ),
                        InkWell(
                          onTap: onOpenRoutes,
                          child: Text(
                            l10n.seeAll,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (state.recentRoutes.isEmpty)
                      Text(
                        l10n.noRoutesYet,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      )
                    else
                      ...state.recentRoutes.map(
                        (route) => RecentRouteTile(route: route),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }
}
