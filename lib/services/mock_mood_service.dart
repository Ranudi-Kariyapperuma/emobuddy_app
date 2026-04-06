import 'dart:math';

class MockMoodService {
  Future<String> detectMood() async {
    await Future.delayed(Duration(seconds: 2));

    List<String> moods = ["happy", "sad", "angry", "calm"];
    return moods[Random().nextInt(moods.length)];
  }
}