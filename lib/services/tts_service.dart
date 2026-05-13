import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts tts = FlutterTts();

  Future<void> init() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45);
  }

  Future<void> speak(String text) async {
    await tts.speak(text);
  }

  Future<void> stop() async {
    await tts.stop();
  }
}