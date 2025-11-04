
// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// iOS Simulator ใช้ 127.0.0.1
  static const String base = 'http://127.0.0.1:3000';

  static const _json = {'Content-Type': 'application/json'};
  static const _timeout = Duration(seconds: 10);

  // Health check (ออปชัน)
  static Future<String> health() async {
    final r = await http.get(Uri.parse('$base/api/health')).timeout(_timeout);
    _throwIfNot200(r);
    return r.body;
  }

  /// ดึงรายการห้องทั้งหมด
  static Future<List<dynamic>> getRooms() async {
    final r = await http.get(Uri.parse('$base/api/rooms')).timeout(_timeout);
    _throwIfNot200(r);
    return jsonDecode(r.body) as List;
  }

  /// จองห้อง (ตั้งเป็น pending) ต้องส่ง roleId ของผู้ใช้
  static Future<void> reserveRoom(int roomId, int roleId) async {
    final r = await http.put(
      Uri.parse('$base/api/student/rooms/$roomId'),
      headers: _json,
      body: jsonEncode({'role_id': roleId}),
    ).timeout(_timeout);
    _throwIfNot200(r);
  }

  /// เข้าสู่ระบบ -> ได้ role_id, username, role
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final r = await http.post(
      Uri.parse('$base/api/login'),
      headers: _json,
      body: jsonEncode({'username': username, 'password': password}),
    ).timeout(_timeout);
    _throwIfNot200(r);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  /// ประวัติการจองของฉัน
  static Future<List<dynamic>> getMyHistory(int roleId) async {
    final r = await http
        .get(Uri.parse('$base/api/student/history/$roleId'))
        .timeout(_timeout);
    _throwIfNot200(r);
    return jsonDecode(r.body) as List;
  }

  // ===== helpers =====
  static void _throwIfNot200(http.Response r) {
    if (r.statusCode != 200) {
      // พยายามดึงข้อความ error จาก body
      final msg = r.body.isNotEmpty ? r.body : 'HTTP ${r.statusCode}';
      throw Exception(msg);
    }
  }
}
