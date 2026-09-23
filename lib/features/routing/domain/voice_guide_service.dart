/// Speaks guidance text aloud (requirement A9). Backed by
/// [NoopVoiceGuideService] for now — no `flutter_tts` dependency added yet,
/// on purpose: adding a plugin is its own deliberate step, not something to
/// slip in as a side effect of building the Route Guide screen. Swapping in
/// a real TTS-backed implementation later is a one-line change in
/// main.dart, same as every other repository/service so far.
abstract class VoiceGuideService {
  Future<void> speak(String text);

  Future<void> stop();
}
