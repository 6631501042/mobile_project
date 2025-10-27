import 'package:flutter/material.dart';
import '../models/room_data.dart'; // ต้อง import room_data
import '../screens/base_browse_screen.dart'; // ต้อง import base_browse_screen

// คลาสหลักสำหรับหน้า User Role
class BrowseRoomListUser extends StatefulWidget {
  const BrowseRoomListUser({super.key});

  @override
  State<BrowseRoomListUser> createState() => _BrowseRoomListUserState();
}

class _BrowseRoomListUserState extends State<BrowseRoomListUser> {
  final String userName = 'User001'; // สมมติชื่อผู้ใช้
  
  // กำหนดสีหลักของ Role นี้ (ใช้สีเดียวกับ Staff เพื่อความสม่ำเสมอของ App Bar)
  static const Color _primaryColor = Color(0xFF476C5E);
  static const Color _baseColor = Color(0xFFD8C38A);
  static const Color _logoutColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // User มีแค่ Home และ History
      child: Scaffold(
        backgroundColor: _baseColor,
        
        // --- Custom AppBar ---
        appBar: AppBar(
          automaticallyImplyLeading: false, 
          backgroundColor: _primaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Image/Logo
              Row(
                children: [
                  // ⚠️ ต้องมี Image file ใน assets/images/bird.png
                  Image.asset('assets/images/bird.png', height: 40), 
                  const SizedBox(width: 8),
                  const Text(
                    'ROOM RESERVATION (User)', // ⬅️ เพิ่ม Role เข้าไปใน Title หลักแทน
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // User Name / Logout button
              Row(
                children: [
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: _logoutColor,
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
          // ⚠️ ลบ PreferredSize ออก:
          /*
          bottom: const PreferredSize( 
            preferredSize: Size.fromHeight(20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, bottom: 4.0),
                child: Text(
                  'Browse room list(User)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white70),
                ),
              ),
            ),
          ),
          */
        ),

        // --- TabBarView ---
        body: TabBarView(
          children: [
            // 1. Home Tab: ใช้ BaseBrowseScreen พร้อมปุ่ม Reserve
            HomeTab(userName: userName), 
            // 2. History Tab:
            const HistoryTab(),
          ],
        ),

        // --- Bottom Navigation Bar (TabBar) ---
        bottomNavigationBar: Container(
          color: _primaryColor,
          child: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.schedule), text: 'History'),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================
// 1. Home Tab (Browse Room List + Reservation Button)
// ==========================
class HomeTab extends StatelessWidget {
  final String userName;
  const HomeTab({super.key, required this.userName});

  // ปุ่ม Reservation สำหรับ User
  Widget _buildReservationButton() {
    const Color reserveColor = Color(0xFF4CAF50); // เขียว
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_task, color: Colors.white),
          label: const Text('New Reservation', style: TextStyle(color: Colors.white, fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: reserveColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ BaseBrowseScreen เป็น Home Tab
    return BaseBrowseScreen(
      userRole: UserRole.user,
      userName: userName,
      actionButtons: _buildReservationButton(),
    );
  }
}

// ==========================
// 2. History Tab
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
