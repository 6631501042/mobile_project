// ---------------------------------------------approver
// SECTION 0: Imports
// ---------------------------------------------
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const RoomReservationApp());

// ---------------------------------------------
// SECTION 1: Theme & Constants
// ---------------------------------------------
class AppColors {
  static const finlandia = Color(0xFF51624F); // Top bar
  static const hampton   = Color(0xFFE6D5A9); // Background
  static const norway    = Color(0xFFAFBEA2);
  static const edward    = Color(0xFF9CB4AC); // Approve button
  static const rejected  = Color(0xFFFF9E9E); // Reject button
  static const cardBg    = Color(0xFFF9F5E5);
}

// ---------------------------------------------
// SECTION 2: Domain Models (ต่อยอด DB ได้)
// ---------------------------------------------
enum ReservationStatus { pending, approved, rejected }

class Reservation {
  final String id;
  final String userId;
  final String userName;
  final String roomCode;
  final DateTime date;
  final TimeOfDay start, end;
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

  Reservation copyWith({ReservationStatus? status}) => Reservation(
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

/// สำหรับบันทึกประวัติผลอนุมัติ/ปฏิเสธ
class ReservationLog {
  final String reservationId;
  final String approverId;
  final ReservationStatus result;
  final DateTime timestamp;

  const ReservationLog({
    required this.reservationId,
    required this.approverId,
    required this.result,
    required this.timestamp,
  });
}

// ---------------------------------------------
// SECTION 3: Repository Layer (Mock -> DB จริงได้ทันที)
// ---------------------------------------------
abstract class ReservationRepository {
  Stream<List<Reservation>> watchPendingForApprover(String approverId);
  Future<void> addIncomingRequest(Reservation r); // ← ใช้เมื่อมีคำขอใหม่
  Future<void> setStatus({
    required String reservationId,
    required ReservationStatus status,
    required String approverId,
  });
  Stream<List<ReservationLog>> watchLogs(String approverId);
}

/// เวอร์ชันจำลอง (ไร้เน็ต) — ภายหลังสลับเป็น Firestore/REST
class MockReservationRepository implements ReservationRepository {
  MockReservationRepository() {
    _pending = [
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
    _pendingCtrl.add(_pending);
    _logsCtrl.add(const []);
  }

  late List<Reservation> _pending;
  final _pendingCtrl = StreamController<List<Reservation>>.broadcast();
  final _logsCtrl = StreamController<List<ReservationLog>>.broadcast();
  List<ReservationLog> _logs = [];

  @override
  Stream<List<Reservation>> watchPendingForApprover(String approverId) =>
      _pendingCtrl.stream;

  @override
  Future<void> addIncomingRequest(Reservation r) async {
    _pending = [..._pending, r];
    _pendingCtrl.add(_pending);
  }

  @override
  Future<void> setStatus({
    required String reservationId,
    required ReservationStatus status,
    required String approverId,
  }) async {
    // ย้ายออกจากคิว pending
    final idx = _pending.indexWhere((e) => e.id == reservationId);
    if (idx == -1) return;
    final updated = _pending[idx].copyWith(status: status);
    _pending.removeAt(idx);
    _pendingCtrl.add(List.unmodifiable(_pending));

    // เก็บ Log
    final log = ReservationLog(
      reservationId: updated.id,
      approverId: approverId,
      result: status,
      timestamp: DateTime.now(),
    );
    _logs = [..._logs, log];
    _logsCtrl.add(List.unmodifiable(_logs));
  }

  @override
  Stream<List<ReservationLog>> watchLogs(String approverId) => _logsCtrl.stream;
}

/* ---------- Firestore Template (ย่อ) ----------
class FirestoreReservationRepository implements ReservationRepository {
  final _col = FirebaseFirestore.instance.collection('reservations');
  final _log = FirebaseFirestore.instance.collection('reservation_logs');

  @override
  Stream<List<Reservation>> watchPendingForApprover(String approverId) {
    return _col.where('status', isEqualTo: 'pending')
               .where('approverId', isEqualTo: approverId) // ถ้ามีฟิลด์นี้
               .snapshots()
               .map((s) => s.docs.map((d) => mapToReservation(d)).toList());
  }

  @override
  Future<void> addIncomingRequest(Reservation r) =>
    _col.doc(r.id).set({
      'userId': r.userId,
      'userName': r.userName,
      'roomCode': r.roomCode,
      'date': Timestamp.fromDate(r.date),
      'start': {'h': r.start.hour, 'm': r.start.minute},
      'end':   {'h': r.end.hour,   'm': r.end.minute},
      'status': 'pending'
    });

  @override
  Future<void> setStatus({required String reservationId, required ReservationStatus status, required String approverId}) async {
    await _col.doc(reservationId).update({'status': status.name});
    await _log.add({'reservationId': reservationId, 'approverId': approverId, 'result': status.name, 'ts': FieldValue.serverTimestamp()});
  }
}
------------------------------------------------ */

// ---------------------------------------------
// SECTION 4: App Root
// ---------------------------------------------
class RoomReservationApp extends StatelessWidget {
  const RoomReservationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.hampton,
        primaryColor: AppColors.finlandia,
      ),
      home: const ApproverStatusPage(
        approverId: 'teacher-001',
        approverName: 'Ajarn.Tick',
      ),
    );
  }
}

