import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

// void main() {
//   runApp(const MyApp());
// }

class Listen extends StatelessWidget {
  const Listen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpeechAssistant(),
    );
  }
}

class SpeechAssistant extends StatefulWidget {
  @override
  _SpeechAssistantState createState() => _SpeechAssistantState();
}

class _SpeechAssistantState extends State<SpeechAssistant> {
  stt.SpeechToText _speech = stt.SpeechToText();
  FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _userText = "Hold the button and speak...";
  String _botResponse = "";

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTTS();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onError: (error) => print("Speech Error: $error"),
      onStatus: (status) => print("Speech Status: $status"),
    );
    if (!available) {
      setState(() {
        _userText = "Speech recognition is not available.";
      });
    }
  }

  void _initTTS() async {
    await _tts.setLanguage("hi-IN"); // Indian English accent
    await _tts.setPitch(1.0); // Natural voice
    await _tts.setSpeechRate(0.7); // Speed of speaking
  }

  void _startListening() async {
    if (!_isListening && _speech.isAvailable) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _userText = result.recognizedWords; // Updates text in real-time
          });

          if (result.finalResult) {
            _generateResponse(
                _userText); // Generate response only on final result
          }
        },
        partialResults: true, // ✅ Enables real-time text updates
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _generateResponse(String userText) {
    setState(() {
      _botResponse = "Aapne kaha : $userText. Mai kya help kar skti hu!";
    });
    _speak(_botResponse);
  }

  void _speak(String response) async {
    await _tts.speak(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Indian Voice Assistant")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _userText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            GestureDetector(
              onLongPress: _startListening,
              onLongPressUp: _stopListening,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : Colors.blue,
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _botResponse,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
