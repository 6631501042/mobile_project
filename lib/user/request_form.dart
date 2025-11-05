import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class RequestForm extends StatefulWidget {
  final VoidCallback onCancel;
  final String roomName;
  final String initialSlot; // จาก DB เช่น "08.00-10.00"
  final int roomId;

  const RequestForm({
    super.key,
    required this.onCancel,
    required this.roomName,
    required this.initialSlot,
    required this.roomId,
  });

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  String? selectedSlot; // เก็บแบบ UI เช่น "8:00-10:00"
  bool _submitting = false;
  late final Set<String> _selectableSlots; // เก็บแบบ UI

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
    _selectableSlots = {uiSlot}; // อนุญาตให้กดเฉพาะ slot ที่เลือกมาจากหน้าลิสต์
  }

  bool get _canSubmit => selectedSlot != null;

  // 🖼️ Choose image based on room type
  String _getRoomImage(String roomName) {
    if (roomName.startsWith('SR')) {
      return 'assets/images/four_people.jpg';
    } else if (roomName.startsWith('MR')) {
      return 'assets/images/eight_people.jpg';
    } else if (roomName.startsWith('LR')) {
      return 'assets/images/ten_people.jpg';
    }
    return 'assets/images/MeetingRoom.jpg'; // default
  }

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

          // images
          // 🖼️ dynamic image based on room type
          Image.asset(
            _getRoomImage(widget.roomName),
            // height: 150,
            fit: BoxFit.cover,
          ),

          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Time Slot', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 8),

          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildSlot('8:00-10:00', isLeft: true),
                  buildSlot('10:00-12:00', isLeft: false),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildSlot('13:00-15:00', isLeft: true),
                  buildSlot('15:00-17:00', isLeft: false),
                ],
              ),
            ],
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

  Widget buildSlot(String time, {required bool isLeft}) {
    final isEnabled = _selectableSlots.contains(time);
    final isSelected = selectedSlot == time;

    return GestureDetector(
      onTap: !isEnabled ? null : () => setState(() => selectedSlot = time),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: Container(
          height: 70,
          width: 140,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected && isEnabled
                ? const Color(0xFFAFBEA2)
                : Colors.transparent,
            borderRadius: isLeft
                ? const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
            border: Border.all(
              color: isSelected && isEnabled
                  ? const Color(0xFFAFBEA2)
                  : (isEnabled ? Colors.blueAccent : Colors.grey),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              time,
              style: TextStyle(
                color: isSelected && isEnabled ? Colors.white : Colors.black87,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
