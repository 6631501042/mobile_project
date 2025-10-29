// ---------------------------------------------
// Approver Status page (ปุ่ม Approve/Reject ตามภาพ + popup เหตุผล)
// ---------------------------------------------
import 'dart:async';
import 'package:flutter/material.dart';

/// ============ THEME ============
class AppColors {
  static const finlandia = Color(0xFF51624F); // Top bar
  static const hampton   = Color(0xFFE6D5A9); // Background
  static const norway    = Color(0xFFAFBEA2);
  static const cardBg    = Color(0xFFF9F5E5);

  // ปุ่มตามภาพ (ฟ้ากับชมพู + เส้นขอบ)
  static const approveBg     = Color(0xFFD9EBFF); // ฟ้าอ่อนปุ่ม Approve
  static const approveBorder = Color(0xFF9BC3F8); // เส้นขอบฟ้า
  static const approveText   = Color(0xFF245B96); // ตัวหนังสือฟ้าเข้มเล็กน้อย

  static const rejectBg      = Color(0xFFFFD4D4); // ชมพูอ่อนปุ่ม Reject
  static const rejectBorder  = Color(0xFFE89999); // เส้นขอบชมพู
  static const rejectText    = Color(0xFF7F1F1F); // ตัวหนังสือแดงอมเลือดนิดๆ
}

/// ============ MODELS ============
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

class ReservationLog {
  final String reservationId;
  final String approverId;
  final ReservationStatus result;
  final String? reason;
  final DateTime timestamp;

  const ReservationLog({
    required this.reservationId,
    required this.approverId,
    required this.result,
    required this.timestamp,
    this.reason,
  });
}

/// ============ REPOSITORY ============
abstract class ReservationRepository {
  Stream<List<Reservation>> watchPendingForApprover(String approverId);
  Future<void> addIncomingRequest(Reservation r);
  Future<void> setStatus({
    required String reservationId,
    required ReservationStatus status,
    required String approverId,
    String? reason,
  });
  Stream<List<ReservationLog>> watchLogs(String approverId);
}

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
    String? reason,
  }) async {
    final idx = _pending.indexWhere((e) => e.id == reservationId);
    if (idx == -1) return;
    final updated = _pending[idx].copyWith(status: status);
    _pending.removeAt(idx);
    _pendingCtrl.add(List.unmodifiable(_pending));

    final log = ReservationLog(
      reservationId: updated.id,
      approverId: approverId,
      result: status,
      timestamp: DateTime.now(),
      reason: reason,
    );
    _logs = [..._logs, log];
    _logsCtrl.add(List.unmodifiable(_logs));
  }

  @override
  Stream<List<ReservationLog>> watchLogs(String approverId) =>
      _logsCtrl.stream;
}

/// ============ Wrapper (ใช้ใน main.dart) ============
class Status extends StatelessWidget {
  const Status({super.key});
  @override
  Widget build(BuildContext context) {
    return const ApproverStatusPage(
      approverId: 'teacher-001',
      approverName: 'Ajarn.Tick',
    );
  }
}

/// ============ PAGE ============
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
  int _seed = 3;

  @override
  void initState() {
    super.initState();
    repo = MockReservationRepository();
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
        onPressed: _addMockRequest,
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
                children: const [
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
                          onApprove: () async {
                            await repo.setStatus(
                              reservationId: r.id,
                              status: ReservationStatus.approved,
                              approverId: widget.approverId,
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${r.roomCode} • Approved')),
                            );
                          },
                          onReject: (reason) async {
                            await repo.setStatus(
                              reservationId: r.id,
                              status: ReservationStatus.rejected,
                              approverId: widget.approverId,
                              reason: reason,
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${r.roomCode} • Rejected\nReason: $reason')),
                            );
                          },
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

  Future<void> _addMockRequest() async {
    final now = DateTime(2025, 9, 28);
    final id = 'r${_seed++}';
    final startH = 9 + (_seed % 6) * 2;
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

/// ===== ป๊อปอัปขอเหตุผล Reject
Future<String?> _promptRejectReason(BuildContext context) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      final controller = TextEditingController();
      return AlertDialog(
        title: const Text('Reason for rejection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'Type reason…',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(dialogCtx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      );
    },
  );
}

/// ============ WIDGETS ============
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
              Text(approverName,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
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
  final Future<void> Function() onApprove;
  final Future<void> Function(String reason) onReject;

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
              offset: const Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${data.userId}  ${data.userName}',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.75),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(data.roomCode,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withOpacity(0.9))),
                const SizedBox(height: 8),
                Text(dateStr,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.45),
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${t(data.start)}-${t(data.end)}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.45),
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Right
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _PillButton.approve(
                label: 'Approve',
                onTap: onApprove,
              ),
              const SizedBox(height: 10),
              _PillButton.reject(
                label: 'Reject',
                onTap: () async {
                  final reason = await _promptRejectReason(context);
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

  String _two(int v) => v.toString().padLeft(2, '0');
  String _month(int m) {
    const names = [
      '', 'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return names[m];
  }
}

/// ปุ่มเม็ดยาให้เหมือนภาพ: พื้นสีอ่อน + เส้นขอบ + ขอบมน
class _PillButton extends StatelessWidget {
  final String label;
  final Future<void> Function() onTap;
  final Color bg;
  final Color border;
  final Color text;

  const _PillButton._({
    required this.label,
    required this.onTap,
    required this.bg,
    required this.border,
    required this.text,
  });

  factory _PillButton.approve({
    required String label,
    required Future<void> Function() onTap,
  }) => _PillButton._(
    label: label,
    onTap: onTap,
    bg: AppColors.approveBg,
    border: AppColors.approveBorder,
    text: AppColors.approveText,
  );

  factory _PillButton.reject({
    required String label,
    required Future<void> Function() onTap,
  }) => _PillButton._(
    label: label,
    onTap: onTap,
    bg: AppColors.rejectBg,
    border: AppColors.rejectBorder,
    text: AppColors.rejectText,
  );

  @override
  Widget build(BuildContext context) => Material(
    color: bg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: border, width: 1.4),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async => await onTap(),
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
