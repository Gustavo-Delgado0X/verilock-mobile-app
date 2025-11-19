import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StatusResponse {
  final bool ok;
  final bool locked;
  final String lockState;
  final String lastSeenName;
  final bool cameraOk;

  StatusResponse({
    required this.ok,
    required this.locked,
    required this.lockState,
    required this.lastSeenName,
    required this.cameraOk,
  });

  factory StatusResponse.fromJson(Map<String, dynamic> json) {
    final state = json['lock_state'] as String? ?? 'UNKNOWN';
    return StatusResponse(
      ok: json['ok'] ?? false,
      locked: state == 'LOCKED',
      lockState: state,
      lastSeenName: json['last_seen_name'] ?? 'Unknown',
      cameraOk: json['camera_ok'] ?? false,
    );
  }
}

class ActionResponse {
  final bool ok;
  final String state;

  ActionResponse({required this.ok, required this.state});

  factory ActionResponse.fromJson(Map<String, dynamic> json) {
    return ActionResponse(
      ok: json['ok'] ?? false,
      state: json['state'] ?? 'UNKNOWN',
    );
  }
}

class ApiService {
  Future<String> get baseUrl async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('custom_base_url') ??
           dotenv.env['BASE_URL'] ??
           'http://192.168.1.100:8000';
  }

  Future<T> _post<T>(String endpoint, T Function(Map<String, dynamic>) parser) async {
    try {
      final url = await baseUrl;
      final uri = Uri.parse('$url$endpoint');
      final response = await http.post(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return parser(jsonDecode(response.body));
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Connection failed: $e';
    }
  }

  // --- Single File Upload Helper ---
  Future<bool> _uploadFile(String endpoint, String filepath, String fieldName, Map<String, String> fields) async {
    try {
      final url = await baseUrl;
      final uri = Uri.parse('$url$endpoint');
      
      var request = http.MultipartRequest('POST', uri);
      fields.forEach((k, v) => request.fields[k] = v);
      
      var file = await http.MultipartFile.fromPath(fieldName, filepath);
      request.files.add(file);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      throw 'Upload failed: $e';
    }
  }

  // --- Dual File Upload (For Verification) ---
  Future<bool> _uploadDualFiles(String endpoint, String facePath, String voicePath, Map<String, String> fields) async {
    try {
      final url = await baseUrl;
      final uri = Uri.parse('$url$endpoint');
      
      var request = http.MultipartRequest('POST', uri);
      
      // Add text fields (user_name, phrase)
      fields.forEach((k, v) => request.fields[k] = v);
      
      // Add Face (Key must be 'face_image')
      request.files.add(await http.MultipartFile.fromPath('face_image', facePath));
      
      // Add Voice (Key must be 'voice_file')
      request.files.add(await http.MultipartFile.fromPath('voice_file', voicePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      throw 'Verification failed: $e';
    }
  }

  // --- Public Methods (MATCHING PYTHON KEYS) ---
  
  Future<bool> enrollFace(String name, String imagePath) async {
    // Python: request.form.get("user_name"), request.files.get("face_image")
    return _uploadFile('/upload_face', imagePath, 'face_image', {'user_name': name});
  }

  Future<bool> enrollVoice(String name, String audioPath, String phrase) async {
    // Python: request.form.get("user_name"), request.files.get("voice_file")
    return _uploadFile('/enroll_voice', audioPath, 'voice_file', {'user_name': name, 'phrase': phrase});
  }

  Future<bool> verifyUser(String name, String imagePath, String audioPath, String phrase) async {
    // Python: user_name, phrase, face_image, voice_file
    return _uploadDualFiles('/verify_user', imagePath, audioPath, {
      'user_name': name, 
      'phrase': phrase
    });
  }

  Future<List<String>> getProfiles() async {
    try {
      final url = await baseUrl;
      final uri = Uri.parse('$url/api_profiles'); 
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['profiles']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteProfile(String name) async {
    try {
      final url = await baseUrl;
      final uri = Uri.parse('$url/delete_profile/$name');
      final response = await http.post(uri);
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      return false;
    }
  }

  Future<StatusResponse> getStatus() async {
    try {
      final url = await baseUrl;
      final uri = Uri.parse('$url/api_status');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return StatusResponse.fromJson(jsonDecode(response.body));
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Connection failed: $e';
    }
  }

  Future<ActionResponse> lock() => _post('/api_lock', ActionResponse.fromJson);
  Future<ActionResponse> unlock() => _post('/api_unlock', ActionResponse.fromJson);
  Future<ActionResponse> keyOverride() => _post('/api_key_override', ActionResponse.fromJson);
}
