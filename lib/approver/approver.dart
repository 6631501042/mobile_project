import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_project/user/login.dart';
import '../modelsData/room_data.dart';
import '../screensOfBrowseRoomList/base_browse_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Approver extends StatefulWidget {
  const Approver({super.key});

  @override
  State<Approver> createState() => _ApproverState();
}

class _ApproverState extends State<Approver> {
  final url = '192.168.50.51:3000';
  // final url = '172.27.7.238:3000';
  bool isWaiting = false;
  String username = '';
  List? rooms;

  void popDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(title: const Text('Error'), content: Text(message));
      },
    );
  }

  void getRooms() async {
    // get token from local storage
    final storage = await SharedPreferences.getInstance();
    String? token = storage.getString('token');
    if (token == null) {
      if (!mounted) return;
      // return to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const Login()),
      );
      return;
    }
    // decode token to get user info
    final user = jsonDecode(token);

    setState(() {
      isWaiting = true;
      username = user['username'];
    });

    // get all rooms
    try {
      Uri uri = Uri.http(url, '/api/role/rooms/:roomID');
      http.Response response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));
      // check server's response
      if (response.statusCode == 200) {
        rooms = jsonDecode(response.body);
      } else {
        popDialog(response.body);
      }
    } on TimeoutException catch (e) {
      debugPrint(e.message);
      if (!mounted) return;
      popDialog('Timeout error, try again!');
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      popDialog('Unknown error, try again!');
    } finally {
      setState(() {
        isWaiting = false;
      });
    }
  }

    void logout() async {
    // remove stored token
    final storage = await SharedPreferences.getInstance();
    await storage.remove('token');

    if (!mounted) return;
    // back to login, clear all history
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    getRooms();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFE6D5A9),
        // appbar
        appBar: AppBar(
          backgroundColor: const Color(0xFF476C5E),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // image bird
              Row(
                children: [
                  Image.asset('assets/images/bird.png', height: 50),
                  const SizedBox(width: 8),
                  const Text(
                    'ROOM \nRESERVATION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // staff name / logout button
              Row(
                children: [
                  Text(
                    username,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      minimumSize: Size(40, 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'LOGOUT',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // tab bar
        body: TabBarView(
          children: [
            // home
            HomeTab(userName: username),
            // status
            StatusTab(),
            // history
            HistoryTab(),
            // dashboard
            DashboardTab(),
          ],
        ),
        bottomNavigationBar: Container(
          color: const Color(0xFF476C5E),
          child: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.star), text: 'Status'),
              Tab(icon: Icon(Icons.schedule), text: 'History'),
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================
// home
// ==========================
class HomeTab extends StatelessWidget {
  final String userName;
  const HomeTab({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return BaseBrowseScreen(userRole: UserRole.user, userName: userName);
  }
}

// ==========================
// status
// ==========================

/// ========== THEME ==========
class C {
  static const finlandia = Color(0xFF51624F);
  static const hampton = Color(0xFFE6D5A9);
  static const norway = Color(0xFFAFBEA2);
  static const cardBg = Color(0xFFF9F5E5);

  // ปุ่ม Approve/Reject ให้เหมือนภาพ
  static const approveBg = Color(0xFFD9EBFF);
  static const approveBorder = Color(0xFF9BC3F8);
  static const approveText = Color(0xFF245B96);
  static const rejectBg = Color(0xFFFFD4D4);
  static const rejectBorder = Color(0xFFE89999);
  static const rejectText = Color(0xFF7F1F1F);
}

/// ========== DOMAIN ==========
enum RStatus { pending, approved, rejected }

class Reservation {
  final String id, userId, userName, roomCode;
  final DateTime date;
  final TimeOfDay start, end;
  final RStatus status;

  const Reservation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.roomCode,
    required this.date,
    required this.start,
    required this.end,
    required this.status,
  });

  Reservation copyWith({RStatus? status}) => Reservation(
    id: id,
    userId: userId,
    userName: userName,
    roomCode: roomCode,
    date: date,
    start: start,
    end: end,
    status: status ?? this.status,
  );
}

class RLog {
  final String reservationId, approverId;
  final RStatus result;
  final String? reason;
  final DateTime ts;
  const RLog({
    required this.reservationId,
    required this.approverId,
    required this.result,
    required this.ts,
    this.reason,
  });
}

/// ========== REPO (Mock) ==========
abstract class RRepo {
  Stream<List<Reservation>> watchPending(String approverId);
  Future<void> add(Reservation r);
  Future<void> set({
    required String id,
    required RStatus status,
    required String approverId,
    String? reason,
  });
}

class MockRepo implements RRepo {
  final _pendingCtrl = StreamController<List<Reservation>>.broadcast();
  final _logsCtrl = StreamController<List<RLog>>.broadcast();
  List<Reservation> _pending = [];
  List<RLog> _logs = [];

  MockRepo() {
    _pending = [
      Reservation(
        id: 'r1',
        userId: '6631501xxx',
        userName: 'Leo Jone',
        roomCode: 'LR-105',
        date: DateTime(2025, 9, 28),
        start: const TimeOfDay(hour: 8, minute: 0),
        end: const TimeOfDay(hour: 10, minute: 0),
        status: RStatus.pending,
      ),
      Reservation(
        id: 'r2',
        userId: '6631501xxx',
        userName: 'Lion Sins',
        roomCode: 'MR-110',
        date: DateTime(2025, 9, 28),
        start: const TimeOfDay(hour: 13, minute: 0),
        end: const TimeOfDay(hour: 15, minute: 0),
        status: RStatus.pending,
      ),
    ];
    _pendingCtrl.add(_pending);
    _logsCtrl.add(const []);
  }

  @override
  Stream<List<Reservation>> watchPending(String _) => _pendingCtrl.stream;

  @override
  Future<void> add(Reservation r) async {
    _pending = [..._pending, r];
    _pendingCtrl.add(_pending);
  }

  @override
  Future<void> set({
    required String id,
    required RStatus status,
    required String approverId,
    String? reason,
  }) async {
    _pending.removeWhere((e) => e.id == id);
    _pendingCtrl.add(List.unmodifiable(_pending));
    _logs = [
      ..._logs,
      RLog(
        reservationId: id,
        approverId: approverId,
        result: status,
        ts: DateTime.now(),
        reason: reason,
      ),
    ];
    _logsCtrl.add(List.unmodifiable(_logs));
  }
}

/// ========== ENTRY (ใช้ใน main.dart) ==========
class StatusTab extends StatelessWidget {
  const StatusTab({super.key});
  @override
  Widget build(BuildContext context) =>
      const ApproverPage(approverId: 'teacher-001', approverName: 'Ajarn.Tick');
}

/// ========== PAGE (ไม่มี TopBar แล้ว) ==========
class ApproverPage extends StatefulWidget {
  final String approverId, approverName;
  const ApproverPage({
    super.key,
    required this.approverId,
    required this.approverName,
  });
  @override
  State<ApproverPage> createState() => _ApproverPageState();
}

class _ApproverPageState extends State<ApproverPage> {
  late final RRepo repo;
  int _seed = 3;

  @override
  void initState() {
    super.initState();
    repo = MockRepo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.hampton,

      // ❌ ไม่มี appBar / TopBar แล้วตามที่ขอ
      // ✅ คง FAB "+ Add mock request" ไว้
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: C.norway,
        icon: const Icon(Icons.add),
        label: const Text('Add mock request'),
        onPressed: _addMock,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // เติมระยะบน ~ เท่า AppBar เดิม เพื่อไม่ให้ตำแหน่งเลื่อน

              const Center(
                child: Text(
                  'Status',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 18),

              const _HeaderRow(),
              const SizedBox(height: 10),

              Expanded(
                child: StreamBuilder<List<Reservation>>(
                  stream: repo.watchPending(widget.approverId),
                  builder: (_, s) {
                    final items = s.data ?? const <Reservation>[];
                    if (items.isEmpty) {
                      return const Center(child: Text('No pending requests'));
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _Card(
                        r: items[i],
                        onApprove: () async {
                          await repo.set(
                            id: items[i].id,
                            status: RStatus.approved,
                            approverId: widget.approverId,
                          );
                          if (!mounted) return;
                          _toast('${items[i].roomCode} • Approved');
                        },
                        onReject: (reason) async {
                          await repo.set(
                            id: items[i].id,
                            status: RStatus.rejected,
                            approverId: widget.approverId,
                            reason: reason,
                          );
                          if (!mounted) return;
                          _toast(
                            '${items[i].roomCode} • Rejected\nReason: $reason',
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              const Divider(thickness: 1),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _addMock() async {
    final id = 'r${_seed++}';
    final start = 9 + (_seed % 6) * 2;
    await repo.add(
      Reservation(
        id: id,
        userId: '66315${_seed}xxx',
        userName: _seed.isEven ? 'Eren Yeager' : 'Mikasa Ackerman',
        roomCode: _seed.isEven ? 'LR-10$_seed' : 'MR-11$_seed',
        date: DateTime(2025, 9, 28),
        start: TimeOfDay(hour: start, minute: 0),
        end: TimeOfDay(hour: start + 2, minute: 0),
        status: RStatus.pending,
      ),
    );
  }
}

/// ========== UI CHUNKS ==========
class _HeaderRow extends StatelessWidget {
  const _HeaderRow();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: const [
      Text(
        'User/Room',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
      ),
      Text(
        'Action',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _Card extends StatelessWidget {
  final Reservation r;
  final Future<void> Function() onApprove;
  final Future<void> Function(String reason) onReject;
  const _Card({
    // super.key,
    required this.r,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = '${_two(r.date.day)} ${_mon(r.date.month)} ${r.date.year}';
    String t(TimeOfDay x) => '${x.hour}.${_two(x.minute)}';

    return Container(
      decoration: BoxDecoration(
        color: C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${r.userId}  ${r.userName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  r.roomCode,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black.withOpacity(0.45),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${t(r.start)}-${t(r.end)}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black.withOpacity(0.45),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Pill.approve('Approve', onApprove),
              const SizedBox(height: 10),
              _Pill.reject('Reject', () async {
                final reason = await _askReason(context);
                if (reason == null || reason.isEmpty) return;
                await onReject(reason);
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Future<void> Function() onTap;
  final Color bg, border, text;
  const _Pill._(this.label, this.onTap, this.bg, this.border, this.text);

  factory _Pill.approve(String label, Future<void> Function() onTap) =>
      _Pill._(label, onTap, C.approveBg, C.approveBorder, C.approveText);

  factory _Pill.reject(String label, Future<void> Function() onTap) =>
      _Pill._(label, onTap, C.rejectBg, C.rejectBorder, C.rejectText);

  @override
  Widget build(BuildContext context) => Material(
    color: bg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: border, width: 1.4),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async => await onTap(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: text,
          ),
        ),
      ),
    ),
  );
}

/// ========== UTIL ==========
String _two(int v) => v.toString().padLeft(2, '0');
String _mon(int m) => const [
  '',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][m];

Future<String?> _askReason(BuildContext context) => showDialog<String>(
  context: context,
  barrierDismissible: false,
  builder: (ctx) {
    final c = TextEditingController();
    return AlertDialog(
      title: const Text('Reason for rejection'),
      content: TextField(
        controller: c,
        autofocus: true,
        maxLines: 2,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          hintText: 'Type reason…',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(c.text.trim()),
          child: const Text('Reject'),
        ),
      ],
    );
  },
);

// ==========================
// history
// ==========================
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  // mock data list (will be rendered in a loop)
  List<HistoryItem> _mockData() {
    return [
      HistoryItem(
        reqIdAndUser: "6E3510/xxx Leo Jane",
        roomCode: "LR-105",
        date: "28 Sep 2025",
        time: "08.00-10.00",
        status: "Approved",
        approverName: "Ajarn.Tick",
      ),
      HistoryItem(
        reqIdAndUser: "6E3510/xxx Leo Jane",
        roomCode: "LR-104",
        date: "24 Sep 2025",
        time: "15.00-17.00",
        status: "Rejected",
        approverName: "Ajarn.Tick",
        rejectReason: "Room already booked by another department.",
      ),
      HistoryItem(
        reqIdAndUser: "6E3510/xxx Lion Sins",
        roomCode: "MR-101",
        date: "20 Sep 2025",
        time: "10.00-12.00",
        status: "Approved",
        approverName: "Ajarn.Tock",
      ),
      HistoryItem(
        reqIdAndUser: "6E3510/xxx Nick Sakon",
        roomCode: "SR-110",
        date: "1 Sep 2025",
        time: "13.00-15.00",
        status: "Rejected",
        approverName: "Ajarn.Tock",
        rejectReason: "Room already booked by another department.",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dataList = _mockData();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 360,
            color: const Color(0xFFE6D5A9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Center(
                        child: Text(
                          "History Approver",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Room",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Action",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // list section
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      final item = dataList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HistoryCardApprover(item: item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================== DATA MODEL ==================
class HistoryItem {
  final String reqIdAndUser;
  final String roomCode;
  final String date;
  final String time;
  final String status;
  final String approverName;
  final String? rejectReason;

  HistoryItem({
    required this.reqIdAndUser,
    required this.roomCode,
    required this.date,
    required this.time,
    required this.status,
    required this.approverName,
    this.rejectReason,
  });
}

// ================== HISTORY CARD (APPROVER STYLE) ==================
class HistoryCardApprover extends StatelessWidget {
  final HistoryItem item;
  const HistoryCardApprover({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isApproved = item.status.toLowerCase() == "approved";
    final bool isRejected = item.status.toLowerCase() == "rejected";

    final Color pillBg = isApproved
        ? const Color(0xFFE4E9EE)
        : const Color(0xFFF4D6D5);
    final Color pillBorder = isApproved
        ? const Color(0xFF6D7A86)
        : const Color(0xFFB52125);
    final Color pillText = isApproved
        ? const Color(0xFF2D3A43)
        : const Color(0xFFB52125);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2EDD9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF8E8A76), width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 3),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // main row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoText(item.reqIdAndUser, bold: true),
                    _infoText(item.roomCode, bold: true),
                    _infoText(item.date),
                    _infoText(item.time),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: pillBorder, width: 1),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: pillText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "By",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  Text(
                    item.approverName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (isRejected) ...[
            const SizedBox(height: 8),
            const Text(
              "Reason for Rejection:",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB52125),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                item.rejectReason ?? "No reason provided",
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoText(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontSize: 16,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ==========================
// dashboard
// ==========================
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final String url = '192.168.50.51:3000';
  bool isLoading = true;
  int free = 0;
  int pending = 0;
  int reserved = 0;
  int disable = 0;

  @override
  void initState() {
    super.initState();
    fetchSummary();
    // auto refresh every 10 sec
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) fetchSummary();
    });
  }

  Future<void> fetchSummary() async {
    try {
      Uri uri = Uri.http(url, '/api/rooms/status');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          free = int.tryParse(data['free'].toString()) ?? 0;
          pending = int.tryParse(data['pending'].toString()) ?? 0;
          reserved = int.tryParse(data['reserved'].toString()) ?? 0;
          disable = int.tryParse(data['disable'].toString()) ?? 0;
          isLoading = false;
        });
      } else {
        debugPrint("Server error: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout - server not responding");
    } catch (e) {
      debugPrint("Error fetching summary: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D5A9),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E3B31),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${free + pending + reserved + disable}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E3B31),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _card(
                          'assets/images/free.png',
                          'Free Slots',
                          '$free',
                          const Color(0xFFA8E6CF), // green mint
                        ),
                        _card(
                          'assets/images/pending.png',
                          'Pending Slots',
                          '$pending',
                          const Color(0xFFFFF59D), // soft yellow
                        ),
                        _card(
                          'assets/images/reserve.png',
                          'Reserved Slots',
                          '$reserved',
                          const Color(0xFF81D4FA), // light blue
                        ),
                        _card(
                          'assets/images/disable.png',
                          'Disabled Rooms',
                          '$disable',
                          const Color(0xFFEF9A9A), // soft red
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _card(String img, String title, String value, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: () => fetchSummary(), // tap to refresh
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(img, height: 60, fit: BoxFit.cover),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
