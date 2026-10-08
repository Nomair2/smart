import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/guidance_instruction.dart';
import '../../domain/entities/route_result.dart';
import '../../domain/voice_guide_service.dart';
import 'route_guide_state.dart';
import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../../core/location/location_service.dart';

class RouteGuideCubit extends Cubit<RouteGuideState> {
  RouteGuideCubit({
    required this.result,
    required ProfileRepository profileRepository,
    required VoiceGuideService voiceGuideService,
    required this.locationService,
  }) : _profileRepository = profileRepository,
       _voice = voiceGuideService,
       super(const RouteGuideState()) {
    _loadVoicePreference();
  }
  final LocationService locationService;

  StreamSubscription? _locationSubscription;

  final RouteResult result;
  final ProfileRepository _profileRepository;
  final VoiceGuideService _voice;

  GuidanceInstruction get currentInstruction =>
      result.instructions[state.currentStepIndex];

  List<GuidanceInstruction> get upcomingInstructions =>
      result.instructions.sublist(state.currentStepIndex + 1);

  bool get hasArrived =>
      state.currentStepIndex >= result.instructions.length - 1;

  Future<void> _loadVoicePreference() async {
    try {
      final profile = await _profileRepository.watchCurrentProfile().first;
      emit(state.copyWith(voiceEnabled: profile.voiceEnabled));
    } catch (_) {
      // Keep the default (on) if the profile can't be read — this screen
      // shouldn't be blocked by a profile hiccup.
    }
  }

  /// Turns on the "Navigating..." status and voice narration. Doesn't reset
  /// progress — see the design note on why "Start Navigation" isn't the
  /// same as "jump back to step 1".
  // void startNavigation() {
  //   emit(state.copyWith(mode: NavigationModee.navigating));
  //   _announceCurrentStep();
  // }

  /// Marks a specific upcoming step as reached — the manual stand-in for
  /// GPS-triggered auto-advance (explicitly future work).
  void advanceTo(int index) {
    if (index < 0 || index >= result.instructions.length) return;
    emit(state.copyWith(currentStepIndex: index));
    if (state.mode == NavigationModee.navigating) _announceCurrentStep();
  }

  Future<void> toggleVoice() async {
    final next = !state.voiceEnabled;
    emit(state.copyWith(voiceEnabled: next));
    if (!next) {
      await _voice.stop();
    } else {
      _announceCurrentStep();
    }
    try {
      await _profileRepository.updatePreferences(voiceEnabled: next);
    } catch (_) {
      // Best-effort persistence — the toggle still works for this session
      // even if the write fails.
    }
  }

  void _announceCurrentStep() {
    if (state.voiceEnabled) _voice.speak(currentInstruction.text);
  }

  Future<void> startNavigation() async {
    final allowed = await locationService.requestPermission();

    if (!allowed) {
      return;
    }

    final position = await locationService.getCurrentPosition();

    emit(
      state.copyWith(
        userLatitude: position.latitude,

        userLongitude: position.longitude,
      ),
    );

    _locationSubscription = locationService.positionStream().listen((
      Position position,
    ) {
      emit(
        state.copyWith(
          userLatitude: position.latitude,

          userLongitude: position.longitude,
        ),
      );
    });

    emit(state.copyWith(mode: NavigationModee.navigating));
  }
}
