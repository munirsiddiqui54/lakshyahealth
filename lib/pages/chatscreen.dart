import 'dart:convert';

import 'package:arogya/components/healthmetrics.dart';
import 'package:arogya/pages/hospital.dart';
import 'package:arogya/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:arogya/utils/speech.dart';
import 'package:arogya/utils/tts.dart';
import 'package:arogya/pages/hospital.dart';

class SpeechScreen extends StatefulWidget {
  final String hid;

  SpeechScreen({required this.hid});

  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final TTSHelper _ttsHelper = TTSHelper();
  final SpeechHelper _speechHelper = SpeechHelper();
  TextEditingController _textController = TextEditingController();
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
        _textController.text = text;
      });
      if (isFinal) {
        _sendRequest(text);
      }
    });
  }

  void _sendRequest(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({"role": "user", "message": text});
    });

    try {
      String response = await fetchResponse(text, widget.hid);
      _ttsHelper.speak(response);

      setState(() {
        _messages.add({"role": "app", "message": response});
        if (_messages.length >= 2) {
          _showSearchIcon = true;
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              _showSearchIcon = false;
            });
          });
        }
      });
      _textController.clear();
    } catch (e) {
      setState(() {
        _messages
            .add({"role": "app", "message": "Sorry, something went wrong."});
      });
    }
  }

  bool isUser(String response) {
    return false; // Helper function to check if response is from user
  }

  bool isValidJson(String response) {
    try {
      json.decode(response);
      return true;
    } catch (e) {
      return false;
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
              child: Stack(
                children: [
                  ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message["role"] == "user";
                      final messageText = message["message"]!;

                      if (!isUser && isValidJson(messageText)) {
                        // Parse JSON and convert into HealthCardData
                        final jsonResponse = json.decode(messageText);
                        List<HealthCardData> healthDataList = [];

                        // List of gradient color pairs for 4 boxes
                        final List<List<Color>> colorList = [
                          [Colors.orange.shade800, Colors.orange.shade400],
                          [Colors.green.shade800, Colors.green.shade400],
                          [Colors.purple.shade800, Colors.purple.shade400],
                          [Colors.pink.shade800, Colors.pink.shade400],
                        ];

                        int colorIndex = 0;

                        jsonResponse.forEach((key, value) {
                          healthDataList.add(
                            HealthCardData(
                              title: key,
                              items: [value.toString()],
                              colors: colorList[colorIndex % colorList.length],
                              isBorder: true, // Assign colors cyclically
                            ),
                          );
                          colorIndex++; // Move to the next color
                        });

                        return HealthMetrics(healthCards: healthDataList);
                      } else {
                        return ChatBubble(
                          message: messageText,
                          isUser: isUser,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: Colors.grey.withOpacity(0.8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _sendRequest(_textController.text);
                      _textController.clear();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                  SizedBox(width: 10),
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
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(_isRecording ? 12 : 8),
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Colors.indigo,
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

// This is a placeholder - you'll need to create this screen
class MedicalReportsScreen extends StatelessWidget {
  final String hid;

  MedicalReportsScreen({required this.hid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Previous Medical Reports"),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Text("Medical Reports will be displayed here"),
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
