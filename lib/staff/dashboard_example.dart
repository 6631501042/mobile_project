import 'package:flutter/material.dart';

class DashboardStaff extends StatefulWidget {
  final String ajarnName; // 👈 dynamic name passed in

  const DashboardStaff({super.key, required this.ajarnName});

  @override
  State<DashboardStaff> createState() => _DashboardStaffState();
}

class _DashboardStaffState extends State<DashboardStaff> {
  int freeSlots = 5;
  int pendingSlots = 5;
  int reservedSlots = 7;
  int disabledRooms = 3;

  void reserveRoom() {
    if (freeSlots > 0) {
      setState(() {
        freeSlots--;
        pendingSlots++;
      });
    }
  }

  void approveReservation() {
    if (pendingSlots > 0) {
      setState(() {
        pendingSlots--;
        reservedSlots++;
      });
    }
  }

  void disableRoom() {
    if (freeSlots > 0) {
      setState(() {
        freeSlots--;
        disabledRooms++;
      });
    }
  }

  void enableRoom() {
    if (disabledRooms > 0) {
      setState(() {
        disabledRooms--;
        freeSlots++;
      });
    }
  }

  int get total =>
      freeSlots + pendingSlots + reservedSlots + disabledRooms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8C38A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF476C5E),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: logo + title
            Row(
              children: [
                Image.asset('assets/logo.png', height: 30),
                const SizedBox(width: 8),
                const Text(
                  'ROOM RESERVATION',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),

            // Right: dynamic Ajarn name + Logout
            Row(
              children: [
                Text(
                  widget.ajarnName, // 👈 shows name dynamically
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Add logout logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'LOGOUT',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '$total',
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                    title: 'Free Slots',
                    count: freeSlots,
                    color: Colors.greenAccent.shade100),
                _buildDashboardCard(
                    title: 'Pending Slots',
                    count: pendingSlots,
                    color: Colors.yellowAccent.shade100),
                _buildDashboardCard(
                    title: 'Reserved Slots',
                    count: reservedSlots,
                    color: Colors.lightBlueAccent.shade100),
                _buildDashboardCard(
                    title: 'Disabled Rooms',
                    count: disabledRooms,
                    color: Colors.redAccent.shade100),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFD8C38A),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time_outlined), label: 'Time'),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_box_outlined), label: 'Check'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.grid_view_rounded, size: 40),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(
            '$count',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
