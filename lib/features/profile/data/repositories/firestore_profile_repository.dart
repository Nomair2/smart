import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/domain/entities/season_mode.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  static const _usersCollection = 'users';

  String get _uid {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null)
      throw StateError('No signed-in user to load a profile for.');
    return uid;
  }

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection(_usersCollection).doc(_uid);

  @override
  Stream<UserProfile> watchCurrentProfile() {
    return _doc.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        throw StateError('No profile document found for the signed-in user.');
      }
      return _fromFirestore(uid: snapshot.id, data: data);
    });
  }

  @override
  Future<void> updatePersonalInfo({
    required String fullName,
    String? phone,
  }) async {
    await _doc.update({
      'fullName': fullName,
      if (phone != null) 'phone': phone,
    });
    await _firebaseAuth.currentUser?.updateDisplayName(fullName);
  }

  @override
  Future<void> updateAcademicDetails({
    required String college,
    String? academicYear,
  }) async {
    await _doc.update({
      'college': college,
      if (academicYear != null) 'academicYear': academicYear,
    });
  }

  @override
  Future<void> updateDefaultSeasonMode(SeasonMode mode) async {
    await _doc.update({'defaultSeasonMode': mode.storageValue});
  }

  @override
  Future<void> updatePreferences({
    String? preferredLanguage,
    bool? voiceEnabled,
  }) async {
    await _doc.update({
      if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
      if (voiceEnabled != null) 'voiceEnabled': voiceEnabled,
    });
  }

  UserProfile _fromFirestore({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    return UserProfile(
      uid: uid,
      studentId: data['studentId'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      universityEmail: data['universityEmail'] as String? ?? '',
      isEmailVerified: _firebaseAuth.currentUser?.emailVerified ?? false,
      college: data['college'] as String? ?? '',
      academicYear: data['academicYear'] as String?,
      phone: data['phone'] as String?,
      routesCount: (data['routesCount'] as num?)?.toInt() ?? 0,
      kmWalkedTotal: (data['kmWalkedTotal'] as num?)?.toDouble() ?? 0,
      savedRoutesCount: (data['savedRoutesCount'] as num?)?.toInt() ?? 0,
      preferredLanguage: data['preferredLanguage'] as String? ?? 'en',
      voiceEnabled: data['voiceEnabled'] as bool? ?? true,
      defaultSeasonMode: SeasonModeX.fromStorage(
        data['defaultSeasonMode'] as String?,
      ),
    );
  }
}
