import 'package:flutter/material.dart';

class DashboardStaff extends StatefulWidget {
  const DashboardStaff({super.key});

  @override
  State<DashboardStaff> createState() => _DashboardStaffState();
}

class _DashboardStaffState extends State<DashboardStaff> {
  // Reactive slot counts
  int freeSlots = 5;
  int pendingSlots = 5;
  int reservedSlots = 7;
  int disabledRooms = 3;

  // Example simulation functions
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

  int get total => freeSlots + pendingSlots + reservedSlots + disabledRooms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8C38A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF476C5E),
        elevation: 0, //??
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/images/bird.png', height: 30),
                const SizedBox(width: 8),
                const Text(
                  'ROOM RESERVATION',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Ajarn.Tick'),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('LOGOUT',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),

      // Body
      body: SingleChildScrollView(
        child: Column(
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

            // Grid cards
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
                    color: Colors.greenAccent.shade100,
                  ),
                  _buildDashboardCard(
                    title: 'Pending Slots',
                    count: pendingSlots,
                    color: Colors.yellowAccent.shade100,
                  ),
                  _buildDashboardCard(
                    title: 'Reserved Slots',
                    count: reservedSlots,
                    color: Colors.lightBlueAccent.shade100,
                  ),
                  _buildDashboardCard(
                    title: 'Disabled Rooms',
                    count: disabledRooms,
                    color: Colors.redAccent.shade100,
                  ),
                ],
              ),
            ),

            // Demo buttons to test changes
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: reserveRoom, child: const Text("Reserve Room")),
                ElevatedButton(
                    onPressed: approveReservation,
                    child: const Text("Approve Reservation")),
                ElevatedButton(
                    onPressed: disableRoom, child: const Text("Disable Room")),
                ElevatedButton(
                    onPressed: enableRoom, child: const Text("Enable Room")),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      // Bottom navigation
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

  // Helper widget for cards
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
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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
