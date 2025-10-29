import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../modelsData/room_data.dart';
import '../screensOfBrowseRoomList/base_browse_screen.dart'; // ต้อง import base_browse_screen
import 'package:mobile_project/user/request_form.dart'; //มันคือ request form ของ user

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final String userName = '6631501xxx';
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
              // user name / logout button
              Row(
                children: [
                  Text(
                    userName,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {},
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
            HomeTab(userName: userName),
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
class HomeTab extends StatefulWidget {
  final String userName;
  const HomeTab({super.key, required this.userName});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  RoomSlot? selectedSlot;

  void _goToRequestForm(RoomSlot slot) {
    setState(() {
      selectedSlot = slot;
    });
  }

  void _backToList() {
    setState(() {
      selectedSlot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ถ้า selectedSlot != null แสดง RequestForm
    if (selectedSlot != null) {
      return RequestForm(
        roomName: selectedSlot!.room,
        initialSlot: selectedSlot!.timeSlots,
        onCancel: _backToList,
      );
    }

    // ถ้า selectedSlot == null แสดง BaseBrowseScreen
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

/// ===== THEME COLORS =====
class AppColors {
  static const finlandia = Color(0xFF51624F); // Top bar
  static const hampton = Color(0xFFE6D5A9); // Page background
  static const norway = Color(0xFFAFBEA2); // Logo circle bg
  static const edward = Color(0xFF9CB4AC); // Approved chip
  static const chipPending = Color(0xFFFDFD96); // Pending chip // 0xFFFBFB3C
  static const chipRejected = Color(0xFFFF9E9E); // Rejected chip
}

/// ===== MODEL =====
enum BookingStatus { pending, approved, rejected }

class UserReservation {
  final String roomCode;
  final DateTime date;
  final TimeOfDay start;
  final TimeOfDay end;
  final BookingStatus status;

  const UserReservation({
    required this.roomCode,
    required this.date,
    required this.start,
    required this.end,
    required this.status,
  });
}

/// ===== PAGE (USER) — Stateful =====
class StatusTab extends StatefulWidget {
  const StatusTab({super.key});

  @override
  State<StatusTab> createState() => _StatusTabState();
}

class _StatusTabState extends State<StatusTab> {
  late UserReservation _todayItem;

  @override
  void initState() {
    super.initState();
    _todayItem = UserReservation(
      // <- เอา const ออก
      roomCode: 'LR-104',
      date: DateTime(2025, 9, 28),
      start: const TimeOfDay(hour: 8, minute: 0),
      end: const TimeOfDay(hour: 10, minute: 0),
      status: BookingStatus.pending,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _todayItem;

    return Scaffold(
      backgroundColor: AppColors.hampton,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Title
              Text(
                'Status',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.92),
                ),
              ),
              const SizedBox(height: 18),

              // White card
              _ReservationCardUser(item: item),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===== WHITE CARD (USER VIEW) =====
class _ReservationCardUser extends StatelessWidget {
  final UserReservation item;
  const _ReservationCardUser({required this.item});

  @override
  Widget build(BuildContext context) {
    final dateStr = '${_dd(item.date)} ${_mon(item.date)} ${item.date.year}';
    String hhmm(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF2EDD9),
        border: Border.all(color: const Color(0xFF8E8A76), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 3),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.roomCode,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${hhmm(item.start)}-${hhmm(item.end)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // RIGHT: status chip
          _StatusChip(status: item.status),
        ],
      ),
    );
  }

  String _dd(DateTime d) => d.day.toString().padLeft(2, '0');
  String _mon(DateTime d) {
    const m = [
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
    ];
    return m[d.month];
  }
}

/// ===== STATUS CHIP =====
class _StatusChip extends StatelessWidget {
  final BookingStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color border;
    late String label;
    switch (status) {
      case BookingStatus.pending:
        bg = AppColors.chipPending;
        border = Color(0xFFA08A0D);
        label = 'Pending';
        break;
      case BookingStatus.approved:
        bg = AppColors.edward;
        label = 'Approved';
        break;
      case BookingStatus.rejected:
        bg = AppColors.chipRejected;
        label = 'Rejected';
        break;
    }
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Color(0xFFA08A0D),
        ),
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
        roomCode: "MR-104",
        date: "24 Sep 2025",
        time: "15.00-17.00",
        status: "Rejected",
        approverName: "Ajarn.Tick",
        rejectReason: "Room already booked by another department.",
      ),
      HistoryItem(
        reqIdAndUser: "6E3510/xxx Leo Jane",
        roomCode: "SR-101",
        date: "20 Sep 2025",
        time: "10.00-12.00",
        status: "Approved",
        approverName: "Ajarn.Tock",
      ),
      HistoryItem(
        reqIdAndUser: "6E3510/xxx Leo Jane",
        roomCode: "SR-106",
        date: "10 Sep 2025",
        time: "13.00-15.00",
        status: "Rejected",
        approverName: "Ajarn.Tock",
        rejectReason: "Room already booked by another department.",
      ),
      HistoryItem(
        reqIdAndUser: "6E3510/xxx Leo Jane",
        roomCode: "LR-105",
        date: "9 Sep 2025",
        time: "8.00-10.00",
        status: "Approved",
        approverName: "Ajarn.Tick",
      ),
      HistoryItem(
        reqIdAndUser: "6E3510/xxx Leo Jane",
        roomCode: "LR-105",
        date: "8 Sep 2025",
        time: "8.00-10.00",
        status: "Rejected",
        approverName: "Ajarn.Tick",
        rejectReason: "Room already booked by another department.",
      ),
      HistoryItem(
        reqIdAndUser: "6E3510/xxx Leo Jane",
        roomCode: "LR-105",
        date: "7 Sep 2025",
        time: "8.00-10.00",
        status: "Rejected",
        approverName: "Ajarn.Tick",
        rejectReason: "Room already booked by another department.",
      ),
      HistoryItem(
        reqIdAndUser: "6E3510/xxx Leo Jane",
        roomCode: "LR-105",
        date: "6 Sep 2025",
        time: "8.00-10.00",
        status: "Approved",
        approverName: "Ajarn.Tick",
      ),
      HistoryItem(
        reqIdAndUser: "6E3510/xxx Leo Jane",
        roomCode: "LR-105",
        date: "5 Sep 2025",
        time: "8.00-10.00",
        status: "Approved",
        approverName: "Ajarn.Tick",
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
                        child: HistoryCardUser(item: item),
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
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            '20',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              children: [
                _card(
                  'assets/images/free.png',
                  'Free Slots',
                  '5',
                  Colors.greenAccent[100]!,
                ),
                _card(
                  'assets/images/pending.png',
                  'Pending Slots',
                  '5',
                  Colors.amberAccent[100]!,
                ),
                _card(
                  'assets/images/reserve.png',
                  'Reserved Slots',
                  '7',
                  Colors.blueAccent[100]!,
                ),
                _card(
                  'assets/images/disable.png',
                  'Disabled Rooms',
                  '3',
                  Colors.redAccent[100]!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String img, String title, String value, Color color) {
    return Card(
      color: color,
      elevation: 4,
      child: InkWell(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(img, height: 60, fit: BoxFit.cover),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 16)),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
