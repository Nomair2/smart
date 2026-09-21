import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/route_optimization_goal.dart';
import '../../domain/repositories/campus_repository.dart';
import '../cubit/route_selection_cubit.dart';
import '../cubit/route_selection_state.dart';
import '../widgets/optimization_goal_pill.dart';
import '../widgets/route_point_selector.dart';
import '../widgets/season_mode_card.dart';
import 'best_route_page.dart';

class RouteSelectionPage extends StatelessWidget {
  const RouteSelectionPage({super.key, this.onBack});

  /// Called when the header's back button is tapped. This screen is a
  /// bottom-nav tab root (not a pushed route) when reached from the shell,
  /// so `Navigator.pop` would be a no-op there — the shell passes a
  /// callback that switches back to the Home tab instead. Falls back to a
  /// real pop for any future flow that pushes this screen directly.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RouteSelectionCubit(
        campusRepository: context.read<CampusRepository>(),
        homeRepository: context.read<HomeRepository>(),
        profileRepository: context.read<ProfileRepository>(),
      ),
      child: _RouteSelectionView(onBack: onBack),
    );
  }
}

class _RouteSelectionView extends StatelessWidget {
  const _RouteSelectionView({this.onBack});

  final VoidCallback? onBack;

  static const Color primaryGreen = Color(0xFF1E5B3D);
  static const Color primaryGreenLight = Color(0xFF2F7A55);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: BlocBuilder<RouteSelectionCubit, RouteSelectionState>(
        builder: (context, state) {
          final cubit = context.read<RouteSelectionCubit>();

          if (state.status == RouteSelectionStatus.loadingGraph) {
            return const SafeArea(child: Center(child: CircularProgressIndicator()));
          }
          if (state.status == RouteSelectionStatus.graphError) {
            return SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.errorMessage ?? 'Could not load the campus map.'),
                ),
              ),
            );
          }

          final sameNode = state.origin != null &&
              state.destination != null &&
              state.origin!.id == state.destination!.id;

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryGreen, primaryGreenLight],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: onBack ?? () => Navigator.of(context).maybePop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration:
                                BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            Text('Select Route',
                                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                            SizedBox(width: 8),
                            Text('\ud83d\udcd8', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Choose your start & destination',
                            style: TextStyle(color: Colors.white70, fontSize: 13.5)),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -26),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RoutePointSelector(
                            nodes: state.selectableNodes,
                            origin: state.origin,
                            destination: state.destination,
                            onOriginChanged: cubit.originChanged,
                            onDestinationChanged: cubit.destinationChanged,
                            onSwap: cubit.swapPoints,
                          ),
                          if (sameNode) ...[
                            const SizedBox(height: 8),
                            const Text('Starting point and destination can\'t be the same.',
                                style: TextStyle(fontSize: 12, color: Color(0xFFE0574C))),
                          ],
                          if (state.errorMessage != null && !sameNode) ...[
                            const SizedBox(height: 8),
                            Text(state.errorMessage!, style: const TextStyle(fontSize: 12, color: Color(0xFFE0574C))),
                          ],
                          const SizedBox(height: 22),
                          Text('NAVIGATION MODE',
                              style: TextStyle(
                                  fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.grey[500])),
                          const SizedBox(height: 10),
                          Row(
                            children: SeasonMode.values
                                .map((mode) => Padding(
                                      padding: EdgeInsets.only(right: mode == SeasonMode.values.last ? 0 : 10),
                                      child: SeasonModeCard(
                                        mode: mode,
                                        selected: state.seasonMode == mode,
                                        onTap: () => cubit.seasonModeChanged(mode),
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 22),
                          Text('OPTIMIZE FOR',
                              style: TextStyle(
                                  fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.grey[500])),
                          const SizedBox(height: 10),
                          Row(
                            children: RouteOptimizationGoal.values
                                .map((goal) => Padding(
                                      padding: EdgeInsets.only(right: goal == RouteOptimizationGoal.values.last ? 0 : 10),
                                      child: OptimizationGoalPill(
                                        goal: goal,
                                        selected: state.goal == goal,
                                        onTap: () => cubit.goalChanged(goal),
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: state.canSearch
                                  ? () async {
                                      final result = await cubit.findBestRoute();
                                      if (result != null && context.mounted) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => BestRoutePage(result: result)),
                                        );
                                      }
                                    }
                                  : null,
                              icon: state.status == RouteSelectionStatus.searching
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.navigation_rounded, size: 18),
                              label: const Text('Find Best Route'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: primaryGreen.withOpacity(0.5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
