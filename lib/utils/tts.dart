import 'package:flutter_tts/flutter_tts.dart';

class TTSHelper {
  final FlutterTts _tts = FlutterTts();

  Future<void> initTTS() async {
    await _tts.setLanguage("hi-IN"); // Indian English
    await _tts.setPitch(1.0); // Normal pitch
    await _tts.setSpeechRate(0.5); // Normal speed
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }
}
