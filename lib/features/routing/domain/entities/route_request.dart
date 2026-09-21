import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/season_mode.dart';
import 'route_optimization_goal.dart';

class RouteRequest extends Equatable {
  const RouteRequest({
    required this.originNodeId,
    required this.destinationNodeId,
    required this.seasonMode,
    required this.goal,
  });

  final String originNodeId;
  final String destinationNodeId;
  final SeasonMode seasonMode;
  final RouteOptimizationGoal goal;

  @override
  List<Object?> get props => [originNodeId, destinationNodeId, seasonMode, goal];
}
