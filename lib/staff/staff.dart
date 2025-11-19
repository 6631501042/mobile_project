import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_project/user/login.dart';
import '../modelsData/room_data.dart';
import '../screensOfBrowseRoomList/base_browse_screen.dart';
import 'package:mobile_project/staff/add_edit_form.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  final url = '192.168.50.51:3000';
  // final url = '172.27.10.98:3000';
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
              // staff name
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
class HomeTab extends StatefulWidget {
  final String userName;
  const HomeTab({super.key, required this.userName});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin<HomeTab> {
  bool isAdding = false;
  bool isEditing = false;
  RoomSlot? selectedSlot;
  void _selectAndEditSlot(RoomSlot slot) {
    setState(() {
      selectedSlot = slot;
      isEditing = true; // 🔥 เปิดฟอร์มทันที
      isAdding = false;
    });
  }

  @override
  bool get wantKeepAlive => true;
  Widget _buildActionButtons() {
    const Color addColor = Color(0xFFF09598);
    const Color editColor = Color(0xFF3F3735);

    return Container(
      // color: const Color(0xFFE6D5A9),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isAdding = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: addColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ElevatedButton(
                onPressed: selectedSlot == null
                    ? null // ✅ ปิดปุ่มถ้ายังไม่ได้เลือกห้อง
                    : () {
                        setState(() {
                          isEditing = true;
                          isAdding = false;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedSlot == null
                      ? Colors.grey
                      : editColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void resetEditState() {
    setState(() {
      isEditing = false;
      selectedSlot = null; // รีเซ็ตห้องที่เลือก
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // ✅ กรณี Add
    if (isAdding) {
      return AddEditForm(
        isEdit: false,
        onCancel: () {
          setState(() {
            isAdding = false;
          });
        },
      );
    }

    // กรณี Edit
    if (isEditing && selectedSlot != null) {
      return AddEditForm(
        isEdit: true,
        roomSlot: selectedSlot,
        roomId: selectedSlot!.no,
        onCancel: () {
          resetEditState(); // รีเซ็ตเฉพาะ Edit
        },
      );
    }

    // ✅ แสดง Browse ปกติ

    return BaseBrowseScreen(
      userRole: UserRole.staff,
      userName: widget.userName,
      actionButtons: _buildActionButtons(),
      // Callback สำหรับการแตะที่ตาราง (แค่เลือก)
      onSlotSelected: (slot) {
        setState(() {
          selectedSlot = slot;
        });
      },
      // Callback สำหรับหน้า Detail (เลือกและเปิดฟอร์ม)
      onSlotSelectedForDetail: _selectAndEditSlot,
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
  // ✅ Use 10.0.2.2 for Android emulator; use your PC LAN IP for real device
  static const String baseUrl = 'http://192.168.50.51:3000';
  // static const String baseUrl = 'http://172.27.10.98:3000';

  late Future<_HistoryResponse> _future;

  //--------------------------------------Demo--------------------------------------------
  // bool _isDemoStaff = false; // 👈 track if staff is logged in (toggle state)

  // // ✅ Toggle ON = login as staff, OFF = logout-----------------------------------------
  // Future<void> _setDemoRole(bool value) async {
  //   final prefs = await SharedPreferences.getInstance();

  //   if (value) {
  //     // ✅ ON → LOGIN as STAFF
  //     await prefs.setInt('role_id', 28); // fake staff id
  //     await prefs.setString('role_name', 'staff'); // must match your DB
  //     await prefs.setString('username', 'staff001'); // show name
  //     debugPrint("🟢 Logged in as staff");
  //   } else {
  //     // ❌ OFF → LOGOUT (clear prefs)
  //     await prefs.clear();
  //     debugPrint("🔴 Logged out (cleared prefs)");
  //   }

  //   // refresh screen
  //   setState(() {
  //     _isDemoStaff = value;
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
    final roleName = prefs.getString('role'); // 👈 make sure you save this at login

    if (roleId == null) {
      return _HistoryResponse(
        items: const [],
        username: username ?? '—',
        roleIdText: '—',
      );
    }

    // 👇 is this account staff?
    final bool isStaff =
        roleName != null &&
        roleName.toLowerCase() == 'staff'; // adjust to your DB

    // 👇 use /api/staff/history for staff, old endpoint for normal users
    final Uri url = isStaff
        ? Uri.parse('$baseUrl/api/staff/history') // STAFF → see ALL history
        : Uri.parse('$baseUrl/api/student/history/$roleId'); // USER → see OWN history

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
                              "History Staff",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 🟢 TOGGLE LOGIN BOX (NO const HERE)---------------------------------------------------------
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
                          //             _isDemoStaff
                          //                 ? "🟢 Logged in as Staff"
                          //                 : "🔴 Logged out",
                          //             style: const TextStyle(
                          //               fontSize: 12,
                          //               color: Colors.black,
                          //             ),
                          //           ),
                          //           Switch(
                          //             value: _isDemoStaff,
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
                          // 🟢 TOGGLE LOGIN BOX (NO const HERE)--------------------------------------------------
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
  final String url = '192.168.50.51:3000';
  // final String url = '172.27.10.98:3000';
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
                          'Free Rooms',
                          '$free',
                          const Color(0xFFA8E6CF), // green mint
                        ),
                        _card(
                          'assets/images/pending.png',
                          'Pending Rooms',
                          '$pending',
                          const Color(0xFFFFF59D), // soft yellow
                        ),
                        _card(
                          'assets/images/reserve.png',
                          'Reserved Rooms',
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
