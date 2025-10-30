import 'package:flutter/material.dart';

class RequestForm extends StatefulWidget {
  final VoidCallback onCancel;
  final String roomName; // เพิ่มพารามิเตอร์ห้อง
  final String initialSlot; // เพิ่มพารามิเตอร์ช่วงเวลา

  const RequestForm({
    super.key,
    required this.onCancel,
    required this.roomName,
    required this.initialSlot,
  });

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  late String? selectedSlot;

  @override
  void initState() {
    super.initState();
    selectedSlot = widget.initialSlot; // กำหนดค่าเริ่มต้นจากพารามิเตอร์
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
          const SizedBox(height: 20),

          // Room Name
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Room Name', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: widget.roomName,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
            ),
          ),

          const SizedBox(height: 16),
          Image.asset(
            'assets/images/MeetingRoom.jpg',
            height: 150,
            fit: BoxFit.cover,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E5B4C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (selectedSlot == null) {
                    // กรณีไม่ได้เลือกเวลา
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Warning'),
                        content: const Text(
                          'Please select a time slot before submitting.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // แสดง AlertDialog ยืนยันการจอง
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Request'),
                        content: Text(
                          'Do you want to reserve ${widget.roomName} at $selectedSlot ?',
                        ),

                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context), // ปิด dialog
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4E5B4C),
                            ),
                            onPressed: () {
                              Navigator.pop(context); // ปิด dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Request sent for $selectedSlot',
                                  ),
                                ),
                              );
                              widget.onCancel(); // กลับไปหน้าเดิม
                            },
                            child: const Text(
                              'Confirm',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text(
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
    bool isSelected = selectedSlot == time;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSlot = time;
        });
      },
      child: Container(
        height: 70,
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFAFBEA2) : Colors.transparent,
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
            color: isSelected ? Color(0xFFAFBEA2) : Colors.blueAccent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,

              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}
