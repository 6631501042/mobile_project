import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../modelsData/room_data.dart'; 
class AddEditForm extends StatefulWidget {
  final bool isEdit;
  final RoomSlot? roomSlot;
  final VoidCallback onCancel;

  const AddEditForm({
    super.key,
    required this.isEdit,
    this.roomSlot,
    required this.onCancel,
  });

  @override
  State<AddEditForm> createState() => _AddEditFormState();
}

class _AddEditFormState extends State<AddEditForm> {
  final TextEditingController roomNameController = TextEditingController();

  // ใช้แทน Dropdown เดิม
  bool isEnabled = true;
  File? selectedImage;
  // สำหรับ Edit (เลือกได้ช่องเดียว)
  String? selectedSlot;

  //  ฟังก์ชันเลือกรูป
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  // ไว้ดึงข้อมูลจาก API
  @override
  void initState() {
    super.initState();
    // ถ้าเป็นโหมด Edit และมีข้อมูลห้องส่งมา
  if (widget.isEdit && widget.roomSlot != null) {
    roomNameController.text = widget.roomSlot!.room;
    selectedSlot = widget.roomSlot!.timeSlots;
    isEnabled = widget.roomSlot!.status == 'Free';
  }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.isEdit ? 'Edit Room' : 'Add Room',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Room Name
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Room Name', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: roomNameController,
            decoration: InputDecoration(
              hintText: 'Enter room name',
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

          // Switch แทน Dropdown
          Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Room Status', style: TextStyle(fontSize: 22)),
              ),
              Row(
                children: [
                  Text(
                    isEnabled ? 'Free' : 'Disable',
                    style: TextStyle(
                      fontSize: 18,
                      color: isEnabled ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    value: isEnabled,
                    onChanged: (value) {
                      setState(() {
                        isEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          //  UI แสดงและเปลี่ยนรูป
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Room Image', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Center(
                      child: Text(
                        widget.isEdit
                            ? 'Tap to change image'
                            : 'Tap to add image',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // แสดงเฉพาะในโหมด Edit เท่านั้น
          if (widget.isEdit) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Select Time Slot', style: TextStyle(fontSize: 22)),
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
            const SizedBox(height: 30),
          ],

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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.isEdit ? 'Confirm Edit' : 'Confirm Add'),
          content: Text(
            widget.isEdit
                ? 'Are you sure you want to update this room?'
                : 'Are you sure you want to add this room?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // ปิด dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // ปิด dialog ก่อน
                final name = roomNameController.text;
                final status = isEnabled ? 'Free' : 'Disable';
                final slot = widget.isEdit
                    ? selectedSlot ?? 'None'
                    : '8:00-10:00, 10:00-12:00, 13:00-15:00, 15:00-17:00';

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.isEdit
                          ? 'Updated: $name ($status) — $slot'
                          : 'Added: $name ($status) — $slot',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E5B4C),
              ),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  },
  child: Text(
    widget.isEdit ? 'Update' : 'Add',
    style: const TextStyle(color: Colors.white, fontSize: 22),
  ),
),

            ],
          ),
        ],
      ),
    );
  }

  // สร้างตาราง time slot
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
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFAFBEA2) : Colors.transparent,
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
            color: isSelected ? const Color(0xFFAFBEA2) : Colors.blueAccent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
