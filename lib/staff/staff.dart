import 'package:flutter/material.dart';

class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> {
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
                  const Text(
                    'Staff001',
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
        body: const TabBarView(
          children: [
            // home
            HomeTab(),
            // history
            HistoryTab(),
            // dashboard
            DashboardTab(),
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
// home
// ==========================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Welcome to Home',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ==========================
// history
// ==========================
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Reservation History',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ==========================
// dashboard
// ==========================
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
        ],
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
