import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../modelsData/room_data.dart';
import '../screensOfBrowseRoomList/base_browse_screen.dart';
import '../services/api_service.dart';
import 'package:mobile_project/user/request_form.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_project/user/login.dart';

class User extends StatefulWidget {
  const User({super.key});
  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  bool isWaiting = false;
  String username = '';
  List? rooms;
  void popDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(title: const Text('Error'), content: Text(message));
      },
    );
  }

  void getRooms() async {
    // get token from local storage
    final storage = await SharedPreferences.getInstance();
    String? token = storage.getString('token');
    if (token == null) {
      if (!mounted) return;
      // return to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const Login()),
      );
      return;
    }
    // decode token to get user info

    setState(() {
      isWaiting = true;
      username = storage.getString('username') ?? '';
    });

    await Future.delayed(const Duration(milliseconds: 300)); // เผื่อเวลาสั้นๆ
    setState(() {
      isWaiting = false;
    });
    try {
      final result = await ApiService.getRooms();
      setState(() {
        rooms = result;
      });
    } catch (e) {
      popDialog('Failed to load rooms: $e');
    } finally {
      setState(() {
        isWaiting = false;
      });
    }
  }

  void logout() async {
    // remove stored token
    final storage = await SharedPreferences.getInstance();
    await storage.remove('token');

    if (!mounted) return;
    // back to login, clear all history
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    getRooms();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFD8C38A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF476C5E),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Row(
                children: [
                  Text(
                    username,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: logout,
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
        body: TabBarView(
          children: [
            HomeTab(userName: username),
            StatusTab(),
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

// ========== Home ==========
class HomeTab extends StatefulWidget {
  final String userName;
  const HomeTab({super.key, required this.userName});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  RoomSlot? selectedSlot;

  void _goToRequestForm(RoomSlot slot) => setState(() => selectedSlot = slot);
  void _backToList() => setState(() => selectedSlot = null);

  @override
  Widget build(BuildContext context) {
    if (selectedSlot != null) {
      return RequestForm(
        roomId: selectedSlot!.no,
        roomName: selectedSlot!.room,
        initialSlot: selectedSlot!.timeSlots, // จาก DB เช่น "08.00-10.00"
        onCancel: _backToList,
      );
    }
    return BaseBrowseScreen(
      userRole: UserRole.user,
      userName: widget.userName,
      actionButtons: null,
      onSlotSelected: _goToRequestForm,
    );
  }
}

// ========== Status (โหลดรายการจองของฉัน) ==========
class StatusTab extends StatefulWidget {
  const StatusTab({super.key});
  @override
  State<StatusTab> createState() => _StatusTabState();
}

class _StatusTabState extends State<StatusTab> {
  late Future<List<RoomSlot>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<RoomSlot>> _load() async {
    // ดึง role_id จาก SharedPreferences (ถ้ามี login)
    // ถ้าไม่มี ให้ fallback เป็น 24 เช่นเดิม
    final sp = await SharedPreferences.getInstance();
    final roleId = sp.getInt('role_id') ?? 24;

    final list = await ApiService.getMyHistory(roleId);
    return list.map((e) => RoomSlot.fromJson(e)).toList();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<RoomSlot>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 80),
                Center(child: Text('Error: ${snap.error}')),
              ],
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                Center(child: Text('No reservations yet')),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final r = items[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.room,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Timeslot: ${r.timeSlots}'),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: r.statusColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        r.status,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ========== History ==========
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
