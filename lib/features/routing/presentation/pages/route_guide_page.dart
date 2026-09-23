import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/route_result.dart';
import '../../domain/voice_guide_service.dart';
import '../cubit/route_guide_cubit.dart';
import '../cubit/route_guide_state.dart';
import '../widgets/current_step_card.dart';
import '../widgets/guide_step_tile.dart';
import '../widgets/route_schematic_map.dart';

class RouteGuidePage extends StatelessWidget {
  const RouteGuidePage({super.key, required this.result});

  final RouteResult result;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RouteGuideCubit(
        result: result,
        profileRepository: context.read<ProfileRepository>(),
        voiceGuideService: context.read<VoiceGuideService>(),
      ),
      child: const _RouteGuideView(),
    );
  }
}

class _RouteGuideView extends StatelessWidget {
  const _RouteGuideView();

  static const Color primaryGreen = Color(0xFF1E5B3D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      body: BlocBuilder<RouteGuideCubit, RouteGuideState>(
        builder: (context, state) {
          final cubit = context.read<RouteGuideCubit>();
          final result = cubit.result;
          final total = result.instructions.length;
          final progress = total <= 1
              ? 1.0
              : state.currentStepIndex / (total - 1);

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                Stack(
                  children: [
                    RouteSchematicMap(
                      geometry: result.geometry,
                      progress: progress,
                    ),
                    Positioned(
                      top: 10,
                      left: 12,
                      child: _RoundIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 12,
                      child: _RoundIconButton(
                        icon: state.voiceEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        onTap: cubit.toggleVoice,
                      ),
                    ),
                    if (state.mode == NavigationModee.navigating)
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fiber_manual_record,
                                  size: 9,
                                  color: primaryGreen,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Navigating...',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                CurrentStepCard(
                  instruction: cubit.currentInstruction,
                  stepNumber: state.currentStepIndex + 1,
                  totalSteps: total,
                ),
                Expanded(
                  child: cubit.hasArrived
                      ? _ArrivedContent(
                          destinationName:
                              result.destination.name ?? 'your destination',
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                          children: cubit.upcomingInstructions
                              .map(
                                (instruction) => GuideStepTile(
                                  instruction: instruction,
                                  onTap: () =>
                                      cubit.advanceTo(instruction.stepOrder),
                                ),
                              )
                              .toList(),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: state.mode == NavigationModee.navigating
                              ? null
                              : cubit.startNavigation,
                          icon: const Icon(Icons.navigation_rounded, size: 17),
                          label: Text(
                            state.mode == NavigationModee.navigating
                                ? 'Navigating'
                                : 'Start Navigation',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: primaryGreen.withOpacity(
                              0.6,
                            ),
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Route Details page using this same result.
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryGreen,
                            side: const BorderSide(color: Color(0xFFDDE5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Details'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 17, color: const Color(0xFF1E5B3D)),
      ),
    );
  }
}

class _ArrivedContent extends StatelessWidget {
  const _ArrivedContent({required this.destinationName});

  final String destinationName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration_rounded,
              size: 40,
              color: Color(0xFF1E5B3D),
            ),
            const SizedBox(height: 12),
            Text(
              "You've arrived at $destinationName!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
