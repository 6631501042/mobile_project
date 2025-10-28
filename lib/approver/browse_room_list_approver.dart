import 'package:flutter/material.dart';
import '../models/room_data.dart';
import '../screens/base_browse_screen.dart';

// --- Placeholder Widgets for Tabs ---

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('History Tab Content (Approver)'));
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});
  @override
  Widget build(BuildContext context) {
    // 🛑 ห่อด้วย SingleChildScrollView เพื่อแก้ไขปัญหา Overflow
    return const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Dashboard Tab Content (Approver)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 2000), // Mock content to ensure scrolling works
            Text('End of Dashboard'),
          ],
        ));
  }
}

class HomeTabApprover extends StatelessWidget {
  final String userName;
  const HomeTabApprover({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return BaseBrowseScreen(
      userRole: UserRole.approver,
      userName: userName,
    );
  }
}

// --- Main Screen ---

class BrowseRoomListApprover extends StatefulWidget {
  const BrowseRoomListApprover({super.key});
  @override
  State<BrowseRoomListApprover> createState() => _BrowseRoomListApproverState();
}

class _BrowseRoomListApproverState extends State<BrowseRoomListApprover> {
  final String userName = 'Approver Name';
  static const Color _primaryColor = Color(0xFF558B6E); // Logo / Text color
  static const Color _baseColor = Color(0xFFD8C38A); // Background color
  static const Color _logoutColor = Color(0xFFC35757); // Logout Color

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
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
          // ⚠️ ไม่มี PreferredSize ด้านล่าง (แก้ไขตามที่คุณต้องการ)
        ),

        // --- TabBarView ---
        body: SafeArea(
          child: TabBarView(
            children: [
              // 1. Home Tab: Browse Room List (No action buttons now)
              HomeTabApprover(userName: userName), 
              // 2. History Tab:
              const HistoryTab(),
              // 3. Dashboard Tab:
              const DashboardTab(),
            ],
          ),
        ),

        // --- Bottom Navigation Bar (TabBar) ---
        bottomNavigationBar: Container(
          color: _primaryColor,
          child: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.history), text: 'History'),
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            ],
          ),
        ),
      ),
    );
  }
}
