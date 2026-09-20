import '../../../../core/domain/entities/season_mode.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  /// Live updates to the signed-in user's profile — a [Stream] rather than
  /// a one-off [Future] so the profile page (and anything else showing the
  /// user's name/season mode) reflects edits immediately without a manual
  /// refresh.
  Stream<UserProfile> watchCurrentProfile();

  Future<void> updatePersonalInfo({required String fullName, String? phone});

  Future<void> updateAcademicDetails({required String college, String? academicYear});

  Future<void> updateDefaultSeasonMode(SeasonMode mode);

  Future<void> updatePreferences({String? preferredLanguage, bool? voiceEnabled});
}
