import 'package:flutter/material.dart';

class GridCardNoLoop extends StatelessWidget {
  const GridCardNoLoop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grid Cards (No Loop)"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2, // number of columns
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            // 🟦 Card 1
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  print("Card 1 tapped");
                },
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, size: 40, color: Colors.blue),
                      SizedBox(height: 10),
                      Text('Home', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),

            // 🟩 Card 2
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  print("Card 2 tapped");
                },
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 40, color: Colors.green),
                      SizedBox(height: 10),
                      Text('Profile', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),

            // 🟧 Card 3
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  print("Card 3 tapped");
                },
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.settings, size: 40, color: Colors.orange),
                      SizedBox(height: 10),
                      Text('Settings', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),

            // 🟥 Card 4
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  print("Card 4 tapped");
                },
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications, size: 40, color: Colors.red),
                      SizedBox(height: 10),
                      Text('Alerts', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            // example
            Card(
              color: Colors.amberAccent[100],
              elevation: 4,
              child: InkWell(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/bird.png'),
                      // Icon(Icons.home, size: 40, color: Colors.blue),
                      SizedBox(height: 10),
                      Text('Pending Slots', style: TextStyle(fontSize: 16)),
                      Text('5', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
