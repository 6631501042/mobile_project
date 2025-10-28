import 'package:flutter/material.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  String status = "Pending"; // You can change this dynamically later

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D5A9), // beige background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF51624F), // green top bar
        toolbarHeight: 80,
        title: Row(
          children: [
            // Logo placeholder
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFAFBEA2),
              child: const Text('🐦', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROOM',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5),
                ),
                Text(
                  'RESERVATION',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5),
                ),
              ],
            ),
            const Spacer(),
            const Text(
              '6631501xxx',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(width: 10),
            Material(
              color: const Color(0xFFD94B4B),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // ✅ Navigate to another screen on logout
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LogoutScreen()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'LOGOUT',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Status',
                style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),

            // Header Row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Room',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87),
                ),
                Text(
                  'Action',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Room card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F5E5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black54, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LR-104',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '28 Sep 2025',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.5)),
                      ),
                      Text(
                        '8.00-10.00',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.5)),
                      ),
                    ],
                  ),

                  // Right - Status chip (dynamic)
                  Container(
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      status,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom navigation
            const Divider(thickness: 1),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.home_outlined, size: 34),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1AC67),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.check_box_outlined,
                      size: 34, color: Colors.black),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.schedule_outlined, size: 34),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// Helper: color changes based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.greenAccent;
      case 'Rejected':
        return Colors.redAccent;
      default:
        return Colors.yellow[300]!;
    }
  }
}

// Dummy page for logout navigation
class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Back to status page
          },
          child: const Text("Back to Status Page"),
        ),
      ),
    );
  }
}
