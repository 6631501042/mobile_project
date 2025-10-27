import 'package:flutter/material.dart';
import '../models/room_data.dart'; // แก้ไข Path แล้ว

class BaseBrowseScreen extends StatelessWidget {
  final UserRole userRole;
  final String userName;
  final Widget? actionButtons; // ปุ่ม Add/Edit / Reserve / Approve-Reject
  // final Widget? bottomNavBar; // ไม่จำเป็นต้องใช้ เพราะ Scaffold หลักจัดการแล้ว

  const BaseBrowseScreen({
    super.key,
    required this.userRole,
    required this.userName,
    this.actionButtons,
    // this.bottomNavBar, // ลบออกจาก constructor
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
  // ⚠️ หมายเหตุ: สีเหล่านี้ควรถูกกำหนดในไฟล์หลัก (Approver, Staff) เพื่อความเป็นระเบียบ
  // แต่ถูกเก็บไว้ที่นี่ชั่วคราวเพื่อรันโค้ด
  static const Color _cardColor = Color(0xFF6A994E);
  static const Color _tableHeaderColor = Color(0xFF90A959);

  @override
  Widget build(BuildContext context) {
    // ⚠️ BaseBrowseScreen ควร return แค่เนื้อหา (Content)
    // ลบ Scaffold, AppBar และ SafeArea ออก
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ⚠️ ลบ _buildHeader(appBarTitle) ที่มี Logo/Logout ซ้ำซ้อนออก

        const Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
          child: Text(
            'Browse room list', // ใช้หัวข้อหลักนี้แทน
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        _buildRoomTypeCards(),
        _buildFilterRow(),
        Expanded(
          child: _buildRoomListTable(),
        ),
        if (actionButtons != null) actionButtons!,
      ],
    );
  }

  // ⚠️ ลบ _buildHeader ออก

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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
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

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton('Room Type'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildFilterButton('Status'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _tableHeaderColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
        ],
      ),
    );
  }

  Widget _buildRoomListTable() {
    return Container(
      margin: const EdgeInsets.all(16.0),
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
                Expanded(flex: 3, child: Text('Time slots', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
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
          Expanded(flex: 3, child: Text(slot.timeSlots)),
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
