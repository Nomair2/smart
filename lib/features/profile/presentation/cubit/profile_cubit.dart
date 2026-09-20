import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._profileRepository) : super(const ProfileState()) {
    _subscription = _profileRepository.watchCurrentProfile().listen(
      (profile) => emit(state.copyWith(status: ProfileStatus.loaded, profile: profile)),
      onError: (Object error) =>
          emit(state.copyWith(status: ProfileStatus.error, errorMessage: error.toString())),
    );
  }

  final ProfileRepository _profileRepository;
  late final StreamSubscription<dynamic> _subscription;

  Future<void> updatePersonalInfo({required String fullName, String? phone}) {
    return _profileRepository.updatePersonalInfo(fullName: fullName, phone: phone);
  }

  Future<void> updateAcademicDetails({required String college, String? academicYear}) {
    return _profileRepository.updateAcademicDetails(college: college, academicYear: academicYear);
  }

  Future<void> updateDefaultSeasonMode(SeasonMode mode) {
    return _profileRepository.updateDefaultSeasonMode(mode);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
