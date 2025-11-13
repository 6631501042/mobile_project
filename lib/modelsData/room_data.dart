// lib/modelsData/room_data.dart
import 'package:flutter/material.dart';

enum UserRole { user, staff, approver }

class RoomSlot {
  final int no; // = id ใน DB
  final String room; // rooms.roomname
  final String timeSlots; // rooms.timeslot (เช่น 08.00-10.00)
  final String status; // Free/Pending/Reserved/Disabled
  final String? roomType; // rooms.roomtype
  final String? imageUrl; // URL ของรูปเต็ม เช่น "http://.../uploads/xxx.png"

  RoomSlot({
    required this.no,
    required this.room,
    required this.timeSlots,
    required this.status,
    this.roomType,
    this.imageUrl,
  });
  factory RoomSlot.empty() {
    return RoomSlot(
      no: 0,
      room: '',
      timeSlots: '',
      status: 'Unknown',
      roomType: '',
      imageUrl: null,
    );
  }
  factory RoomSlot.fromJson(Map<String, dynamic> j) {
    final raw = (j['status'] as String? ?? '').toLowerCase();
    final normalized = switch (raw) {
      'free' => 'Free',
      'pending' => 'Pending',
      'reserved' => 'Reserved',
      'disable' => 'Disabled',
      _ => raw.isEmpty ? 'Free' : raw,
    };
    return RoomSlot(
      no: j['id'] as int,
      room: j['roomname'] as String,
      timeSlots: j['timeslot'] as String,
      status: normalized,
      roomType: j['roomtype'] as String?,
      imageUrl: j['imageUrl'] as String?,
    );
  }

  Color get statusColor {
    switch (status) {
      case 'Reserved':
        return const Color(0xFFC35757);
      case 'Pending':
        return const Color(0xFFE4AD65);
      case 'Free':
        return const Color(0xFF6A994E);
      case 'Disabled':
        return const Color(0xFF838A73);
      default:
        return Colors.grey;
    }
  }
}
