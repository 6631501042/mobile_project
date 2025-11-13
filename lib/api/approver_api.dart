// lib/api/approver_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// ✅ เปลี่ยนตรงนี้ให้ตรงกับเครื่อง/อีมูเลเตอร์
// Emulator Android (AVD): http://10.0.2.2:3000
// LDPlayer/มือถือจริง:  http://<IP-คอม>:3000  เช่น http://192.168.1.196:3000
// const String BASE_URL = 'http://192.168.1.196:3000';
const String BASE_URL = 'http://192.168.50.51:3000';

class ApproverService {
  static Future<List<Map<String, dynamic>>> fetchPending() async {
    final url = Uri.parse('$BASE_URL/api/approver/pending');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final body = jsonDecode(res.body);
    if (body is List) return body.cast<Map<String, dynamic>>();
    return const [];
  }

  static Future<bool> approve(int historyId, int approverId) async {
    final url = Uri.parse('$BASE_URL/api/approver/approve');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'history_id': historyId, 'approver_id': approverId}),
    );
    if (res.statusCode != 200) return false;
    final m = jsonDecode(res.body);
    return m is Map && m['ok'] == true;
  }

  static Future<bool> reject(int historyId, int approverId, String reason) async {
    final url = Uri.parse('$BASE_URL/api/approver/reject');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'history_id': historyId,
        'approver_id': approverId,
        'reason': reason,
      }),
    );
    if (res.statusCode != 200) return false;
    final m = jsonDecode(res.body);
    return m is Map && m['ok'] == true;
  }
}
