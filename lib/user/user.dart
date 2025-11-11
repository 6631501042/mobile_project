import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_project/user/login.dart';
import '../modelsData/room_data.dart';
import '../screensOfBrowseRoomList/base_browse_screen.dart';
import '../services/api_service.dart';
import 'package:mobile_project/user/request_form.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final url = '192.168.50.51:3000';
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
    // final user = jsonDecode(token);

    setState(() {
      isWaiting = true;
      username = storage.getString('username') ?? '';
      // username = user['username'];
    });

    await Future.delayed(const Duration(milliseconds: 300)); // เผื่อเวลาสั้นๆ
    setState(() {
      isWaiting = false;
    });
    try {
      final result = await ApiService.getRooms();
      setState(() {
        rooms = result;
      });
    } catch (e) {
      popDialog('Failed to load rooms: $e');
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
      length: 3,
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
              // user name
              Row(
                children: [
                  Text(
                    username,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  // logout button
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
class HomeTab extends StatefulWidget {
  final String userName;
  const HomeTab({super.key, required this.userName});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  RoomSlot? selectedSlot;

  void _goToRequestForm(RoomSlot slot) => setState(() => selectedSlot = slot);
  void _backToList() => setState(() => selectedSlot = null);

  @override
  Widget build(BuildContext context) {
    if (selectedSlot != null) {
      return RequestForm(
        roomId: selectedSlot!.no,
        roomName: selectedSlot!.room,
        initialSlot: selectedSlot!.timeSlots,// จาก DB เช่น "08.00-10.00"
        //isInitiallyFree: (selectedSlot!.status == "Free"),
        onCancel: _backToList,
      );
    }
    return BaseBrowseScreen(
      userRole: UserRole.user,
      userName: widget.userName,
      actionButtons: null,
      onSlotSelected: _goToRequestForm,
    );
  }
}

// ==========================
// status
// ==========================
// ========== Status (โหลดรายการจองของฉัน) ==========
class StatusTab extends StatefulWidget {
  const StatusTab({super.key});
  @override
  State<StatusTab> createState() => _StatusTabState();
}

class _StatusTabState extends State<StatusTab> {
  late Future<List<RoomSlot>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<RoomSlot>> _load() async {
    final sp = await SharedPreferences.getInstance();
    final roleId = sp.getInt('role_id') ?? 24;
    final list = await ApiService.getMyHistory(roleId);
    return list.map((e) => RoomSlot.fromJson(e)).toList();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<RoomSlot>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 80),
                Center(child: Text('Error: ${snap.error}')),
              ],
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                Center(
                  child: Text(
                    'No reservations yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final r = items[i];
              final status = r.status.toLowerCase();

              // ✅ Define colors for each status
              final bool isApproved = status == "approved";
              final bool isRejected = status == "rejected";
              final bool isPending = status == "pending";

              final Color pillBg = isApproved
                  ? const Color(0xFFE4E9EE) // Light gray-blue
                  : isRejected
                      ? const Color(0xFFF4D6D5) // Soft red
                      : const Color(0xFFFFF4C4); // 🟡 Yellow for pending

              final Color pillBorder = isApproved
                  ? const Color(0xFF6D7A86)
                  : isRejected
                      ? const Color(0xFFB52125)
                      : const Color(0xFFF6C12A);

              final Color pillText = isApproved
                  ? const Color(0xFF2D3A43)
                  : isRejected
                      ? const Color(0xFFB52125)
                      : const Color(0xFF8A6D00);

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EDD9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF8E8A76), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.room,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Timeslot: ${r.timeSlots}'),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: pillBorder, width: 1.5),
                      ),
                      child: Text(
                        r.status,
                        style: TextStyle(
                          color: pillText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================
// history
// ==========================
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  static const String baseUrl = 'http://192.168.50.51:3000';

  late Future<_HistoryResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchHistory();
  }

  Future<_HistoryResponse> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final roleId = prefs.getInt('role_id');
    final username = prefs.getString('username');
    // final username = prefs.getString('username');

    if (roleId == null) {
      // no login info yet
      return _HistoryResponse(
        items: const [],
        username: username ?? '—',
        roleIdText: '—',
      );
    }

    final url = Uri.parse('$baseUrl/api/student/history/$roleId');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to load history: ${res.statusCode} ${res.body}');
    }

    final List<dynamic> jsonList = json.decode(res.body);
    final items = jsonList
        .map(
          (e) => HistoryItem(
            reqIdAndUser: (e['reqIdAndUser'] ?? '').toString(),
            roomCode: (e['roomCode'] ?? '').toString(),
            date: (e['date'] ?? '').toString(),
            time: (e['time'] ?? '').toString(),
            status: (e['status'] ?? '').toString(),
            approverName: (e['approverName'] ?? '').toString(),
            rejectReason: ((e['rejectReason'] ?? '') as String).trim().isEmpty
                ? null
                : e['rejectReason'],
          ),
        )
        .toList();

    return _HistoryResponse(
      items: items,
      username: username ?? '—',
      roleIdText: roleId.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HistoryResponse>(
      future: _future, // ✅ use the field, not _fetchHistory()
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        // String topRight = "—";
        List<HistoryItem> dataList = const [];

        if (snap.hasData) {
          // topRight = snap.data!.username.isNotEmpty
          // ? snap.data!.username
          // : snap.data!.roleIdText;
          dataList = snap.data!.items;
        }

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
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "History User",
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
                            child: HistoryCardUser(
                              item: item,
                            ), // your original card
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
      },
    );
  }
}

class _HistoryResponse {
  final List<HistoryItem> items;
  final String username;
  final String roleIdText;
  _HistoryResponse({
    required this.items,
    required this.username,
    required this.roleIdText,
  });
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

// ================== HISTORY CARD (USER STYLE) ==================
class HistoryCardUser extends StatelessWidget {
  final HistoryItem item;
  const HistoryCardUser({super.key, required this.item});

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
          // main row (left info + right status)
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
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

          // 👇 move the reason section OUTSIDE the Row
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
