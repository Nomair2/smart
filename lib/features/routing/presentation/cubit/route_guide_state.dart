import 'package:equatable/equatable.dart';

enum NavigationModee { preview, navigating }

class RouteGuideState extends Equatable {
  const RouteGuideState({
    this.currentStepIndex = 0,
    this.mode = NavigationModee.preview,
    this.voiceEnabled = true,
  });

  /// Index into `result.instructions`. Advances only when the user taps a
  /// step in the upcoming list (manual progress) — there's no GPS-based
  /// auto-advance yet; that's flagged as future work, not silently assumed.
  final int currentStepIndex;
  final NavigationModee mode;
  final bool voiceEnabled;

  RouteGuideState copyWith({
    int? currentStepIndex,
    NavigationModee? mode,
    bool? voiceEnabled,
  }) {
    return RouteGuideState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      mode: mode ?? this.mode,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
    );
  }

  @override
  List<Object?> get props => [currentStepIndex, mode, voiceEnabled];
}
