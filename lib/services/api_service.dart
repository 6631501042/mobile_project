// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  /// iOS Simulator ใช้ 127.0.0.1
  static const String base = 'http://192.168.50.51:3000';
  // static const String base = 'http://192.168.1.106:3000';

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
    final r = await http
        .put(
          Uri.parse('$base/api/student/rooms/$roomId'),
          headers: _json,
          body: jsonEncode({'role_id': roleId}),
        )
        .timeout(_timeout);
    _throwIfNot200(r);
  }

  /// ประวัติการจองของฉัน
  static Future<List<dynamic>> getMyHistory(int roleId) async {
    final r = await http
        .get(Uri.parse('$base/api/student/status/$roleId'))
        .timeout(_timeout);
    _throwIfNot200(r);
    return jsonDecode(r.body) as List;
  }

static Future<void> addRoom(String name, String? roomType, String status, String? imageUrl, String slot) async {
  final response = await http.post(
    Uri.parse('$base/api/addRoom'),
    headers: _json,
    body: jsonEncode({
      'roomname': name,
      'roomtype': roomType,
      'status': status,
      'image': imageUrl,
      'timeSlots': slot,
    }),
  ).timeout(_timeout);
  _throwIfNot200(response);
}

// ฟังก์ชันสำหรับอัปเดตห้อง
  static Future<void> updateRoom(int roomId, String roomname, String? roomType, String status, String? imageUrl, String timeSlots) async {
    final response = await http.put(
      Uri.parse('$base/api/updateRoom/$roomId'),
      headers: _json,
      body: jsonEncode({
        'roomname': roomname,
        'roomtype': roomType,
        'status': status,
        'image': imageUrl,
        'timeSlots': timeSlots,
      }),
    ).timeout(_timeout);

    _throwIfNot200(response);
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


