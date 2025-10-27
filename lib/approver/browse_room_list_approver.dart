import 'package:flutter/material.dart';
import '../models/room_data.dart'; // Import necessary for UserRole enum
import '../screens/base_browse_screen.dart'; // Import BaseBrowseScreen

// คลาสหลักสำหรับหน้า Approver Role
class BrowseRoomListApprover extends StatefulWidget {
  const BrowseRoomListApprover({super.key});

  @override
  State<BrowseRoomListApprover> createState() => _BrowseRoomListApproverState();
}

class _BrowseRoomListApproverState extends State<BrowseRoomListApprover> {
  final String userName = 'Approver001'; // สมมติชื่อผู้ใช้
  
  // กำหนดสีหลักของ Role นี้
  static const Color _primaryColor = Color(0xFF476C5E);
  static const Color _baseColor = Color(0xFFD8C38A);
  static const Color _logoutColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Home, History, Dashboard
      child: Scaffold(
        backgroundColor: _baseColor,
        
        // --- Custom AppBar ---
        appBar: AppBar(
          automaticallyImplyLeading: false, 
          backgroundColor: _primaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Image/Logo and Title with Role
              Row(
                children: [
                  Image.asset('assets/images/bird.png', height: 40), 
                  const SizedBox(width: 8),
                  const Text(
                    'ROOM RESERVATION (Approver)', // แสดง Role ใน Title
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
          // ⚠️ ไม่มี PreferredSize ด้านล่าง
        ),

        // --- TabBarView ---
        body: TabBarView(
          children: [
            // 1. Home Tab: Browse Room List + Approve/Reject
            HomeTab(userName: userName), 
            // 2. History Tab:
            const HistoryTab(),
            // 3. Dashboard Tab:
            const DashboardTab(),
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
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================
// 1. Home Tab (Browse Room List + Approve/Reject)
// ==========================
class HomeTab extends StatelessWidget {
  final String userName;
  const HomeTab({super.key, required this.userName});

  // ปุ่ม Approve และ Reject สำหรับ Approver
  Widget _buildActionButtons() {
    const Color approveColor = Colors.green;
    const Color rejectColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: approveColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Approve', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: rejectColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Reject', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseBrowseScreen(
      userRole: UserRole.approver,
      userName: userName,
      actionButtons: _buildActionButtons(),
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
        'Approval History',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ==========================
// 3. Dashboard Tab (โครงสร้างเดียวกับ Staff)
// ==========================
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '20',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), 
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                children: [
                  _card(
                    'assets/images/free.png',
                    'Free Slots',
                    '5',
                    Colors.greenAccent[100]!,
                  ),
                  _card(
                    'assets/images/pending.png',
                    'Pending Slots',
                    '5',
                    Colors.amberAccent[100]!,
                  ),
                  _card(
                    'assets/images/reserve.png',
                    'Reserved Slots',
                    '7',
                    Colors.blueAccent[100]!,
                  ),
                  _card(
                    'assets/images/disable.png',
                    'Disabled Rooms',
                    '3',
                    Colors.redAccent[100]!,
                  ),
                ],
              ),
            ),
             const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _card(String img, String title, String value, Color color) {
    return Card(
      color: color,
      elevation: 4,
      child: InkWell(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(img, height: 60, fit: BoxFit.cover),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 16)),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
