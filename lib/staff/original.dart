import 'package:flutter/material.dart';

class DashboardStaff extends StatefulWidget {
  const DashboardStaff({super.key});

  @override
  State<DashboardStaff> createState() => _DashboardStaffState();
}

class _DashboardStaffState extends State<DashboardStaff> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color(0xFFD8C38A),
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
              // ajarn name
              Row(
                children: [
                  const Text(
                    'Staff001',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  // logout button
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      side: BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'LOGOUT',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //body
        body: Center(
          child: Column(
            children: [
              // dashboard
              SizedBox(height: 30),
              Text(
                'Dashboard',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '20',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // grid cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  // card
                  children: [
                    // card 1
                    Card(
                      color: Colors.greenAccent[100],
                      elevation: 4,
                      child: InkWell(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/free.png',
                                // width: 20,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Free Slots',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text('5', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // card 2
                    Card(
                      color: Colors.amberAccent[100],
                      elevation: 4,
                      child: InkWell(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/pending.png',
                                // width: 20,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Pending Slots',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text('5', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // card 3
                    Card(
                      color: Colors.blueAccent[100],
                      elevation: 4,
                      child: InkWell(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/reserve.png',
                                // width: 20,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Reserved Slots',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text('7', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // card 4
                    Card(
                      color: Colors.redAccent[100],
                      elevation: 4,
                      child: InkWell(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/disable.png',
                                // width: 20,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Disabled Rooms',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text('3', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // tab bar
              TabBar(
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: 'Home', icon: Icon(Icons.home)),
                  Tab(text: 'History', icon: Icon(Icons.schedule)),
                  Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
