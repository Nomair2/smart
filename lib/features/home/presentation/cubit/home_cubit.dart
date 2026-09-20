import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._profileRepository, this._homeRepository) : super(const HomeState()) {
    _profileSubscription = _profileRepository.watchCurrentProfile().listen(
      (profile) => emit(state.copyWith(profile: profile)),
      onError: (Object error) =>
          emit(state.copyWith(status: HomeStatus.error, errorMessage: error.toString())),
    );
    _loadHomeData();
  }

  final ProfileRepository _profileRepository;
  final HomeRepository _homeRepository;
  late final StreamSubscription<dynamic> _profileSubscription;

  Future<void> _loadHomeData() async {
    try {
      final weather = await _homeRepository.fetchCurrentWeather();
      final recentRoutes = await _homeRepository.fetchRecentRoutes();
      emit(state.copyWith(
        status: HomeStatus.loaded,
        weather: weather,
        recentRoutes: recentRoutes,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> refresh() => _loadHomeData();

  /// The "Summer Mode Active" card only appears when summer weather is
  /// driving routing — toggling it off hands the decision back to
  /// [SeasonMode.auto] rather than jumping straight to winter.
  Future<void> toggleSummerMode(bool enabled) {
    return _profileRepository.updateDefaultSeasonMode(
      enabled ? SeasonMode.summer : SeasonMode.auto,
    );
  }

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    return super.close();
  }
}
