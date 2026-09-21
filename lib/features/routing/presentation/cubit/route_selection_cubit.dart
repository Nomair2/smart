import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/campus_node.dart';
import '../../domain/entities/path_segment.dart';
import '../../domain/entities/route_optimization_goal.dart';
import '../../domain/entities/route_request.dart';
import '../../domain/entities/route_result.dart';
import '../../domain/repositories/campus_repository.dart';
import '../../domain/routing_engine.dart';
import 'route_selection_state.dart';

class RouteSelectionCubit extends Cubit<RouteSelectionState> {
  RouteSelectionCubit({
    required CampusRepository campusRepository,
    required HomeRepository homeRepository,
    required ProfileRepository profileRepository,
  })  : _campusRepository = campusRepository,
        _homeRepository = homeRepository,
        super(const RouteSelectionState()) {
    _init(profileRepository);
  }

  final CampusRepository _campusRepository;
  final HomeRepository _homeRepository;
  final RoutingEngine _engine = RoutingEngine();

  List<CampusNode> _allNodes = const [];
  List<PathSegment> _allSegments = const [];

  Future<void> _init(ProfileRepository profileRepository) async {
    try {
      final nodes = await _campusRepository.fetchNodes();
      final segments = await _campusRepository.fetchSegments();
      _allNodes = nodes;
      _allSegments = segments;

      // Prefill the season pill from the student's saved preference —
      // ProfileRepository already tracks this (see the profile feature).
      SeasonMode initialSeason = SeasonMode.auto;
      try {
        final profile = await profileRepository.watchCurrentProfile().first;
        initialSeason = profile.defaultSeasonMode;
      } catch (_) {
        // Fall back to auto if the profile can't be read for some reason —
        // this screen shouldn't be blocked by a profile hiccup.
      }

      emit(state.copyWith(
        status: RouteSelectionStatus.ready,
        selectableNodes: nodes.where((n) => n.isSelectable).toList(),
        seasonMode: initialSeason,
      ));
    } catch (e) {
      emit(state.copyWith(status: RouteSelectionStatus.graphError, errorMessage: e.toString()));
    }
  }

  void originChanged(CampusNode node) => emit(state.copyWith(origin: node, errorMessage: null));

  void destinationChanged(CampusNode node) =>
      emit(state.copyWith(destination: node, errorMessage: null));

  void swapPoints() => emit(state.copyWith(origin: state.destination, destination: state.origin));

  void seasonModeChanged(SeasonMode mode) => emit(state.copyWith(seasonMode: mode));

  void goalChanged(RouteOptimizationGoal goal) => emit(state.copyWith(goal: goal));

  /// Runs the search and returns the result directly rather than storing it
  /// in this cubit's state — Best Route Found takes the [RouteResult] as a
  /// plain constructor argument, so it doesn't need this cubit (or the
  /// campus graph) at all.
  Future<RouteResult?> findBestRoute() async {
    if (!state.canSearch) return null;

    emit(state.copyWith(status: RouteSelectionStatus.searching, errorMessage: null));
    try {
      final weather = await _homeRepository.fetchCurrentWeather();
      final result = _engine.findRoute(
        nodes: _allNodes,
        segments: _allSegments,
        request: RouteRequest(
          originNodeId: state.origin!.id,
          destinationNodeId: state.destination!.id,
          seasonMode: state.seasonMode,
          goal: state.goal,
        ),
        currentTemperatureC: weather.temperatureC,
        windSpeedKph: weather.windSpeedKph,
      );

      if (result == null) {
        emit(state.copyWith(
          status: RouteSelectionStatus.ready,
          errorMessage: 'No walkable route found between those two points.',
        ));
        return null;
      }

      emit(state.copyWith(status: RouteSelectionStatus.ready));
      return result;
    } catch (_) {
      emit(state.copyWith(
        status: RouteSelectionStatus.ready,
        errorMessage: 'Could not compute a route. Please try again.',
      ));
      return null;
    }
  }
}
