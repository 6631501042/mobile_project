import 'package:flutter/material.dart';
import '../modelsData/room_data.dart';
import '../services/api_service.dart';
import 'room_detail_page.dart';
import 'dart:async';

class BaseBrowseScreen extends StatefulWidget {
  final UserRole userRole;
  final String userName;
  final Widget? actionButtons;
  final void Function(RoomSlot)? onSlotSelected;
  final void Function(RoomSlot)? onSlotSelectedForDetail;
  const BaseBrowseScreen({
    super.key,
    required this.userRole,
    required this.userName,
    this.actionButtons,
    this.onSlotSelected,
    this.onSlotSelectedForDetail,
  });

  @override
  State<BaseBrowseScreen> createState() => _BaseBrowseScreenState();
}

class _BaseBrowseScreenState extends State<BaseBrowseScreen> {
  RoomSlot? _selectedSlot;
  String _searchQuery = '';
  List<RoomSlot> _all = [];
  bool _loading = true;
  String _error = '';

  static const Color _cardColor = Color(0xFF6A994E);
  static const Color _tableHeaderColor = Color(0xFF90A959);

  @override
  void initState() {
    super.initState();
    _fetchRooms();
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) _fetchRooms();
    });
  }

  Future<void> _fetchRooms() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final list = await ApiService.getRooms();
      _all = list.map((e) => RoomSlot.fromJson(e)).toList();
      final now = DateTime.now();

      // ฟังก์ชันแปลง "08.00-10.00" → เวลาเริ่มและเวลาจบ
      bool isFutureSlot(String slot) {
        try {
          final parts = slot.split('-');
          if (parts.length != 2) return true; // ปล่อยผ่านถ้า format ไม่ถูก

          DateTime parseTime(String s) {
            final hhmm = s.replaceAll('.', ':');
            final parts = hhmm.split(':');
            final h = int.parse(parts[0]);
            final m = int.parse(parts[1]);
            // ใช้วันที่วันนี้
            return DateTime(now.year, now.month, now.day, h, m);
          }

          final start = parseTime(parts[0]);
          final end = parseTime(parts[1]);
          return end.isAfter(now); // ✅ แสดงเฉพาะที่ “ยังไม่จบ”
        } catch (e) {
          // ถ้าแปลงไม่ได้ให้แสดงไว้ก่อน
          return true;
        }
      }

      //  staff จะเห็นทุก slot รวมทั้งที่หมดเวลาแล้ว(ุถ้าทำเป็น comment ทุก role ก็จะเห็นปกติ)
      if (widget.userRole != UserRole.staff ) {
        _all = _all.where((room) => isFutureSlot(room.timeSlots)).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  List<RoomSlot> get _filterRoomSlots {
    final List<RoomSlot> filtered;
    if (_searchQuery.isEmpty) {
      filtered = List.from(_all);
    } else {
      final q = _searchQuery.toLowerCase();
      filtered = _all
          .where(
            (s) =>
                s.room.toLowerCase().contains(q) ||
                s.status.toLowerCase().contains(q) ||
                s.timeSlots.toLowerCase().contains(q),
          )
          .toList();
    }

    // 🧮 Sort by "no" (least → greatest)
    filtered.sort((a, b) => a.no.compareTo(b.no));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              'Browse room list',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        _buildSearchBar(),
        _buildRoomTypeCards(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : _buildRoomListTable(),
        ),
        if (widget.actionButtons != null) widget.actionButtons!,
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search room name or status...',
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFF6A994E), width: 2),
          ),
        ),
        onChanged: (v) => setState(() {
          _searchQuery = v;
          _selectedSlot = null;
        }),
      ),
    );
  }

  // images
  Widget _buildRoomTypeCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildRoomCard(
            'Small Room\n(SR)',
            'Room capacity:\n4 people',
            'smallroom', // ส่งค่า roomType เป็น string
          ),
          const SizedBox(width: 8),
          _buildRoomCard(
            'Medium Room\n(MR)',
            'Room capacity:\n8 people',
            'mediumroom', // ส่งค่า roomType เป็น string
          ),
          const SizedBox(width: 8),
          _buildRoomCard(
            'Large Room\n(LR)',
            'Room capacity:\n10 people',
            'largeroom', // ส่งค่า roomType เป็น string
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(String title, String subtitle, String roomType) {
  return Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        // --- เริ่มส่วนเตรียมข้อมูล ---

        // 1. กรองห้องทั้งหมดให้เหลือเฉพาะ roomType ที่ต้องการและมีรูป
        final roomsForThisType = _all
            .where((r) => r.roomType == roomType && r.imageUrl != null)
            .toList();

        // 2. ดึงชื่อห้องที่ไม่ซ้ำ
        final uniqueRoomNames = roomsForThisType.map((r) => r.room).toSet().toList();

        // 3. สร้าง List ของข้อมูลห้องที่ไม่ซ้ำเพื่อส่งไปแสดงผล
        final List<RoomSlot> uniqueRooms = uniqueRoomNames.map((name) {
          return roomsForThisType.firstWhere((r) => r.room == name);
        }).toList();
        
        // 4. สร้าง Map ที่เก็บ slot ทั้งหมดของแต่ละห้อง
        final Map<String, List<RoomSlot>> allSlotsByRoom = {};
        for (var roomName in uniqueRoomNames) {
          allSlotsByRoom[roomName] = _all.where((slot) => slot.room == roomName).toList();
        }

        // --- จบส่วนเตรียมข้อมูล ---

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailPage(
              title: title.split('\n').first,
              userRole: widget.userRole,
              // 👈 ส่งข้อมูลที่เตรียมไว้ไปให้
              uniqueRooms: uniqueRooms,
              allSlotsByRoom: allSlotsByRoom,
              onSlotSelected: widget.onSlotSelectedForDetail ?? widget.onSlotSelected,
            ),
          ),
        );
      },
        child: SizedBox(
          // ... โค้ด Container เดิม ...
          height: 85,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Text(
              '6 November 2025',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: const BoxDecoration(color: _tableHeaderColor),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'No.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Room',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Time slots',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ), // Flex 2 เพื่อแก้ปัญหาล้นจอ
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filterRoomSlots.length,
              itemBuilder: (context, index) {
                return _buildTableRow(_filterRoomSlots[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(RoomSlot slot, int index) {
    bool isSelected = _selectedSlot == slot;

    // 🚫 ปิดการคลิกถ้าห้องอยู่ในสถานะที่ไม่อนุญาต
    bool isClickable;
    // 🎭 แยกตามบทบาท
    switch (widget.userRole) {
      case UserRole.user:
        isClickable = slot.status == 'Free';
        break;
      case UserRole.staff:
        isClickable = slot.status == 'Free' || slot.status == 'Disabled';
        break;
      case UserRole.approver:
        isClickable = false; // ❌ ห้ามคลิก
        break;
    }

    // ✅ ไม่มี opacity สำหรับ Approver
    final double rowOpacity = widget.userRole == UserRole.approver
        ? 1.0
        : (isClickable ? 1.0 : 0.6);

    return GestureDetector(
      onTap: isClickable
          ? () {
              setState(() {
                _selectedSlot = slot;
              });
              // เรียก callback เสมอ เพื่อให้ Parent (HomeTab) รับรู้
              if (widget.onSlotSelected != null) {
                widget.onSlotSelected!(slot);
              }
            }
          : null,
      child: Opacity(
        opacity: rowOpacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.amber.withOpacity(0.3)
                : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: Colors.black12, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(flex: 1, child: Text('${slot.no}')),
              Expanded(flex: 2, child: Text(slot.room)),
              Expanded(flex: 2, child: Text(slot.timeSlots)),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
