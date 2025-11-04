import 'package:flutter/material.dart';
import '../modelsData/room_data.dart';
import '../screensOfBrowseRoomList/base_browse_screen.dart'; // ต้อง import base_browse_screen
import 'package:mobile_project/user/request_form.dart'; //มันคือ request form ของ user

// คลาสหลักสำหรับหน้า User Role
class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final String userName = 'User001'; // สมมติชื่อผู้ใช้
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFD8C38A),
        // appbar
        appBar: AppBar(
          backgroundColor: const Color(0xFF476C5E),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // image bird
              Row(
                children: [
                  Image.asset('assets/images/bird.png', height: 50),
                  const SizedBox(width: 8),
                  const Text(
                    'ROOM RESERVATION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // staff name / logout button
              Row(
                children: [
                  Text(
                    userName,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'LOGOUT',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // tab bar
        body: TabBarView(
          children: [
            // home
            HomeTab(userName: userName),
            // status
            StatusTab(),
            // history
            HistoryTab(),
          ],
        ),
        bottomNavigationBar: Container(
          color: const Color(0xFF476C5E),
          child: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.check_box_outlined), text: 'Check Status'),
              Tab(icon: Icon(Icons.schedule), text: 'History'),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================
// 1. Home Tab (Browse Room List)
// ==========================
class HomeTab extends StatefulWidget {
  final String userName;
  const HomeTab({super.key, required this.userName});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  RoomSlot? selectedSlot;

  void _goToRequestForm(RoomSlot slot) {
    setState(() {
      selectedSlot = slot;
    });
  }

  void _backToList() {
    setState(() {
      selectedSlot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ถ้า selectedSlot != null แสดง RequestForm
    if (selectedSlot != null) {
      return RequestForm(
        roomId: selectedSlot!.no, // ✅ ส่ง id แถวห้อง
        roomName: selectedSlot!.room,
        initialSlot: selectedSlot!.timeSlots,
        isInitiallyFree:
            (selectedSlot!.status == 'Free'), // ✅ อนุญาตกดต่อเมื่อ Free
        onCancel: _backToList,
      );
    }

    // ถ้า selectedSlot == null แสดง BaseBrowseScreen
    return BaseBrowseScreen(
      userRole: UserRole.user,
      userName: widget.userName,
      actionButtons: null,
      onSlotSelected: _goToRequestForm,
    );
  }
}

// ==========================
// 2. Status Tab
// ==========================
class StatusTab extends StatelessWidget {
  const StatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'My Reservation Status',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ==========================
// 3. History Tab
// ==========================
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'My Reservation History',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
