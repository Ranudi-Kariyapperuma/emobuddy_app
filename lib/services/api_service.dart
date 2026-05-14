import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = "http://10.0.2.2:8000";

  static Future<Map<String, dynamic>> uploadActivity(
      File image, String category) async {
    var req = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/predict/activity"),
    );

    req.fields['category'] = category;
    req.files.add(await http.MultipartFile.fromPath("file", image.path));

    var res = await req.send();
    return json.decode(await res.stream.bytesToString());
  }

  static Future<Map<String, dynamic>> uploadFace(File image) async {
    var req = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/predict/facial"),
    );

    req.files.add(await http.MultipartFile.fromPath("file", image.path));

    var res = await req.send();
    return json.decode(await res.stream.bytesToString());
  }

  static Future<Map<String, dynamic>> combined({
    File? handwriting,
    File? coloring,
    File? drawing,
    File? face,
  }) async {
    var req = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/predict/combined"),
    );

    if (handwriting != null) {
      req.files.add(await http.MultipartFile.fromPath(
          "handwriting_file", handwriting.path));
    }
    if (coloring != null) {
      req.files.add(
          await http.MultipartFile.fromPath("coloring_file", coloring.path));
    }
    if (drawing != null) {
      req.files.add(
          await http.MultipartFile.fromPath("drawing_file", drawing.path));
    }
    if (face != null) {
      req.files.add(await http.MultipartFile.fromPath("facial_file", face.path));
    }

    var res = await req.send();
    return json.decode(await res.stream.bytesToString());
  }
}