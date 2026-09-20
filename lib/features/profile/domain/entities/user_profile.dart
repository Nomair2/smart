import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/season_mode.dart';

/// Mirrors the `users/{uid}` Firestore document (report Table 5, minus
/// `password_hash` — Firebase Auth owns that). Fields the registration
/// form doesn't collect yet (`academicYear`, `phone`) are nullable rather
/// than defaulted to a fake-looking value.
class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.studentId,
    required this.fullName,
    required this.universityEmail,
    required this.isEmailVerified,
    required this.college,
    this.academicYear,
    this.phone,
    this.routesCount = 0,
    this.kmWalkedTotal = 0,
    this.savedRoutesCount = 0,
    this.preferredLanguage = 'en',
    this.voiceEnabled = true,
    this.defaultSeasonMode = SeasonMode.auto,
  });

  final String uid;
  final String studentId;
  final String fullName;
  final String universityEmail;
  final bool isEmailVerified;
  final String college;
  final String? academicYear;
  final String? phone;
  final int routesCount;
  final double kmWalkedTotal;
  final int savedRoutesCount;
  final String preferredLanguage;
  final bool voiceEnabled;
  final SeasonMode defaultSeasonMode;

  UserProfile copyWith({
    String? fullName,
    String? college,
    String? academicYear,
    String? phone,
    String? preferredLanguage,
    bool? voiceEnabled,
    SeasonMode? defaultSeasonMode,
  }) {
    return UserProfile(
      uid: uid,
      studentId: studentId,
      fullName: fullName ?? this.fullName,
      universityEmail: universityEmail,
      isEmailVerified: isEmailVerified,
      college: college ?? this.college,
      academicYear: academicYear ?? this.academicYear,
      phone: phone ?? this.phone,
      routesCount: routesCount,
      kmWalkedTotal: kmWalkedTotal,
      savedRoutesCount: savedRoutesCount,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      defaultSeasonMode: defaultSeasonMode ?? this.defaultSeasonMode,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        studentId,
        fullName,
        universityEmail,
        isEmailVerified,
        college,
        academicYear,
        phone,
        routesCount,
        kmWalkedTotal,
        savedRoutesCount,
        preferredLanguage,
        voiceEnabled,
        defaultSeasonMode,
      ];
}
