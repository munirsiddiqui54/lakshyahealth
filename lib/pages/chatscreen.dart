import 'package:arogya/pages/hospital.dart';
import 'package:arogya/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:arogya/utils/speech.dart';
import 'package:arogya/utils/tts.dart';
import 'package:arogya/pages/hospital.dart';

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final TTSHelper _ttsHelper = TTSHelper();
  final SpeechHelper _speechHelper = SpeechHelper();
  String _recognizedText = "hold to start speaking...";
  bool _isRecording = false;
  bool _showSearchIcon = false;
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _ttsHelper.initTTS();
    await _speechHelper.initSpeech((String text, {required bool isFinal}) {
      setState(() {
        _recognizedText = text;
      });
      if (isFinal) {
        _sendRequest(text);
      }
    });
  }

  void _sendRequest(String text) async {
    setState(() {
      _messages.add({"role": "user", "message": text});
    });

    try {
      String response = await fetchResponse(text);
      _ttsHelper.speak(response);

      setState(() {
        _messages.add({"role": "app", "message": response});
        if (_messages.length >= 2) {
          _showSearchIcon = true;
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              _showSearchIcon = false; // Hide the icon after 3 seconds
            });
          });
        }
      });
    } catch (e) {
      setState(() {
        _messages
            .add({"role": "app", "message": "Sorry, something went wrong."});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/homebg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubble(
                    message: message["message"]!,
                    isUser: message["role"] == "user",
                  );
                },
              ),
            ),
            if (_messages.length >= 0)
              AnimatedOpacity(
                opacity: _showSearchIcon ? 1.0 : 0.0,
                duration: Duration(seconds: 1),
                child: GestureDetector(
                  onTap: () {
                    _speechHelper.stopListening();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HospitalsScreen()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: SizedBox(
                      width: 250, // Adjust width as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_hospital,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Search Nearby Hospitals...",
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: Colors.grey.withOpacity(0.8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _recognizedText,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onLongPressStart: (_) {
                      setState(() {
                        _isRecording = true;
                      });
                      _speechHelper.startListening();
                    },
                    onLongPressEnd: (_) {
                      setState(() {
                        _isRecording = false;
                      });
                      _speechHelper.stopListening();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/icons/mic.png',
                        color: Colors.white,
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
