import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MoodService {
  // ── Change this to your FastAPI server IP/URL ──────────────────────────────
  // For Android emulator  : http://10.0.2.2:8000
  // For real device (WiFi): http://YOUR_LOCAL_IP:8000   e.g. http://192.168.1.10:8000
  // For production        : https://your-api.com
  static const String _baseUrl = 'http://10.0.2.2:8000';

  /// Sends [imageFile] to the backend and returns the Flutter route key.
  /// Returns one of: "anger" | "fear" | "happy" | "sad"
  /// Throws an exception string if anything goes wrong.
  Future<String> detectMood(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/predict-emotion');

    // Build multipart request
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // "flutter_mood" is one of: anger | fear | happy | sad
        final mood = data['flutter_mood'] as String? ?? 'happy';
        return mood;
      } else {
        throw 'Server error ${response.statusCode}: ${response.body}';
      }
    } on SocketException {
      throw 'Cannot reach the server. Check your IP/URL in mood_service.dart.';
    } catch (e) {
      rethrow;
    }
  }
}
