import 'package:equatable/equatable.dart';

enum NavigationModee { preview, navigating }

class RouteGuideState extends Equatable {
  const RouteGuideState({
    this.currentStepIndex = 0,
    this.mode = NavigationModee.preview,
    this.voiceEnabled = true,
    this.userLatitude,
    this.userLongitude,
  });

  final int currentStepIndex;

  final NavigationModee mode;

  final bool voiceEnabled;

  /// Current GPS latitude of the user.
  final double? userLatitude;

  /// Current GPS longitude of the user.
  final double? userLongitude;

  RouteGuideState copyWith({
    int? currentStepIndex,

    NavigationModee? mode,

    bool? voiceEnabled,

    double? userLatitude,

    double? userLongitude,
  }) {
    return RouteGuideState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,

      mode: mode ?? this.mode,

      voiceEnabled: voiceEnabled ?? this.voiceEnabled,

      userLatitude: userLatitude ?? this.userLatitude,

      userLongitude: userLongitude ?? this.userLongitude,
    );
  }

  @override
  List<Object?> get props => [
    currentStepIndex,
    mode,
    voiceEnabled,
    userLatitude,
    userLongitude,
  ];
}
