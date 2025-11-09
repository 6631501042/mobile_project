import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HistoryApproverPage extends StatefulWidget {
  const HistoryApproverPage({super.key});

  @override
  State<HistoryApproverPage> createState() => _HistoryApproverPageState();
}

class _HistoryApproverPageState extends State<HistoryApproverPage> {
  // ✅ Use 10.0.2.2 for Android emulator; use your PC LAN IP for real device
  static const String baseUrl = 'http://10.0.2.2:3000';

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
    final roleName =
        prefs.getString('role_name'); // 👈 make sure you save this at login

    if (roleId == null) {
      return _HistoryResponse(
        items: const [],
        username: username ?? '—',
        roleIdText: '—',
      );
    }

    // 👇 is this account staff?
    final bool isStaff = roleName != null &&
        roleName.toLowerCase() == 'approver'; // adjust to your DB

    // 👇 use /api/staff/history for staff, old endpoint for normal users
    final Uri url = isStaff
        ? Uri.parse('$baseUrl/api/approver/history') // approver → see ALL history
        : Uri.parse(
            '$baseUrl/api/student/history/$roleId'); // USER → see OWN history

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to load history: ${res.statusCode} ${res.body}');
    }

    final List<dynamic> jsonList = json.decode(res.body);
    final items = jsonList
        .map((e) => HistoryItem(
              reqIdAndUser: (e['reqIdAndUser'] ?? '').toString(),
              roomCode: (e['roomCode'] ?? '').toString(),
              date: (e['date'] ?? '').toString(),
              time: (e['time'] ?? '').toString(),
              status: (e['status'] ?? '').toString(),
              approverName: (e['approverName'] ?? '—').toString(),
              rejectReason:
                  (e['rejectReason'] as String?)?.trim().isEmpty == true
                      ? null
                      : e['rejectReason'],
            ))
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
                    TopBar(titleRightText: topRight),
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
                    const BottomNavBar(),
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

// ================== TOP BAR ==================
class TopBar extends StatelessWidget {
  final String titleRightText;

  const TopBar({super.key, required this.titleRightText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFF51624F),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // remove color here if you want transparent background
                ),
                clipBehavior: Clip
                    .hardEdge, // makes sure the image is clipped to the circle
                child: Image.asset(
                  'assets/images/bird.png', // 👈 path to your image
                  fit: BoxFit.cover, // fills the circle nicely
                ),
              ),
              const SizedBox(width: 6),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ROOM\nRESERVATION",
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.1,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            titleRightText,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              // TODO
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Color(0xFFB52125),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "LOGOUT",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== HISTORY CARD (USER STYLE) ==================
class HistoryCardUser extends StatelessWidget {
  final HistoryItem item;
  const HistoryCardUser({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isApproved = item.status.toLowerCase() == "approved";
    final bool isRejected = item.status.toLowerCase() == "rejected";

    final Color pillBg =
        isApproved ? const Color(0xFFE4E9EE) : const Color(0xFFF4D6D5);
    final Color pillBorder =
        isApproved ? const Color(0xFF6D7A86) : const Color(0xFFB52125);
    final Color pillText =
        isApproved ? const Color(0xFF2D3A43) : const Color(0xFFB52125);

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

// ================== BOTTOM NAV BAR ==================
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFDCCB9D),
        border: Border(top: BorderSide(color: Color(0xFF2E2B20), width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIconButton(
                icon: Icons.home_outlined,
                onTap: () {
                  // TODO
                },
              ),
              _NavIconButton(
                icon: Icons.check_box_outlined,
                onTap: () {
                  // TODO
                },
              ),
              _NavIconButton(
                icon: Icons.history,
                onTap: () {
                  // TODO
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              SizedBox(width: 45),
              SizedBox(width: 45),
              _NavHighlightBar(),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.black, size: 28),
    );
  }
}

class _NavHighlightBar extends StatelessWidget {
  const _NavHighlightBar();

  @override
  Widget build(BuildContext context) {
    return Container(width: 40, height: 4, color: Color(0xFF2E2B20));
  }
}
