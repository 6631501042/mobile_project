// ========================== main.dart ==========================
// Status (User) — วันละหนึ่งรายการ, ป้ายสถานะ Pending/Approved/Rejected
// แก้เคส Overflow แบบหมดจด + โครงพร้อมต่อฐานข้อมูลภายหลัง

import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const RoomReservationUserApp());

// ===== THEME COLORS =====
class AppColors {
  static const finlandia = Color(0xFF51624F); // Top bar
  static const hampton   = Color(0xFFE6D5A9); // Background
  static const edward    = Color(0xFF9CB4AC); // Approved (เขียวอมเทา)
  static const norway    = Color(0xFFAFBEA2);

  static const chipPending  = Color(0xFFFFF96F); // เหลืองอ่อน
  static const chipApproved = edward;            // เขียวอมเทา
  static const chipRejected = Color(0xFFFF9E9E); // ชมพูแดง
}

// ===== DOMAIN =====
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

  UserReservation copyWith({BookingStatus? status}) => UserReservation(
        roomCode: roomCode,
        date: date,
        start: start,
        end: end,
        status: status ?? this.status,
      );
}

// ===== REPOSITORY (Mock) — พร้อมสลับเป็น Firestore/REST =====
abstract class UserReservationRepository {
  Stream<UserReservation?> watchToday(String userId);
}

class MockUserReservationRepository implements UserReservationRepository {
  MockUserReservationRepository({this.autoResult = BookingStatus.rejected}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _current = UserReservation(
      roomCode: 'LR-104',
      date: today,
      start: const TimeOfDay(hour: 8, minute: 0),
      end: const TimeOfDay(hour: 10, minute: 0),
      status: BookingStatus.pending,
    );
    _emit(_current);

    // เดโม: เปลี่ยนสถานะอัตโนมัติหลัง 6 วิ (ไว้เห็นการสลับสี/ป้าย)
    Future.delayed(const Duration(seconds: 6), () {
      _current = _current?.copyWith(status: autoResult);
      _emit(_current);
    });
  }

  final BookingStatus autoResult; // ลองเป็น approved ก็ได้
  final _ctrl = StreamController<UserReservation?>.broadcast();
  UserReservation? _current;

  @override
  Stream<UserReservation?> watchToday(String userId) => _ctrl.stream;

  void _emit(UserReservation? r) => _ctrl.add(r);
  void dispose() => _ctrl.close();
}

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

// ===== MAIN PAGE =====
class UserStatusPage extends StatefulWidget {
  final String userId;
  const UserStatusPage({super.key, required this.userId});

  @override
  State<UserStatusPage> createState() => _UserStatusPageState();
}

class _UserStatusPageState extends State<UserStatusPage> {
  late final MockUserReservationRepository repo;

  @override
  void initState() {
    super.initState();
    repo = MockUserReservationRepository(
      autoResult: BookingStatus.rejected, // หรือ BookingStatus.approved
    );
  }

  @override
  void dispose() {
    repo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hampton,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: _TopBar(userId: widget.userId),
      ),
      body: SafeArea(
        // ===== โครงกัน Overflow: เติมเต็มสูงจอ, scroll ได้เมื่อจำเป็น =====
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                          children: const [
                            _Header('Room'),
                            _Header('Action'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<UserReservation?>(
                          stream: repo.watchToday(widget.userId),
                          builder: (context, snap) {
                            final r = snap.data;
                            if (r == null) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 48),
                                child: Text(
                                  'No reservation today',
                                  style: TextStyle(fontSize: 18),
                                ),
                              );
                            }
                            return Align(
                              alignment: Alignment.topCenter,
                              child: _ReservationCard(res: r),
                            );
                          },
                        ),
                        const Spacer(), // ดัน bottom bar ชิดล่างจอ
                        const _BottomBar(),
                        const SizedBox(height: 8),
                        Container(
                          height: 2,
                          width: 220,
                          margin: const EdgeInsets.only(bottom: 16),
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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

// ===== RESERVATION CARD (แก้ล้นภายในการ์ดด้วย IntrinsicHeight) =====
class _ReservationCard extends StatelessWidget {
  final UserReservation res;
  const _ReservationCard({required this.res});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_two(res.date.day)} ${_month(res.date.month)} ${res.date.year}';
    String hhmm(TimeOfDay t) => '${t.hour}.${_two(t.minute)}';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 118, // สูงพอดีตามภาพ
        // ไม่กำหนด maxHeight เพื่อกันล้นแบบเศษพิกเซล
      ),
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: AppColors.hampton.withOpacity(0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(12),
        ),
        // <<<<<< กัน Overflow ภายในการ์ด
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ข้อมูลซ้าย
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ไม่ขยายเกิน
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LR-104',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.black.withOpacity(0.95))),
                    const SizedBox(height: 6),
                    Text(dateStr,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black.withOpacity(0.45),
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${hhmm(res.start)}-${hhmm(res.end)}',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black.withOpacity(0.50),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ป้ายสถานะขวา
              _StatusChip(res.status),
            ],
          ),
        ),
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

// ===== STATUS CHIP (pill + เงา) =====
class _StatusChip extends StatelessWidget {
  final BookingStatus status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;
    switch (status) {
      case BookingStatus.pending:
        bg = AppColors.chipPending;
        label = 'Pending';
        break;
      case BookingStatus.approved:
        bg = AppColors.chipApproved;
        label = 'Approved';
        break;
      case BookingStatus.rejected:
        bg = AppColors.chipRejected;
        label = 'Rejected';
        break;
    }

    return PhysicalModel(
      color: Colors.transparent,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
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
