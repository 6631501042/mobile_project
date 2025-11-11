// lib/approver/approver_status.dart
import 'package:flutter/material.dart';
import 'package:mobile_project/api/approver_api.dart';

class ApproverStatusPage extends StatefulWidget {
  final String approverId; // ใส่เป็น string ของเลข id เช่น '29'
  const ApproverStatusPage({super.key, required this.approverId});

  @override
  State<ApproverStatusPage> createState() => _ApproverStatusPageState();
}

class _ApproverStatusPageState extends State<ApproverStatusPage> {
  bool loading = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => loading = true);
    try {
      final data = await ApproverService.fetchPending();
      setState(() => items = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('โหลดรายการล้มเหลว: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _approve(Map<String, dynamic> row) async {
    final hid = int.tryParse(row['history_id'].toString()) ?? -1;
    final aid = int.tryParse(widget.approverId) ?? -1;

    // optimistic UI
    final old = List<Map<String, dynamic>>.from(items);
    setState(() => items.removeWhere(
        (e) => e['history_id'].toString() == row['history_id'].toString()));

    final ok = await ApproverService.approve(hid, aid);
    if (!ok) {
      setState(() => items = old); // rollback
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Approve ไม่สำเร็จ')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approved: ${row['roomCode']}')),
    );
  }

  // ✅ รับ reason มาจากการ์ด (ไม่ถามซ้ำ)
  Future<void> _reject(Map<String, dynamic> row, String reason) async {
    if (reason.isEmpty) return;

    final hid = int.tryParse(row['history_id'].toString()) ?? -1;
    final aid = int.tryParse(widget.approverId) ?? -1;

    final old = List<Map<String, dynamic>>.from(items);
    setState(() => items.removeWhere(
        (e) => e['history_id'].toString() == row['history_id'].toString()));

    final ok = await ApproverService.reject(hid, aid, reason);
    if (!ok) {
      setState(() => items = old); // rollback
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reject ไม่สำเร็จ')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected: ${row['roomCode']}\nReason: $reason')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D5A9), // Hampton
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              const SizedBox(height: 60),
              const Center(
                child: Text(
                  'Status',
                  style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('User/Room',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  Text('Action',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 10),

              if (loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('No pending requests')),
                )
              else
                ...items.map((row) => _ItemCard(
                      requester: (row['requesterName'] ?? '').toString(),
                      roomCode: (row['roomCode'] ?? '').toString(),
                      date: (row['date'] ?? '').toString(), // "YYYY-MM-DD"
                      timeslot:
                          (row['timeslot'] ?? '').toString(), // "10.00-12.00"
                      onApprove: () => _approve(row),
                      // ✅ ส่ง reason เข้ามาเลย
                      onReject: (reason) => _reject(row, reason),
                    )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String requester, roomCode, date, timeslot;
  final Future<void> Function() onApprove;
  final Future<void> Function(String reason) onReject; // ✅ รับ reason

  const _ItemCard({
    required this.requester,
    required this.roomCode,
    required this.date,
    required this.timeslot,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5E5),
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
          // left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(requester,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.75),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(roomCode,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withOpacity(0.9))),
                const SizedBox(height: 8),
                Text(date,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.45),
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(timeslot,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.45),
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // right buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _pill(
                label: 'Approve',
                bg: const Color(0xFFD9EBFF),
                border: const Color(0xFF9BC3F8),
                text: const Color(0xFF245B96),
                onTap: () async {
                  final ok = await _confirmApprove(
                      context, roomCode, date, timeslot, requester);
                  if (ok) await onApprove();
                },
              ),
              const SizedBox(height: 10),
              _pill(
                label: 'Reject',
                bg: const Color(0xFFFFD4D4),
                border: const Color(0xFFE89999),
                text: const Color(0xFF7F1F1F),
                onTap: () async {
                  final reason = await _askReason(context); // ❗ถามครั้งเดียว
                  if (reason == null || reason.isEmpty) return;
                  await onReject(reason); // ส่งเหตุผลขึ้นไป
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _pill({
    required String label,
    required Color bg,
    required Color border,
    required Color text,
    required Future<void> Function() onTap,
  }) {
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border, width: 1.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 18, color: text)),
        ),
      ),
    );
  }
}

// ===== dialogs =====
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
                hintText: 'Type reason…', border: OutlineInputBorder()),
            onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(c.text.trim()),
                child: const Text('Reject')),
          ],
        );
      },
    );

Future<bool> _confirmApprove(
  BuildContext context,
  String room,
  String date,
  String timeslot,
  String user,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm approval'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Approve this reservation?'),
          const SizedBox(height: 8),
          Text('User : $user'),
          Text('Room : $room'),
          Text('Date : $date'),
          Text('Time : $timeslot'),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel')),
        ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm')),
      ],
    ),
  ).then((v) => v ?? false);
}
