import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceListeningPage extends StatefulWidget {
  const VoiceListeningPage({super.key});

  @override
  State<VoiceListeningPage> createState() => _VoiceListeningPageState();
}

class _VoiceListeningPageState extends State<VoiceListeningPage> {
  late stt.SpeechToText _speech;
  String _spokenText = "";
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _startListening();
  }

  void _startListening() async {
    bool available = await _speech.initialize();

    if (available) {
      setState(() => _isListening = true);

      _speech.listen(
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
          });

          if (result.finalResult) {
            _stopListening();
          }
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    Navigator.pop(context, _spokenText); // send result back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Listening...",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 30),

            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 50),
            ),

            const SizedBox(height: 30),

            Text(
              _spokenText.isEmpty
                  ? "Speak now..."
                  : _spokenText,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
