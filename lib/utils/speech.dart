import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechHelper {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  Function(String, {required bool isFinal})? onResultCallback;

  Future<bool> initSpeech(
      Function(String, {required bool isFinal}) callback) async {
    onResultCallback = callback;
    try {
      bool available = await _speech.initialize(
        onError: (error) => print("Speech Error: $error"),
        onStatus: (status) => print("Speech Status: $status"),
      );
      if (!available) {
        print("Speech recognition is not available.");
        return false;
      }
      return true;
    } catch (e) {
      print("Speech Initialization Error: $e");
      return false;
    }
  }

  void startListening() {
    if (!_isListening && _speech.isAvailable) {
      _isListening = true;
      _speech.listen(
        onResult: (result) {
          if (onResultCallback != null) {
            onResultCallback!(result.recognizedWords,
                isFinal: result.finalResult);
          }
        },
        listenMode: stt.ListenMode.dictation,
        partialResults: true, // Ensures real-time updates
      );
    }
  }

  void stopListening() {
    if (_isListening) {
      _isListening = false;
      _speech.stop();
    }
  }

  bool get isListening => _isListening;
}
