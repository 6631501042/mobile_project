// lib/api/status_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// LDPlayer/Emulator ใช้ 10.0.2.2 แทน localhost
const String BASE_URL = 'http://192.168.1.157:3000';

class UserStatusService {
  static Future<List<Map<String, dynamic>>> fetchPending(String roleId) async {
    final uri = Uri.parse('$BASE_URL/api/user/pending/$roleId');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final raw = jsonDecode(res.body);
    if (raw is List) {
      // คาดหวัง [{roomname, timeslot, status}, ...]
      return raw.cast<Map<String, dynamic>>();
    }
    return const [];
  }
}
