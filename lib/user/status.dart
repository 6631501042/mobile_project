// ---------------------------------------------
// SECTION 0: Imports
// ---------------------------------------------
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const RoomReservationApp());
}

// ---------------------------------------------
// SECTION 1: Theme & Constants (สีตามที่ให้ไว้)
// ---------------------------------------------
class AppColors {
  static const finlandia = Color(0xFF51624F); // Top bar
  static const hampton   = Color(0xFFE6D5A9); // Background
  static const norway    = Color(0xFFAFBEA2); // ปุ่ม/แอคเซ็นต์เย็น ๆ
  static const edward    = Color(0xFF9CB4AC); // ปุ่ม Approve
  static const chipRejected = Color(0xFFFF9E9E); // ปุ่ม Reject (ชมพูอมแดง)
  static const cardBg    = Color(0xFFF9F5E5); // พื้นการ์ดอ่อน ๆ
}

// ---------------------------------------------
// SECTION 2: Domain Models (สำหรับต่อยอด DB)
// ---------------------------------------------
enum ReservationStatus { pending, approved, rejected }

class Reservation {
  final String id;
  final String userId;
  final String userName;
  final String roomCode;
  final DateTime date;
  final TimeOfDay start;
  final TimeOfDay end;
  final ReservationStatus status;

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

  Reservation copyWith({
    ReservationStatus? status,
  }) =>
      Reservation(
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

// ---------------------------------------------
// SECTION 3: Repository Layer (เปลี่ยนเป็น Firestore/REST ทีหลังได้เลย)
// ---------------------------------------------
abstract class ReservationRepository {
  Stream<List<Reservation>> watchApproverQueue(String approverId);
  Future<void> updateStatus({
    required String reservationId,
    required ReservationStatus status,
  });
}

/// Mock สำหรับเดโม — ภายหลังสลับเป็น Firestore ได้ทันที
class MockReservationRepository implements ReservationRepository {
  MockReservationRepository() {
    _data = [
      Reservation(
        id: 'r1',
        userId: '6631501xxx',
        userName: 'Leo Jone',
        roomCode: 'LR-105',
        date: DateTime(2025, 9, 28),
        start: const TimeOfDay(hour: 8, minute: 0),
        end: const TimeOfDay(hour: 10, minute: 0),
        status: ReservationStatus.pending,
      ),
      Reservation(
        id: 'r2',
        userId: '6631501xxx',
        userName: 'Lion Sins',
        roomCode: 'MR-110',
        date: DateTime(2025, 9, 28),
        start: const TimeOfDay(hour: 13, minute: 0),
        end: const TimeOfDay(hour: 15, minute: 0),
        status: ReservationStatus.pending,
      ),
    ];
    _controller.add(_data);
  }

  late List<Reservation> _data;
  final _controller = StreamController<List<Reservation>>.broadcast();

  @override
  Stream<List<Reservation>> watchApproverQueue(String approverId) {
    // ปกติ filter ด้วย approverId; เดโมส่งทั้งก้อน
    return _controller.stream;
  }

  @override
  Future<void> updateStatus({
    required String reservationId,
    required ReservationStatus status,
  }) async {
    _data = _data
        .map((e) => e.id == reservationId ? e.copyWith(status: status) : e)
        .toList();
    _controller.add(_data);
  }
}

// ---------------------------------------------
// SECTION 4: App Root + Routing
// ---------------------------------------------
class RoomReservationApp extends StatelessWidget {
  const RoomReservationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Reservation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.hampton,
        primaryColor: AppColors.finlandia,
        fontFamily: 'Roboto',
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color(0xFF202020),
              displayColor: const Color(0xFF202020),
            ),
      ),
      home: const ApproverStatusPage(
        approverName: 'Ajarn.Tick',
        approverId: 'teacher-001',
      ),
    );
  }
}

// ---------------------------------------------
// SECTION 5: Approver Status Page (ตามภาพ)
//  - Title "Status" อยู่ตรงกลาง
//  - หัวคอลัมน์ "User/Room" (ซ้าย) และ "Action" (ขวา)
//  - ในการ์ด แสดง userId + userName, room, date/time
//  - ปุ่ม Approve/Reject ด้านขวาเหมือนภาพ
// ---------------------------------------------
class ApproverStatusPage extends StatefulWidget {
  final String approverName;
  final String approverId;

  const ApproverStatusPage({
    super.key,
    required this.approverName,
    required this.approverId,
  });

  @override
  State<ApproverStatusPage> createState() => _ApproverStatusPageState();
}

class _ApproverStatusPageState extends State<ApproverStatusPage> {
  late final ReservationRepository repo;

