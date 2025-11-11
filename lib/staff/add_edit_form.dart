import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../modelsData/room_data.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;

class AddEditForm extends StatefulWidget {
  final bool isEdit;
  final RoomSlot? roomSlot;
  final VoidCallback onCancel;
  final int? roomId;
  final String? imageUrl;
  const AddEditForm({
    super.key,
    required this.isEdit,
    this.roomSlot,
    required this.onCancel,
    this.roomId,
    this.imageUrl,
  });

  @override
  State<AddEditForm> createState() => _AddEditFormState();
}

class _AddEditFormState extends State<AddEditForm> {
  final TextEditingController roomNameController = TextEditingController();

  bool isEnabled = true;
  File? selectedImage;
  String? selectedSlot;
  String? selectedRoomType;
  String? existingImageUrl;
  bool isLoading = false; // Add a loading state

  Future<void> _submitRoomData() async {
    final name = roomNameController.text;
    final status = isEnabled ? 'free' : 'disable';
    final slot = widget.isEdit
        ? selectedSlot ?? 'None'
        : '8:00-10:00, 10:00-12:00, 13:00-15:00, 15:00-17:00';

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Room name is required')));
      return;
    }

    // ✅ เริ่มจากใช้รูปเดิมเป็นค่าเริ่มต้นไว้ก่อน
    String? imageUrl = existingImageUrl;

    if (selectedImage != null) {
      // ตรวจว่าภาพที่เลือกใหม่เป็นภาพเดียวกับเดิมไหม
      final selectedFileName = selectedImage!.path.split('/').last;
      final oldFileName = existingImageUrl?.split('/').last;

      if (selectedFileName != oldFileName) {
        // 🔄 อัปโหลดเฉพาะเมื่อชื่อไฟล์ไม่เหมือนเดิม
        setState(() {
          isLoading = true;
        });
        imageUrl = await _uploadImage(selectedImage!);
      } else {
        debugPrint("The same picture, so there's no need to upload a new one.");
        imageUrl = existingImageUrl;
      }
    }

    try {
      if (widget.isEdit) {
        await ApiService.updateRoom(
          widget.roomId!,
          name,
          selectedRoomType ?? widget.roomSlot!.roomType,
          status,
          imageUrl ?? existingImageUrl,
          '',
        );
      } else {
        await ApiService.addRoom(
          name,
          selectedRoomType,
          status,
          imageUrl,
          slot,
        );
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Room saved successfully')));
      widget.onCancel();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save room: $e')));
    } finally {
      setState(() {
        isLoading = false; // Stop loading after request is finished
      });
    }
  }

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

  Future<String> _uploadImage(File image) async {
    try {
      // สร้าง multipart request ไปยัง API upload
      var uri = Uri.parse('${ApiService.base}/api/uploadImage');
      var request = http.MultipartRequest('POST', uri);

      // เพิ่มไฟล์ภาพ
      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        image.path,
      );
      request.files.add(multipartFile);

      // ส่ง request
      var response = await request.send();

      // ✅ แก้ตรงนี้ --- แทนที่ส่วนที่เคย return responseData
      if (response.statusCode == 200) {
        // แปลง stream เป็น string
        final body = await response.stream.bytesToString();
        // decode ข้อความ JSON ที่ backend ส่งมา
        final data = jsonDecode(body);
        // คืนค่าพาธของรูปกลับไป เช่น "/uploads/1708571234567.png"
        return data['imagePath'];
      } else {
        throw Exception('Image upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.roomSlot != null) {
      roomNameController.text = widget.roomSlot!.room;
      selectedSlot = widget.roomSlot!.timeSlots;
      isEnabled = widget.roomSlot!.status == 'Free';
      selectedRoomType = widget.roomSlot!.roomType;
      existingImageUrl = widget.roomSlot!.imageUrl ?? widget.imageUrl;
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
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Room Type', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedRoomType,
            items: const [
              DropdownMenuItem(value: 'smallroom', child: Text('Small Room')),
              DropdownMenuItem(value: 'mediumroom', child: Text('Medium Room')),
              DropdownMenuItem(value: 'largeroom', child: Text('Large Room')),
            ],
            onChanged: (value) {
              setState(() {
                selectedRoomType = value;
              });
            },
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
                  : existingImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${ApiService.base}$existingImageUrl',
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
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          widget.isEdit ? 'Confirm Edit' : 'Confirm Add',
                        ),
                        content: Text(
                          widget.isEdit
                              ? 'Are you sure you want to update this room?'
                              : 'Are you sure you want to add this room?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);

                              // Call _submitRoomData to process the form data
                              await _submitRoomData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4E5B4C),
                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(color: Colors.white),
                            ),
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
}
