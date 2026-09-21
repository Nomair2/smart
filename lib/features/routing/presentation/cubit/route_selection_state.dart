import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../domain/entities/campus_node.dart';
import '../../domain/entities/route_optimization_goal.dart';

enum RouteSelectionStatus { loadingGraph, ready, searching, graphError }

const Object _unset = Object();

class RouteSelectionState extends Equatable {
  const RouteSelectionState({
    this.status = RouteSelectionStatus.loadingGraph,
    this.selectableNodes = const [],
    this.origin,
    this.destination,
    this.seasonMode = SeasonMode.auto,
    this.goal = RouteOptimizationGoal.comfort,
    this.errorMessage,
  });

  final RouteSelectionStatus status;
  final List<CampusNode> selectableNodes;
  final CampusNode? origin;
  final CampusNode? destination;
  final SeasonMode seasonMode;
  final RouteOptimizationGoal goal;
  final String? errorMessage;

  bool get canSearch =>
      status != RouteSelectionStatus.searching &&
      origin != null &&
      destination != null &&
      origin!.id != destination!.id;

  RouteSelectionState copyWith({
    RouteSelectionStatus? status,
    List<CampusNode>? selectableNodes,
    Object? origin = _unset,
    Object? destination = _unset,
    SeasonMode? seasonMode,
    RouteOptimizationGoal? goal,
    Object? errorMessage = _unset,
  }) {
    return RouteSelectionState(
      status: status ?? this.status,
      selectableNodes: selectableNodes ?? this.selectableNodes,
      origin: identical(origin, _unset) ? this.origin : origin as CampusNode?,
      destination: identical(destination, _unset) ? this.destination : destination as CampusNode?,
      seasonMode: seasonMode ?? this.seasonMode,
      goal: goal ?? this.goal,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props =>
      [status, selectableNodes, origin, destination, seasonMode, goal, errorMessage];
}
