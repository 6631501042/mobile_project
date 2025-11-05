import 'package:flutter/material.dart';
import '../modelsData/room_data.dart';
import '../services/api_service.dart';

class BaseBrowseScreen extends StatefulWidget {
  final UserRole userRole;
  final String userName;
  final Widget? actionButtons;
  final void Function(RoomSlot)? onSlotSelected;

  const BaseBrowseScreen({
    super.key,
    required this.userRole,
    required this.userName,
    this.actionButtons,
    this.onSlotSelected,
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
  }

  Future<void> _fetchRooms() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final list = await ApiService.getRooms();
      _all = list.map((e) => RoomSlot.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  List<RoomSlot> get _filterRoomSlots {
    if (_searchQuery.isEmpty) return _all;
    final q = _searchQuery.toLowerCase();
    return _all.where((s) =>
      s.room.toLowerCase().contains(q) ||
      s.status.toLowerCase().contains(q) ||
      s.timeSlots.toLowerCase().contains(q),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8, left: 16),
          child: Text('Browse room list', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFF6A994E), width: 2),
          ),
        ),
        onChanged: (v) => setState(() { _searchQuery = v; _selectedSlot = null; }),
      ),
    );
  }

  Widget _buildRoomTypeCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
      child: SizedBox(
        height: 85,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
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
    bool isClickable =
        !(slot.status == 'Pending' ||
            slot.status == 'Reserved' ||
            slot.status == 'Disabled');

    return GestureDetector(
      onTap: isClickable
          ? () {
              setState(() {
                _selectedSlot = slot;
              });
              if (widget.onSlotSelected != null) {
                widget.onSlotSelected!(slot);
              }
            }
          : null, // ❌ ถ้าไม่อนุญาตให้คลิก, onTap จะเป็น null
      child: Opacity(
        opacity: isClickable ? 1.0 : 0.6, // ทำให้แถวที่คลิกไม่ได้ดูจางลง
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