// ---------------------------------------------
// SECTION 5: Approver Status Page
// ---------------------------------------------
class ApproverStatusPage extends StatefulWidget {
  final String approverId, approverName;
  const ApproverStatusPage({
    super.key,
    required this.approverId,
    required this.approverName,
  });

  @override
  State<ApproverStatusPage> createState() => _ApproverStatusPageState();
}

class _ApproverStatusPageState extends State<ApproverStatusPage> {
  late final ReservationRepository repo;
  int _seed = 3; // สำหรับ gen mock id/slot

  @override
  void initState() {
    super.initState();
    repo = MockReservationRepository(); // 🔁 เปลี่ยนเป็น FirestoreRepository ได้เลย
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hampton,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: _TopBar(approverName: widget.approverName),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMockRequest, // ← เพิ่มรายการใน “วงแดง”
        backgroundColor: AppColors.norway,
        label: const Text('Add mock request'),
        icon: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 12),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HeaderText('User/Room'),
                  _HeaderText('Action'),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<Reservation>>(
                  stream: repo.watchPendingForApprover(widget.approverId),
                  builder: (context, snap) {
                    final items = snap.data ?? const <Reservation>[];
                    if (items.isEmpty) {
                      return const Center(child: Text('No pending requests'));
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) {
                        final r = items[i];
                        return ApproverReservationCard(
                          data: r,
                          onApprove: () => _setStatus(r, ReservationStatus.approved),
                          onReject: () => _setStatus(r, ReservationStatus.rejected),
                        );
                      },
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

  Future<void> _setStatus(Reservation r, ReservationStatus s) async {
    await repo.setStatus(
      reservationId: r.id,
      status: s,
      approverId: widget.approverId,
    );
    if (!mounted) return;
    final text = s == ReservationStatus.approved ? 'Approved' : 'Rejected';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${r.roomCode} • $text')),
    );
  }

  /// เพิ่ม “คำขอใหม่” (จำลอง) — อนาคตเปลี่ยนเป็น push จาก DB
  Future<void> _addMockRequest() async {
    final now = DateTime(2025, 9, 28);
    final id = 'r${_seed++}';
    final startH = 9 + (_seed % 6) * 2; // random-ish
    final r = Reservation(
      id: id,
      userId: '66315${_seed}xxx',
      userName: _seed.isEven ? 'Eren Yeager' : 'Mikasa Ackerman',
      roomCode: _seed.isEven ? 'LR-10$_seed' : 'MR-11$_seed',
      date: now,
      start: TimeOfDay(hour: startH, minute: 0),
      end: TimeOfDay(hour: startH + 2, minute: 0),
      status: ReservationStatus.pending,
    );
    await repo.addIncomingRequest(r);
  }
}

// ---------------------------------------------
// SECTION 6: Widgets
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
                  Text('ROOM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: .5)),
                  Text('RESERVATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: .5)),
                ],
              ),
              const Spacer(),
              Text(approverName, style: const TextStyle(color: Colors.white, fontSize: 14)),
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
          child: Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.black.withOpacity(0.9),
        ),
      );
}

class ApproverReservationCard extends StatelessWidget {
  final Reservation data;
  final VoidCallback onApprove, onReject;

  const ApproverReservationCard({
    super.key,
    required this.data,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = '${_two(data.date.day)} ${_month(data.date.month)} ${data.date.year}';
    String t(TimeOfDay x) => '${x.hour}.${_two(x.minute)}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.25), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${data.userId}  ${data.userName}',
                    style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.75), fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(data.roomCode,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black.withOpacity(0.9))),
                const SizedBox(height: 8),
                Text(dateStr,
                    style: TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.45), fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${t(data.start)}-${t(data.end)}',
                    style: TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.45), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Right section: actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ActionButton.primary(label: 'Approve', onTap: onApprove),
              const SizedBox(height: 10),
              _ActionButton.danger(label: 'Reject', onTap: onReject),
            ],
          ),
        ],
      ),
    );
  }

  String _two(int v) => v.toString().padLeft(2, '0');
  String _month(int m) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[m];
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bg;
  final Color textColor;

  const _ActionButton._({required this.label, required this.onTap, required this.bg, required this.textColor});

  factory _ActionButton.primary({required String label, required VoidCallback onTap}) =>
      _ActionButton._(label: label, onTap: onTap, bg: AppColors.edward, textColor: Colors.black87);

  factory _ActionButton.danger({required String label, required VoidCallback onTap}) =>
      _ActionButton._(label: label, onTap: onTap, bg: AppColors.rejected, textColor: Colors.black87);

  @override
  Widget build(BuildContext context) => Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ),
        ),
      );
}

enum BottomTab { home, clock, check, grid }

class _BottomBar extends StatelessWidget {
  final BottomTab active;
  const _BottomBar({required this.active});

  @override
  Widget build(BuildContext context) {
    Widget icon(IconData i, BottomTab t) {
      final child = Icon(i, size: 36, color: Colors.black.withOpacity(0.85));
      return Container(
        decoration: t == active
            ? BoxDecoration(color: const Color(0xFFD1AC67).withOpacity(0.8), borderRadius: BorderRadius.circular(14))
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
