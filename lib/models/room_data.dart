// lib/models/room_data.dart

import 'package:flutter/material.dart';

// --- Enum สำหรับบทบาทผู้ใช้ ---
enum UserRole {
  user,
  staff,
  approver,
}
// ------------------------------

class RoomSlot {
  final int no;
  final String room;
  final String timeSlots;
  final String status;

  RoomSlot({
    required this.no,
    required this.room,
    required this.timeSlots,
    required this.status,
  });

  // กำหนดสีตามสถานะห้อง
  Color get statusColor {
    switch (status) {
      case 'Reserved':
        return const Color(0xFFC35757); // สีแดงตามภาพ
      case 'Pending':
        return const Color(0xFFE4AD65); // สีส้มตามภาพ
      case 'Free':
        return const Color(0xFF6A994E); // สีเขียวเข้ม
      case 'Disabled':
        return const Color(0xFF838A73); // สีเทาอมเขียว
      case 'Request':
        return const Color(0xFF6A994E); // ใช้สีเขียวเข้มเหมือน Free
      default:
        return Colors.grey;
    }
  }
}