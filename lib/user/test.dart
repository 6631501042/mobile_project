// lib/user/test.dart
import 'dart:async';
import 'package:flutter/material.dart';

/// ========== THEME ==========
class C {
  static const finlandia = Color(0xFF51624F);
  static const hampton   = Color(0xFFE6D5A9);
  static const norway    = Color(0xFFAFBEA2);
  static const cardBg    = Color(0xFFF9F5E5);

  // ปุ่ม Approve/Reject ให้เหมือนภาพ
  static const approveBg     = Color(0xFFD9EBFF);
  static const approveBorder = Color(0xFF9BC3F8);
  static const approveText   = Color(0xFF245B96);
  static const rejectBg      = Color(0xFFFFD4D4);
  static const rejectBorder  = Color(0xFFE89999);
  static const rejectText    = Color(0xFF7F1F1F);
}

/// ========== DOMAIN ==========
enum RStatus { pending, approved, rejected }

class Reservation {
  final String id, userId, userName, roomCode;
  final DateTime date;
  final TimeOfDay start, end;
  final RStatus status;

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

  Reservation copyWith({RStatus? status}) => Reservation(
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

class RLog {
  final String reservationId, approverId;
  final RStatus result;
  final String? reason;
  final DateTime ts;
  const RLog({
    required this.reservationId,
    required this.approverId,
    required this.result,
    required this.ts,
    this.reason,
  });
}

/// ========== REPO (Mock) ==========
abstract class RRepo {
  Stream<List<Reservation>> watchPending(String approverId);
  Future<void> add(Reservation r);
  Future<void> set({
    required String id,
    required RStatus status,
    required String approverId,
    String? reason,
  });
}

class MockRepo implements RRepo {
  final _pendingCtrl = StreamController<List<Reservation>>.broadcast();
  final _logsCtrl    = StreamController<List<RLog>>.broadcast();
  List<Reservation> _pending = [];
  List<RLog> _logs = [];

  MockRepo() {
    _pending = [
      Reservation(
        id: 'r1',
        userId: '6631501xxx',
        userName: 'Leo Jone',
        roomCode: 'LR-105',
        date: DateTime(2025, 9, 28),
        start: const TimeOfDay(hour: 8, minute: 0),
        end: const TimeOfDay(hour: 10, minute: 0),
        status: RStatus.pending,
      ),
      Reservation(
        id: 'r2',
        userId: '6631501xxx',
        userName: 'Lion Sins',
        roomCode: 'MR-110',
        date: DateTime(2025, 9, 28),
        start: const TimeOfDay(hour: 13, minute: 0),
        end: const TimeOfDay(hour: 15, minute: 0),
        status: RStatus.pending,
      ),
    ];
    _pendingCtrl.add(_pending);
    _logsCtrl.add(const []);
  }

  @override
  Stream<List<Reservation>> watchPending(String _) => _pendingCtrl.stream;

  @override
  Future<void> add(Reservation r) async {
    _pending = [..._pending, r];
    _pendingCtrl.add(_pending);
  }

  @override
  Future<void> set({
    required String id,
    required RStatus status,
    required String approverId,
    String? reason,
  }) async {
    _pending.removeWhere((e) => e.id == id);
    _pendingCtrl.add(List.unmodifiable(_pending));
    _logs = [
      ..._logs,
      RLog(
        reservationId: id,
        approverId: approverId,
        result: status,
        ts: DateTime.now(),
        reason: reason,
      )
    ];
    _logsCtrl.add(List.unmodifiable(_logs));
  }
}

/// ========== ENTRY (ใช้ใน main.dart) ==========
class Status extends StatelessWidget {
  const Status({super.key});
  @override
  Widget build(BuildContext context) =>
      const ApproverPage(approverId: 'teacher-001', approverName: 'Ajarn.Tick');
}

/// ========== PAGE (ไม่มี TopBar แล้ว) ==========
class ApproverPage extends StatefulWidget {
  final String approverId, approverName;
  const ApproverPage({
    super.key,
    required this.approverId,
    required this.approverName,
  });
  @override
  State<ApproverPage> createState() => _ApproverPageState();
}

class _ApproverPageState extends State<ApproverPage> {
  late final RRepo repo;
  int _seed = 3;

  @override
  void initState() {
    super.initState();
    repo = MockRepo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.hampton,

      // ❌ ไม่มี appBar / TopBar
      // ✅ คง FAB "+ Add mock request"
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: C.norway,
        icon: const Icon(Icons.add),
        label: const Text('Add mock request'),
        onPressed: _addMock,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 76),
              const Center(
                child: Text(
                  'Status',
                  style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 18),

              const _HeaderRow(),
              const SizedBox(height: 10),

              Expanded(
                child: StreamBuilder<List<Reservation>>(
                  stream: repo.watchPending(widget.approverId),
                  builder: (_, s) {
                    final items = s.data ?? const <Reservation>[];
                    if (items.isEmpty) {
                      return const Center(child: Text('No pending requests'));
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _Card(
                        r: items[i],
                        onApprove: () async {
                          // เปิด dialog ยืนยันก่อน
                          final ok = await _confirmApprove(context, items[i]);
                          if (!ok) return;
                          await repo.set(
                            id: items[i].id,
                            status: RStatus.approved,
                            approverId: widget.approverId,
                          );
                          if (!mounted) return;
                          _toast('${items[i].roomCode} • Approved');
                        },
                        onReject: (reason) async {
                          await repo.set(
                            id: items[i].id,
                            status: RStatus.rejected,
                            approverId: widget.approverId,
                            reason: reason,
                          );
                          if (!mounted) return;
                          _toast('${items[i].roomCode} • Rejected\nReason: $reason');
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              const Divider(thickness: 1),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _addMock() async {
    final id = 'r${_seed++}';
    final start = 9 + (_seed % 6) * 2;
    await repo.add(
      Reservation(
        id: id,
        userId: '66315${_seed}xxx',
        userName: _seed.isEven ? 'Eren Yeager' : 'Mikasa Ackerman',
        roomCode: _seed.isEven ? 'LR-10$_seed' : 'MR-11$_seed',
        date: DateTime(2025, 9, 28),
        start: TimeOfDay(hour: start, minute: 0),
        end: TimeOfDay(hour: start + 2, minute: 0),
        status: RStatus.pending,
      ),
    );
  }
}

/// ========== UI CHUNKS ==========
class _HeaderRow extends StatelessWidget {
  const _HeaderRow();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: const [
      Text('User/Room', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      Text('Action',    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
    ],
  );
}

class _Card extends StatelessWidget {
  final Reservation r;
  final Future<void> Function() onApprove;
  final Future<void> Function(String reason) onReject;
  const _Card({
    super.key,
    required this.r,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = '${_two(r.date.day)} ${_mon(r.date.month)} ${r.date.year}';
    String t(TimeOfDay x) => '${x.hour}.${_two(x.minute)}';

    return Container(
      decoration: BoxDecoration(
        color: C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${r.userId}  ${r.userName}',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.75),
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(r.roomCode,
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
              Text('${t(r.start)}-${t(r.end)}',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.45),
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _Pill.approve('Approve', onApprove),
          const SizedBox(height: 10),
          _Pill.reject('Reject', () async {
            final reason = await _askReason(context);
            if (reason == null || reason.isEmpty) return;
            await onReject(reason);
          }),
        ])
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Future<void> Function() onTap;
  final Color bg, border, text;
  const _Pill._(this.label, this.onTap, this.bg, this.border, this.text);

  factory _Pill.approve(String label, Future<void> Function() onTap) =>
      _Pill._(label, onTap, C.approveBg, C.approveBorder, C.approveText);

  factory _Pill.reject(String label, Future<void> Function() onTap) =>
      _Pill._(label, onTap, C.rejectBg, C.rejectBorder, C.rejectText);

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

/// ========== UTIL ==========
String _two(int v) => v.toString().padLeft(2, '0');
String _mon(int m) => const [
  '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
][m];

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

Future<bool> _confirmApprove(BuildContext context, Reservation r) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final dateStr = '${_two(r.date.day)} ${_mon(r.date.month)} ${r.date.year}';
      String t(TimeOfDay x) => '${x.hour}.${_two(x.minute)}';

      return AlertDialog(
        title: const Text('Confirm approval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Approve this reservation?'),
            const SizedBox(height: 8),
            Text('User : ${r.userId}  ${r.userName}'),
            Text('Room : ${r.roomCode}'),
            Text('Date : $dateStr'),
            Text('Time : ${t(r.start)}-${t(r.end)}'),
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
      );
    },
  ).then((v) => v ?? false);
}
