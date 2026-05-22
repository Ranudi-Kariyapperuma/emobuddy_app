import 'dart:convert';

import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {

  // ─────────────────────────────────────────────

  // Toggle this when switching between devices:

  //   true  → Android Emulator

  //   false → Real Phone

  // ─────────────────────────────────────────────

  static const bool isEmulator = false;

  static const String _emulatorUrl = "http://10.0.2.2:8000";

  static const String _deviceUrl = "http://192.168.1.8:8000"; 

  static String get baseUrl => isEmulator ? _emulatorUrl : _deviceUrl;

  // ───────────────── UPLOAD ACTIVITY ─────────────────

  static Future<Map<String, dynamic>> uploadActivity(

      File image, String category) async {

    try {

      var req = http.MultipartRequest(

        "POST",

        Uri.parse("$baseUrl/predict/activity"),

      );

      req.fields['category'] = category;

      req.files.add(await http.MultipartFile.fromPath("file", image.path));

      var res = await req.send().timeout(const Duration(seconds: 30));

      final body = await res.stream.bytesToString();

      if (res.statusCode != 200) {

        throw Exception("Server error ${res.statusCode}: $body");

      }

      return json.decode(body);

    } on SocketException {

      throw Exception("No connection — check your IP and WiFi");

    } on HttpException {

      throw Exception("Server unreachable");

    }

  }

  // ───────────────── UPLOAD FACE ─────────────────

  static Future<Map<String, dynamic>> uploadFace(File image) async {

    try {

      var req = http.MultipartRequest(

        "POST",

        Uri.parse("$baseUrl/predict/facial"),

      );

      req.files.add(await http.MultipartFile.fromPath("file", image.path));

      var res = await req.send().timeout(const Duration(seconds: 30));

      final body = await res.stream.bytesToString();

      if (res.statusCode != 200) {

        throw Exception("Server error ${res.statusCode}: $body");

      }

      return json.decode(body);

    } on SocketException {

      throw Exception("No connection — check your IP and WiFi");

    } on HttpException {

      throw Exception("Server unreachable");

    }

  }

  // ───────────────── COMBINED ─────────────────

  static Future<Map<String, dynamic>> combined({

    File? handwriting,

    File? coloring,

    File? drawing,

    File? face,

  }) async {

    try {

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

        req.files

            .add(await http.MultipartFile.fromPath("facial_file", face.path));

      }

      var res = await req.send().timeout(const Duration(seconds: 60));

      final body = await res.stream.bytesToString();

      if (res.statusCode != 200) {

        throw Exception("Server error ${res.statusCode}: $body");

      }

      return json.decode(body);

    } on SocketException {

      throw Exception("No connection — check your IP and WiFi");

    } on HttpException {

      throw Exception("Server unreachable");

    }

  }

}