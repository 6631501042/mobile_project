import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class RequestForm extends StatefulWidget {
  final VoidCallback onCancel;
  final String roomName;
  final String initialSlot; // จาก DB เช่น "08.00-10.00"
  final int roomId;
  final String? imageUrl;

  const RequestForm({
    super.key,
    required this.onCancel,
    required this.roomName,
    required this.initialSlot,
    required this.roomId,
    this.imageUrl,
  });

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  String? selectedSlot; // เก็บแบบ UI เช่น "8:00-10:00"
  bool _submitting = false;


  // "08.00-10.00" (DB) -> "8:00-10:00" (UI)
  String _dbToUiTimeslot(String s) {
    final parts = s.split('-');
    String fix(String hhmm) {
      hhmm = hhmm.replaceAll('.', ':');
      if (hhmm.length >= 5 && hhmm.startsWith('0')) {
        hhmm = '${int.parse(hhmm.substring(0, 2))}:${hhmm.substring(3, 5)}';
      }
      return hhmm;
    }

    return '${fix(parts[0])}-${fix(parts[1])}';
  }

  // "8:00-10:00" (UI) -> "08.00-10.00" (DB) (เอาไว้โชว์ใน snackbar เฉย ๆ)
  String _uiToDbTimeslot(String s) {
    final parts = s.split('-');
    String fix(String hhmm) {
      final p = hhmm.split(':');
      final hh = p[0].padLeft(2, '0');
      final mm = p[1];
      return '$hh.$mm';
    }

    return '${fix(parts[0])}-${fix(parts[1])}';
  }

  @override
  void initState() {
    super.initState();
    final uiSlot = _dbToUiTimeslot(widget.initialSlot);
    selectedSlot = uiSlot;
  }

  bool get _canSubmit => selectedSlot != null;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    try {
      final sp = await SharedPreferences.getInstance();
      int? roleId = sp.getInt('role_id');
      roleId ??= 24; // mock ถ้ายังไม่มีระบบ login

      await ApiService.reserveRoom(widget.roomId, roleId);

      if (!mounted) return;
      final dbSlot = _uiToDbTimeslot(selectedSlot!);

      // แจ้งเตือน + สลับไปแท็บ Check Status (index 1)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation submitted for $dbSlot')),
      );
      DefaultTabController.of(context).animateTo(1);
      widget.onCancel();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Request form',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Room Name', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: widget.roomName,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
            ),
          ),

          const SizedBox(height: 16),

      // --- 🖼️ เพิ่มส่วนแสดงรูปภาพตรงนี้ ---
        if (widget.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              '${ApiService.base}${widget.imageUrl}', // ต่อ baseUrl ด้วย
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, size: 48)),
                );
              },
            ),
          ),
        
        const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Time Slot', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 8),

         // แสดงช่วงเวลาเฉยๆ
          TextFormField(
            initialValue: widget.initialSlot,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onPressed: _submitting ? null : widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSubmit
                      ? const Color(0xFF4E5B4C)
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _submitting || !_canSubmit
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Confirm Request'),
                            content: Text(
                              'Do you want to reserve ${widget.roomName} at $selectedSlot ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4E5B4C),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _submit();
                                },
                                child: const Text(
                                  'Confirm',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}