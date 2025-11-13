import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_project/user/login.dart';
import '../modelsData/room_data.dart';
import '../screensOfBrowseRoomList/base_browse_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_project/api/approver_api.dart';

class Approver extends StatefulWidget {
  const Approver({super.key});

  @override
  State<Approver> createState() => _ApproverState();
}

class _ApproverState extends State<Approver> {
  // final url = '192.168.50.51:3000';
  final url = '172.27.10.98:3000';
  bool isWaiting = false;
  String username = '';
  String approverId = '';
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
    print('Decoded user: $user'); // debug print

    setState(() {
      isWaiting = true;
      username = user['username'];
      approverId = user['id'].toString(); // 👈 assign approver ID from token
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
            StatusTab(approverId: approverId),
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
class StatusTab extends StatefulWidget {
  final String approverId; // ใส่เป็น string ของเลข id เช่น '29'
  const StatusTab({super.key, required this.approverId});

  @override
  State<StatusTab> createState() => _StatusTabState();
}

class _StatusTabState extends State<StatusTab> {
  bool loading = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => loading = true);
    try {
      final data = await ApproverService.fetchPending();
      setState(() => items = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Loading list failed: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _approve(Map<String, dynamic> row) async {
    final hid = int.tryParse(row['history_id'].toString()) ?? -1;
    final aid = int.tryParse(widget.approverId) ?? -1;

    // optimistic UI
    final old = List<Map<String, dynamic>>.from(items);
    setState(
      () => items.removeWhere(
        (e) => e['history_id'].toString() == row['history_id'].toString(),
      ),
    );

    final ok = await ApproverService.approve(hid, aid);
    if (!ok) {
      setState(() => items = old); // rollback
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Approve ไม่สำเร็จ')));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Approved: ${row['roomCode']}')));
  }

  // ✅ รับ reason มาจากการ์ด (ไม่ถามซ้ำ)
  Future<void> _reject(Map<String, dynamic> row, String reason) async {
    if (reason.isEmpty) return;

    final hid = int.tryParse(row['history_id'].toString()) ?? -1;
    final aid = int.tryParse(widget.approverId) ?? -1;

    final old = List<Map<String, dynamic>>.from(items);
    setState(
      () => items.removeWhere(
        (e) => e['history_id'].toString() == row['history_id'].toString(),
      ),
    );

    final ok = await ApproverService.reject(hid, aid, reason);
    if (!ok) {
      setState(() => items = old); // rollback
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reject ไม่สำเร็จ')));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected: ${row['roomCode']}\nReason: $reason')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D5A9), // Hampton
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            children: [
              const Center(
                child: Text(
                  'Status',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'User/Room',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Action',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  // child: Center(child: Text('No pending requests')),
                )
              else
                ...items.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 15.0,), // ⬅️ space between cards
                    child: _ItemCard(
                      requester: (row['requesterName'] ?? '').toString(),
                      roomCode: (row['roomCode'] ?? '').toString(),
                      date: (row['date'] ?? '').toString(),
                      timeslot: (row['timeslot'] ?? '').toString(),
                      onApprove: () => _approve(row),
                      onReject: (reason) => _reject(row, reason),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String requester, roomCode, date, timeslot;
  final Future<void> Function() onApprove;
  final Future<void> Function(String reason) onReject; // ✅ รับ reason

  const _ItemCard({
    required this.requester,
    required this.roomCode,
    required this.date,
    required this.timeslot,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EDD9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF8E8A76), width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 3),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ LEFT: Request details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  requester,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  roomCode,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.9),
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  timeslot,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ✅ RIGHT: Buttons and/or status pill
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 🟢 Approve button
              _pill(
                label: 'Approve',
                bg: const Color(0xFFE4E9EE),
                border: const Color(0xFF6D7A86),
                text: const Color(0xFF2D3A43),
                onTap: () async {
                  final ok = await _confirmApprove(
                    context,
                    roomCode,
                    date,
                    timeslot,
                    requester,
                  );
                  if (ok) await onApprove();
                },
              ),
              const SizedBox(height: 8),

              // 🔴 Reject button
              _pill(
                label: 'Reject',
                bg: const Color(0xFFF4D6D5),
                border: const Color(0xFFB52125),
                text: const Color(0xFFB52125),
                onTap: () async {
                  final reason = await _askReason(context);
                  if (reason == null || reason.isEmpty) return;
                  await onReject(reason);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _pill({
    required String label,
    required Color bg,
    required Color border,
    required Color text,
    required Future<void> Function() onTap,
  }) {
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: border, width: 1.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
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
}

// ===== dialogs =====
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

Future<bool> _confirmApprove(
  BuildContext context,
  String room,
  String date,
  String timeslot,
  String user,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm approval'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Approve this reservation?'),
          const SizedBox(height: 8),
          Text('User : $user'),
          Text('Room : $room'),
          Text('Date : $date'),
          Text('Time : $timeslot'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Confirm'),
        ),
      ],
    ),
  ).then((v) => v ?? false);
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
  // ✅ Use 10.0.2.2 for Android emulator; use your PC LAN IP for real device
  // static const String baseUrl = 'http://192.168.50.51:3000';
  static const String baseUrl = 'http://172.27.10.98:3000';

  late Future<_HistoryResponse> _future;

  //--------------------------------------Demo--------------------------------------------
  // bool _isDemoApprover = false; // 👈 track if approver is logged in (toggle state)

  // // ✅ Toggle ON = login as staff, OFF = logout-----------------------------------------
  // Future<void> _setDemoRole(bool value) async {
  //   final prefs = await SharedPreferences.getInstance();

  //   if (value) {
  //     // ✅ ON → LOGIN as approver
  //     await prefs.setInt('role_id', 29); // fake approver id
  //     await prefs.setString('role_name', 'approver'); // must match your DB
  //     await prefs.setString('username', 'approver001'); // show name
  //     debugPrint("🟢 Logged in as approver");
  //   } else {
  //     // ❌ OFF → LOGOUT (clear prefs)
  //     await prefs.clear();
  //     debugPrint("🔴 Logged out (cleared prefs)");
  //   }

  //   // refresh screen
  //   setState(() {
  //     _isDemoApprover = value;
  //     _future = _fetchHistory(); // reload data
  //   });
  // }
  //----------------------------------------Demo------------------------------------------

  @override
  void initState() {
    super.initState();
    _future = _fetchHistory();
  }

  Future<_HistoryResponse> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final roleId = prefs.getInt('role_id');
    final username = prefs.getString('username');
    final roleName = prefs.getString(
      'role',
    ); // 👈 make sure you save this at login

    if (roleId == null) {
      return _HistoryResponse(
        items: const [],
        username: username ?? '—',
        roleIdText: '—',
      );
    }

    // 👇 is this account approver?
    final bool isApprover =
        roleName != null &&
        roleName.toLowerCase() == 'approver'; // adjust to your DB

    // 👇 use /api/approver/history for approver, old endpoint for normal users
    final Uri url = isApprover
        ? Uri.parse(
            '$baseUrl/api/approver/history',
          ) // approver → see ALL history
        : Uri.parse(
            '$baseUrl/api/student/history/$roleId',
          ); // USER → see OWN history

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
            approverName: (e['approverName'] ?? '—').toString(),
            rejectReason: (e['rejectReason'] as String?)?.trim().isEmpty == true
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

        String topRight = "—";
        List<HistoryItem> dataList = const [];

        if (snap.hasError) {
          topRight = "Error";
        } else if (snap.hasData) {
          topRight = snap.data!.username.isNotEmpty
              ? snap.data!.username
              : snap.data!.roleIdText;
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          const Center(
                            child: Text(
                              "History Approver",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 🟢 TOGGLE LOGIN BOX (NO const HERE)---------------------------------------------------------------
                          // Container(
                          //   width: double.infinity,
                          //   padding: const EdgeInsets.all(10),
                          //   margin: const EdgeInsets.only(bottom: 12),
                          //   decoration: BoxDecoration(
                          //     color: const Color(0xFFF2EDD9),
                          //     borderRadius: BorderRadius.circular(8),
                          //     border: Border.all(
                          //         color: const Color(0xFF8E8A76), width: 1),
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       const Text(
                          //         "Demo Login Toggle",
                          //         style: TextStyle(
                          //           fontSize: 14,
                          //           fontWeight: FontWeight.w700,
                          //           color: Colors.black,
                          //         ),
                          //       ),
                          //       const SizedBox(height: 6),
                          //       Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           Text(
                          //             _isDemoApprover
                          //                 ? "🟢 Logged in as approver"
                          //                 : "🔴 Logged out",
                          //             style: const TextStyle(
                          //               fontSize: 12,
                          //               color: Colors.black,
                          //             ),
                          //           ),
                          //           Switch(
                          //             value: _isDemoApprover,
                          //             onChanged: (value) => _setDemoRole(value),
                          //             activeColor: const Color(0xFF51624F),
                          //           ),
                          //         ],
                          //       ),
                          //       const Text(
                          //         "Toggle ON to login as staff, OFF to logout.",
                          //         style: TextStyle(
                          //           fontSize: 10,
                          //           color: Colors.black54,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // 🟢 TOGGLE LOGIN BOX (NO const HERE)----------------------------------------------------------
                          // Table header
                          Row(
                            children: const [
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

// ==========================
// dashboard
// ==========================
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  // final String url = '192.168.50.51:3000';
  final String url = '172.27.10.98:3000';
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
