import 'package:flutter/material.dart';
import '../modelsData/room_data.dart'; // Import necessary for UserRole enum
import '../screensOfBrowseRoomList/base_browse_screen.dart'; // Import BaseBrowseScreen
import 'package:mobile_project/staff/add_edit_form.dart'; //for staff

class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  final String userName = 'Staff001';
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
class HomeTab extends StatefulWidget  {
  final String userName;
  const HomeTab({super.key, required this.userName});
@override
  State<HomeTab> createState() => _HomeTabState();
}
class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin<HomeTab> {
  bool isAdding = false;
  bool isEditing = false;
  RoomSlot? selectedSlot;
  @override
  bool get wantKeepAlive => true;
  Widget _buildActionButtons() {
    const Color addColor = Color(0xFFF09598);
    const Color editColor = Color(0xFF3F3735);


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isAdding = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: addColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ElevatedButton(
                onPressed: selectedSlot == null
                    ? null // ✅ ปิดปุ่มถ้ายังไม่ได้เลือกห้อง
                    : () {
                        setState(() {
                          isEditing = true;
                          isAdding = false;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedSlot == null ? Colors.grey : editColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void resetEditState() {
    setState(() {
      isEditing = false;
      selectedSlot = null; // รีเซ็ตห้องที่เลือก
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // ✅ กรณี Add
    if (isAdding) {
      return AddEditForm(
        isEdit: false,
        onCancel: () {
          setState(() {
            isAdding = false;
          });
        },
      );
    }

      // กรณี Edit
    if (isEditing && selectedSlot != null) {
      return AddEditForm(
        isEdit: true,
        roomSlot: selectedSlot,
        onCancel: () {
          resetEditState(); // รีเซ็ตเฉพาะ Edit
        },
      );
    }

    // ✅ แสดง Browse ปกติ
    return BaseBrowseScreen(
      userRole: UserRole.staff,
      userName: widget.userName,
      actionButtons: _buildActionButtons(),
      onSlotSelected: (slot) {
        setState(() {
          selectedSlot = slot; // ✅ เก็บห้องที่เลือก
        });
      },
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
