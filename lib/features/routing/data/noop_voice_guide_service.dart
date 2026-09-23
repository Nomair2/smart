import 'package:flutter/foundation.dart';

import '../domain/voice_guide_service.dart';

/// Does nothing but log — lets Route Guide's mute toggle and "announce on
/// step change" logic be fully wired and testable before a real
/// `flutter_tts`-backed implementation exists.
class NoopVoiceGuideService implements VoiceGuideService {
  @override
  Future<void> speak(String text) async {
    debugPrint('[VoiceGuide] (not actually speaking) "$text"');
  }

  @override
  Future<void> stop() async {}
}