  @override
  void initState() {
    super.initState();
    repo = MockReservationRepository(); // 🔁 สลับเป็น FirestoreRepository ภายหลัง
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hampton,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: _TopBar(approverName: widget.approverName),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // ---- Title "Status" ให้อยู่ตรงกลางแบบชัดเจน ----
              Center(
                child: Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.92),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // ---- Column headers: User/Room | Action ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HeaderText('User/Room'),
                  _HeaderText('Action'),
                ],
              ),
              const SizedBox(height: 10),
              // ---- List ----
              Expanded(
                child: StreamBuilder<List<Reservation>>(
                  stream: repo.watchApproverQueue(widget.approverId),
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? const <Reservation>[];
                    if (items.isEmpty) {
                      return const Center(child: Text('No pending requests'));
                    }
                    return ListView.separated(
                      itemBuilder: (_, i) => ApproverReservationCard(
                        data: items[i],
                        onApprove: () => repo.updateStatus(
                          reservationId: items[i].id,
                          status: ReservationStatus.approved,
                        ),
                        onReject: () => repo.updateStatus(
                          reservationId: items[i].id,
                          status: ReservationStatus.rejected,
                        ),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemCount: items.length,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const _BottomBar(active: BottomTab.check),
              const SizedBox(height: 8),
              const Divider(thickness: 1),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------
// SECTION 6: Widgets (TopBar, Card, BottomBar)
// ---------------------------------------------
class _TopBar extends StatelessWidget {
  final String approverName;
  const _TopBar({required this.approverName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.finlandia,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.norway,
                child: const Text('🐦', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ROOM',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5)),
                  Text('RESERVATION',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5)),
                ],
              ),
              const Spacer(),
              Text(
                approverName,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(width: 10),
              _LogoutPill(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutPill extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogoutPill({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD94B4B),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'LOGOUT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.black.withOpacity(0.9),
        ));
  }
}

/// การ์ดหนึ่งใบ (เหมือนภาพ: มุมโค้ง เงาอ่อน ๆ เส้นขอบ)
class ApproverReservationCard extends StatelessWidget {
  final Reservation data;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApproverReservationCard({
    super.key,
    required this.data,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_two(data.date.day)} ${_month(data.date.month)} ${data.date.year}';
    String t(TimeOfDay x) => '${x.hour}.${_two(x.minute)}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Left: User/Room/DateTime ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // userId + name (ตัวเล็กเหมือนภาพ)
                Text(
                  '${data.userId}  ${data.userName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                // room (เด่น)
                Text(
                  data.roomCode,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                // date + time (เทาอ่อน)
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
                  '${t(data.start)}-${t(data.end)}',
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
          // ---- Right: Action buttons (Approve + Reject) ----
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ActionButton.primary(
                label: 'Approve',
                onTap: onApprove,
              ),
              const SizedBox(height: 10),
              _ActionButton.danger(
                label: 'Reject',
                onTap: onReject,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _two(int v) => v.toString().padLeft(2, '0');
  String _month(int m) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[m];
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bg;
  final Color textColor;

  const _ActionButton._({
    required this.label,
    required this.onTap,
    required this.bg,
    required this.textColor,
  });

  factory _ActionButton.primary({
    required String label,
    required VoidCallback onTap,
  }) =>
      _ActionButton._(
        label: label,
        onTap: onTap,
        bg: AppColors.edward,
        textColor: Colors.black87,
      );

  factory _ActionButton.danger({
    required String label,
    required VoidCallback onTap,
  }) =>
      _ActionButton._(
        label: label,
        onTap: onTap,
        bg: AppColors.chipRejected,
        textColor: Colors.black87,
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

enum BottomTab { home, clock, check, grid }

class _BottomBar extends StatelessWidget {
  final BottomTab active;
  const _BottomBar({required this.active});

  @override
  Widget build(BuildContext context) {
    Widget icon(IconData i, BottomTab t,
        {bool highlight = false, EdgeInsets? pad}) {
      final child = Icon(i, size: 36, color: Colors.black.withOpacity(0.85));
      return Container(
        decoration: t == active
            ? BoxDecoration(
                color: const Color(0xFFD1AC67).withOpacity(0.8),
                borderRadius: BorderRadius.circular(14),
              )
            : null,
        padding: t == active ? const EdgeInsets.all(6) : EdgeInsets.zero,
        child: InkResponse(onTap: () {}, radius: 28, child: child),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        icon(Icons.home_outlined, BottomTab.home),
        icon(Icons.schedule_outlined, BottomTab.clock),
        icon(Icons.check_box_outlined, BottomTab.check),
        icon(Icons.grid_view_rounded, BottomTab.grid),
      ],
    );
  }
}
