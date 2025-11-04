import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class RequestForm extends StatefulWidget {
  final VoidCallback onCancel;
  final String roomName;
  final String initialSlot;
  final int roomId;

  /// ถ้า slot ที่ผู้ใช้คลิกมาจากหน้า list เป็น Free ให้ส่ง true
  /// ถ้าไม่ใช่ Free ให้ส่ง false (ปุ่มจะถูก disable ทั้ง submit และการเลือก slot)
  final bool isInitiallyFree;

  const RequestForm({
    super.key,
    required this.onCancel,
    required this.roomName,
    required this.initialSlot,
    required this.roomId,
    required this.isInitiallyFree,
  });

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  String? selectedSlot;
  bool _submitting = false;

  // อนุญาตให้กดได้เฉพาะ initialSlot ถ้าและเฉพาะเมื่อมัน Free
  late final Set<String> _selectableSlots;

  @override
  void initState() {
    super.initState();
    selectedSlot = widget.initialSlot;
    _selectableSlots = widget.isInitiallyFree ? {widget.initialSlot} : <String>{};
  }

  // แปลง "8:00-10:00" -> "08.00-10.00" (ถ้าต้องการแสดงผลสวย ๆ)
  String _toDbTimeslot(String ui) {
    final parts = ui.split('-');
    String fix(String hhmm) {
      final p = hhmm.split(':');
      final hh = p[0].padLeft(2, '0');
      final mm = p[1];
      return '$hh.$mm';
    }
    return '${fix(parts[0])}-${fix(parts[1])}';
  }

  bool get _canSubmit => widget.isInitiallyFree && selectedSlot != null;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    try {
      // อ่าน role_id จาก SharedPreferences (ถ้ามีระบบ login แล้ว)
      final sp = await SharedPreferences.getInstance();
      int? roleId = sp.getInt('role_id');

      // ทดสอบชั่วคราว: ใส่ roleId ตัวอย่าง (แก้เป็นของคุณเอง)
      roleId ??= 24;

      await ApiService.reserveRoom(widget.roomId, roleId);

      if (!mounted) return;
      final dbSlot = _toDbTimeslot(selectedSlot!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation submitted for $dbSlot')),
      );
      widget.onCancel();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabledBanner = !widget.isInitiallyFree
        ? Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.redAccent),
            ),
            child: const Row(
              children: [
                Icon(Icons.block, color: Colors.redAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This time slot is not available. You can only submit when the selected slot is Free.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Request form',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          disabledBanner,
          const SizedBox(height: 8),

          // Room Name
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Room Name', style: TextStyle(fontSize: 24))),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: widget.roomName,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
            ),
          ),

          const SizedBox(height: 16),
          Image.asset('assets/images/MeetingRoom.jpg',
              height: 150, fit: BoxFit.cover),

          const SizedBox(height: 16),
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Time Slot', style: TextStyle(fontSize: 24))),
          const SizedBox(height: 8),

          // แสดงปุ่ม slot — เปิดคลิกได้เฉพาะที่อยู่ใน _selectableSlots
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

          // ปุ่ม Cancel / Submit
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: _submitting ? null : widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canSubmit ? const Color(0xFF4E5B4C) : Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submitting || !_canSubmit
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Confirm Request'),
                            content: Text(
                                'Do you want to reserve ${widget.roomName} at $selectedSlot ?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4E5B4C)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _submit();
                                },
                                child: const Text('Confirm',
                                    style: TextStyle(color: Colors.white)),
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
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit',
                        style: TextStyle(color: Colors.white, fontSize: 22)),
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
      onTap: !isEnabled
          ? null
          : () => setState(() {
                selectedSlot = time;
              }),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4, // สีจางเมื่อ disable
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
