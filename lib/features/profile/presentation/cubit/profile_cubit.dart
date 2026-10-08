import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/season_mode.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

/// Lives for the whole app now (provided once in `main.dart`, above
/// `MaterialApp`), not just while `ProfilePage` is on screen — that's
/// what lets `MaterialApp` and any pushed route reach it without the
/// `BlocProvider.value` carry-over this app used to need, and what lets
/// `AppSettingsCubit` pick up the signed-in user's language.
///
/// Because of that wider lifetime, this can no longer assume a user is
/// already signed in at construction time — the old version called
/// `watchCurrentProfile()` straight away, which throws synchronously if
/// nobody's logged in yet (see `FirestoreProfileRepository._uid`), and
/// would have crashed the app on launch. It now watches
/// `authStateChanges()` instead and only subscribes to
/// `watchCurrentProfile()` once a user actually exists, re-subscribing
/// on every login/logout.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._profileRepository, {fb.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
      super(const ProfileState()) {
    _authSubscription = _firebaseAuth.authStateChanges().listen(_onAuthChanged);
  }

  final ProfileRepository _profileRepository;
  final fb.FirebaseAuth _firebaseAuth;
  late final StreamSubscription<fb.User?> _authSubscription;
  StreamSubscription<UserProfile>? _profileSubscription;

  void _onAuthChanged(fb.User? user) {
    _profileSubscription?.cancel();
    if (user == null) {
      // Signed out (or not signed in yet) — nothing to show; AuthGate
      // handles routing to the Welcome screen separately.
      emit(const ProfileState());
      return;
    }
    _profileSubscription = _profileRepository.watchCurrentProfile().listen(
      (profile) => emit(state.copyWith(status: ProfileStatus.loaded, profile: profile)),
      onError: (Object error) =>
          emit(state.copyWith(status: ProfileStatus.error, errorMessage: error.toString())),
    );
  }

  Future<void> updatePersonalInfo({required String fullName, String? phone}) {
    return _profileRepository.updatePersonalInfo(fullName: fullName, phone: phone);
  }

  Future<void> updateAcademicDetails({required String college, String? academicYear}) {
    return _profileRepository.updateAcademicDetails(college: college, academicYear: academicYear);
  }

  Future<void> updateDefaultSeasonMode(SeasonMode mode) {
    return _profileRepository.updateDefaultSeasonMode(mode);
  }

  Future<void> updatePreferences({String? preferredLanguage, bool? voiceEnabled}) {
    return _profileRepository.updatePreferences(
      preferredLanguage: preferredLanguage,
      voiceEnabled: voiceEnabled,
    );
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    _profileSubscription?.cancel();
    return super.close();
  }
}
