import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../domain/voice_guide_service.dart';

/// Real implementation of [VoiceGuideService] using the device's own TTS
/// engine (Android/iOS/desktop system voices — no network call, no API
/// key). Configuration is applied once, in the constructor; every call
/// after that is just `speak`/`stop`.
class FlutterTtsVoiceGuideService implements VoiceGuideService {
  FlutterTtsVoiceGuideService() {
    _configure();
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> _configure() async {
    try {
      await _tts.setLanguage('en-US');
      // Slightly slower than the package default — turn-by-turn directions
      // need to be followed while walking, not just heard once.
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      // A misconfigured TTS engine shouldn't block navigation — speak()
      // below still tries on every call regardless.
      debugPrint('[VoiceGuide] setup failed, will still try to speak: $e');
    }
  }

  @override
  Future<void> speak(String text) async {
    try {
      // Always flush first: a fresh instruction should replace whatever
      // was mid-sentence, not queue behind it — nobody wants to hear step
      // 3's directions after they've already reached step 5.
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('[VoiceGuide] speak failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('[VoiceGuide] stop failed: $e');
    }
  }
}
