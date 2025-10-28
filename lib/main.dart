import 'package:flutter/material.dart';

void main() => runApp(const RoomReservationUserApp());

// ===== THEME COLORS (ตามภาพ) =====
class AppColors {
  static const finlandia = Color(0xFF51624F); // top bar
  static const hampton   = Color(0xFFE6D5A9); // พื้นหลัง + "สีในกล่อง"
  static const norway    = Color(0xFFAFBEA2);
  static const edward    = Color(0xFF9CB4AC); // ชิป Approved

  // ชิปสถานะ
  static const chipPending  = Color(0xFFFFF96F); // เหลืองอ่อนตามภาพ
  static const chipApproved = edward;            // เขียวอมเทาตามภาพ
  static const chipRejected = Color(0xFFFF9E9E); // ชมพูแดงตามภาพ
}

// ===== DOMAIN =====
enum BookingStatus { pending, approved, rejected }

class UserReservation {
  final String roomCode;
  final DateTime date;
  final TimeOfDay start;
  final TimeOfDay end;
  final BookingStatus status;
  final String approver;

  const UserReservation({
    required this.roomCode,
    required this.date,
    required this.start,
    required this.end,
    required this.status,
    required this.approver,
  });
}

// ===== MOCK DATA (ทำหน้าตาเหมือนภาพ) =====
final mockReservations = <UserReservation>[
  UserReservation(
    roomCode: 'LR-105',
    date: DateTime(2025, 9, 28),
    start: const TimeOfDay(hour: 8, minute: 0),
    end: const TimeOfDay(hour: 10, minute: 0),
    status: BookingStatus.approved,
    approver: 'Ajarn.Tick',
  ),
  UserReservation(
    roomCode: 'MR-104',
    date: DateTime(2025, 9, 24),
    start: const TimeOfDay(hour: 15, minute: 0),
    end: const TimeOfDay(hour: 17, minute: 0),
    status: BookingStatus.rejected,
    approver: 'Ajarn.Tick',
  ),
  UserReservation(
    roomCode: 'SR-101',
    date: DateTime(2025, 9, 20),
    start: const TimeOfDay(hour: 10, minute: 0),
    end: const TimeOfDay(hour: 12, minute: 0),
    status: BookingStatus.approved,
    approver: 'Ajarn.Tock',
  ),
  UserReservation(
    roomCode: 'SR-106',
    date: DateTime(2025, 9, 1),
    start: const TimeOfDay(hour: 13, minute: 0),
    end: const TimeOfDay(hour: 15, minute: 0),
    status: BookingStatus.rejected,
    approver: 'Ajarn.Tock',
  ),
];

// ===== APP ROOT =====
class RoomReservationUserApp extends StatelessWidget {
  const RoomReservationUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.hampton,
        primaryColor: AppColors.finlandia,
      ),
      home: const UserStatusPage(userId: '6631501xxx'),
    );
  }
}

// ===== PAGE =====
class UserStatusPage extends StatelessWidget {
  final String userId;
  const UserStatusPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hampton,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: _TopBar(userId: userId),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                'Status',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [_Header('Room'), _Header('Action')],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: mockReservations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _ReservationCard(res: mockReservations[i]),
                ),
              ),
              const _BottomBar(),
              const SizedBox(height: 8),
              Container(
                height: 2,
                width: 220,
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.black.withOpacity(0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== TOP BAR =====
class _TopBar extends StatelessWidget {
  final String userId;
  const _TopBar({required this.userId});

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
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.norway,
                child: Text('🐦', style: TextStyle(fontSize: 22)),
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
              Text(userId, style: const TextStyle(color: Colors.white)),
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text('LOGOUT',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .2)),
        ),
      ),
    );
  }
}

// ===== HEADER =====
class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.black.withOpacity(0.85),
        ),
      );
}

// ===== CARD (สีในกล่อง = Hampton ตามภาพ) =====
class _ReservationCard extends StatelessWidget {
  final UserReservation res;
  const _ReservationCard({required this.res});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_pad(res.date.day)} ${_month(res.date.month)} ${res.date.year}';
    String hhmm(TimeOfDay t) => '${t.hour}.${_pad(t.minute)}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.hampton, // <<— สีในกล่องตามภาพ
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.85), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT: room / date / time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(res.roomCode,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withOpacity(0.95))),
                const SizedBox(height: 6),
                Text(dateStr,
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.black.withOpacity(0.45),
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('${hhmm(res.start)}-${hhmm(res.end)}',
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.black.withOpacity(0.50),
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // RIGHT: Status chip + "By" + approver (จัดกลางตามภาพ)
          SizedBox(
            width: 150, // ให้สัดส่วนเหมือนภาพ
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _StatusChip(res.status),
                const SizedBox(height: 10),
                Text('By',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.75),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(res.approver,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.black.withOpacity(0.95),
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _pad(int v) => v.toString().padLeft(2, '0');
  String _month(int m) {
    const names = [
      '', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug'
    ];
    // ถ้าอยากเรียง Jan-Dec ให้แทนรายชื่อตามปกติได้เลย
    const normal = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return normal[m];
  }
}

// ===== STATUS CHIP (pill สีตามภาพ) =====
class _StatusChip extends StatelessWidget {
  final BookingStatus status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;
    switch (status) {
      case BookingStatus.pending:
        bg = AppColors.chipPending;  label = 'Approved'; // (แค่ตัวอย่าง ถ้าอยากมี Pending ก็โชว์ Pending)
        label = 'Pending';
        break;
      case BookingStatus.approved:
        bg = AppColors.chipApproved; label = 'Approved'; break;
      case BookingStatus.rejected:
        bg = AppColors.chipRejected; label = 'Rejected'; break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    );
  }
}

// ===== BOTTOM BAR =====
class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    Widget icon(IconData i, {bool highlight = false}) {
      final ic = Icon(i, size: 36, color: Colors.black.withOpacity(0.85));
      if (highlight) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD1AC67).withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(6),
          child: ic,
        );
      }
      return ic;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          icon(Icons.home_outlined),
          icon(Icons.check_box_outlined, highlight: true),
          icon(Icons.schedule_outlined),
        ],
      ),
    );
  }
}
