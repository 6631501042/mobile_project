// lib/user/status.dart
import 'package:flutter/material.dart';

/// ====== THEME COLORS ======
class AppColors {
  static const finlandia = Color(0xFF51624F); // Top bar
  static const hampton   = Color(0xFFE6D5A9); // Page background
  static const norway    = Color(0xFFAFBEA2); // Logo circle bg
  static const edward    = Color(0xFF9CB4AC); // Approved chip
  static const chipPending  = Color(0xFFFFF96F); // Pending chip
  static const chipRejected = Color(0xFFFF9E9E); // Rejected chip
}

/// ====== MODEL ======
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

/// ====== PAGE (USER) ======
class Status extends StatelessWidget {
  const Status({super.key});

  // mock 1 รายการประจำวัน (คุณจะต่อ DB ภายหลังได้เลย)
  // ก่อน:  const UserReservation( ... )
UserReservation get _todayItem => UserReservation(
  roomCode: 'LR-104',
  date: DateTime(2025, 9, 28),
  start: const TimeOfDay(hour: 8, minute: 0),
  end:   const TimeOfDay(hour: 10, minute: 0),
  status: BookingStatus.pending,
);

  @override
  Widget build(BuildContext context) {
    final item = _todayItem;

    return Scaffold(
      backgroundColor: AppColors.hampton,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: _TopBar(userId: '6631501xxx'),
      ),
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
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.92),
                ),
              ),
              const SizedBox(height: 18),

              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HeaderText('Room'),
                  _HeaderText('Action'),
                ],
              ),
              const SizedBox(height: 12),

              // White card
              _ReservationCardUser(item: item),

              const Spacer(),

              // Bottom bar
              const Divider(thickness: 1),
              const SizedBox(height: 4),
              const _BottomBarUser(activeCenter: true),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// ====== TOP BAR ======
class _TopBar extends StatelessWidget {
  final String userId;
  const _TopBar({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: AppColors.finlandia,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        bottom: false,
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
            _LogoutPill(onPressed: () {
              // TODO: hook logout
              Navigator.of(context).maybePop();
            }),
          ],
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
          child: Text('LOGOUT',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
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
    return Text(
      text,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Colors.black.withOpacity(0.9),
      ),
    );
  }
}

/// ====== WHITE CARD (USER VIEW) ======
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
        color: Colors.white,                        // ✅ พื้นในกล่อง "สีขาว"
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
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
                Text(item.roomCode,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withOpacity(0.95),
                    )),
                const SizedBox(height: 6),
                Text(dateStr,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black.withOpacity(0.45),
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 6),
                Text('${hhmm(item.start)}-${hhmm(item.end)}',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black.withOpacity(0.50),
                      fontWeight: FontWeight.w700,
                    )),
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
    const m = ['', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return m[d.month];
  }
}

/// ====== STATUS CHIP ======
class _StatusChip extends StatelessWidget {
  final BookingStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late String label;
    switch (status) {
      case BookingStatus.pending:
        bg = AppColors.chipPending;
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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
      ),
    );
  }
}

/// ====== BOTTOM BAR (USER) ======
class _BottomBarUser extends StatelessWidget {
  final bool activeCenter;
  const _BottomBarUser({required this.activeCenter});

  @override
  Widget build(BuildContext context) {
    Widget _icon(IconData i, {bool highlight = false}) {
      final ic = Icon(i, size: 34, color: Colors.black);
      if (!highlight) return ic;
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD1AC67),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(6),
        child: ic,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _icon(Icons.home_outlined),
        _icon(Icons.check_box_outlined, highlight: activeCenter),
        _icon(Icons.schedule_outlined),
      ],
    );
  }
}
