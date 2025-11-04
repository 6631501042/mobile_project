// lib/user/status.dart
import 'package:flutter/material.dart';
import 'package:mobile_project/api/status_api.dart';

class StatusTab extends StatefulWidget {
  final String userId; // 👈 รับ userId
  const StatusTab({super.key, required this.userId});

  @override
  State<StatusTab> createState() => _StatusTabState();
}

class _StatusTabState extends State<StatusTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _pending = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await UserStatusService.fetchPending(widget.userId);
      setState(() {
        _pending = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Load failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D5A9), // hampton
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text('Status',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.92)),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (_pending.isEmpty
                        ? const Center(child: Text('No pending requests'))
                        : ListView.separated(
                            itemCount: _pending.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final m = _pending[i];
                              return _PendingCard(
                                roomCode: m['roomname'] ?? '-',
                                timeRange: m['timeslot'] ?? '-',
                              );
                            },
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final String roomCode;
  final String timeRange;
  const _PendingCard({required this.roomCode, required this.timeRange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2EDD9),
        border: Border.all(color: const Color(0xFF8E8A76), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0,2), blurRadius: 3)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(roomCode, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(timeRange, style: const TextStyle(fontSize: 16)),
            ]),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFDFD96),
              border: Border.all(color: const Color(0xFFA08A0D), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: const Text('Pending', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFFA08A0D))),
          ),
        ],
      ),
    );
  }
}
