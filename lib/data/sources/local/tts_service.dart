import 'package:flutter_tts/flutter_tts.dart';

/// Speaks words aloud for the "tap to hear" flashcard/quiz interactions.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  Future<void> _configure() async {
    if (_configured) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.1);
    await _tts.setVolume(1.0);
    _configured = true;
  }

  Future<void> speak(String text) async {
    await _configure();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
