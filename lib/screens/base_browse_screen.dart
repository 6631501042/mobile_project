import 'package:flutter/material.dart';
import '../models/room_data.dart'; 

class BaseBrowseScreen extends StatelessWidget {
  final UserRole userRole;
  final String userName;
  final Widget? actionButtons; // ปุ่ม Add/Edit / Reserve / Approve-Reject

  const BaseBrowseScreen({
    super.key,
    required this.userRole,
    required this.userName,
    this.actionButtons,
  });

  // ข้อมูลจำลอง (Mock Data)
  static final List<RoomSlot> _roomSlots = [
    RoomSlot(no: 1, room: 'LR-101', timeSlots: '8:00-10:00', status: 'Reserved'),
    RoomSlot(no: 2, room: 'LR-101', timeSlots: '10:00-12:00', status: 'Pending'),
    RoomSlot(no: 3, room: 'LR-101', timeSlots: '13:00-15:00', status: 'Free'),
    RoomSlot(no: 4, room: 'LR-101', timeSlots: '15:00-17:00', status: 'Free'),
    RoomSlot(no: 5, room: 'LR-102', timeSlots: '8:00-10:00', status: 'Disabled'),
    RoomSlot(no: 6, room: 'LR-102', timeSlots: '8:00-12:00', status: 'Disabled'),
    RoomSlot(no: 7, room: 'LR-102', timeSlots: '8:00-10:00', status: 'Request'),
  ];
  
  // กำหนดสี
  static const Color _cardColor = Color(0xFF6A994E);
  static const Color _tableHeaderColor = Color(0xFF90A959);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
          child: Text(
            'Browse room list',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        _buildRoomTypeCards(),
        // 🛑 ลบ _buildFilterRow() ออกตามความต้องการ
        Expanded(
          child: _buildRoomListTable(),
        ),
        if (actionButtons != null) actionButtons!,
      ],
    );
  }

  // --- Widgets ย่อยที่ใช้ร่วมกัน ---

  Widget _buildRoomTypeCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildRoomCard('Small Room\n(SR)', 'Room capacity:\n4 people'),
          const SizedBox(width: 8),
          _buildRoomCard('Medium Room\n(MR)', 'Room capacity:\n8 people'),
          const SizedBox(width: 8),
          _buildRoomCard('Large Room\n(LR)', 'Room capacity:\n10 people'),
        ],
      ),
    );
  }

  Widget _buildRoomCard(String title, String subtitle) {
    return Expanded(
      child: ConstrainedBox( // 🛑 ใช้ ConstrainedBox เพื่อกำหนดความสูงขั้นต่ำ
        constraints: const BoxConstraints(minHeight: 100), 
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 🛑 จัดให้เนื้อหากระจายตามความสูง
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDot(Colors.white),
                      _buildDot(Colors.white.withOpacity(0.5)),
                      _buildDot(Colors.white.withOpacity(0.3)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // 🛑 ลบ _buildFilterRow และ _buildFilterButton ออกไปทั้งหมด

  Widget _buildRoomListTable() {
    return Container(
      // 🛑 ปรับ Margin ด้านบนจาก all(16.0) เป็น fromLTRB(16.0, 8.0, 16.0, 16.0) เพื่อให้ List Table เลื่อนขึ้น
      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _tableHeaderColor.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: const Text(
              '28 March 2024',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: const BoxDecoration(
              color: _tableHeaderColor,
            ),
            child: const Row(
              children: [
                Expanded(flex: 1, child: Text('No.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Time slots', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), // Flex 2 เพื่อแก้ปัญหาล้นจอ
                Expanded(flex: 2, child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _roomSlots.length,
              itemBuilder: (context, index) {
                return _buildTableRow(_roomSlots[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(RoomSlot slot, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('${slot.no}')),
          Expanded(flex: 2, child: Text(slot.room)),
          Expanded(flex: 2, child: Text(slot.timeSlots)), // Flex 2 ให้ตรงกับ Header
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: slot.statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  slot.status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
