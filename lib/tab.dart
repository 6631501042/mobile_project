import 'package:flutter/material.dart';

class TabDemo extends StatefulWidget {
  const TabDemo({super.key});

  @override
  State<TabDemo> createState() => _TabDemoState();
}

class _TabDemoState extends State<TabDemo> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tab Demo'),
          // bottom: TabBar(
          //   tabs: [
          //     Tab(icon: Icon(Icons.home), text: 'Home'),
          //     Tab(icon: Icon(Icons.train), text: 'Train'),
          //     Tab(icon: Icon(Icons.bike_scooter), text: 'Bike'),
          //   ],
          // ),
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.train), text: 'Train'),
              Tab(icon: Icon(Icons.bike_scooter), text: 'Bike'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              color: Colors.amber.shade700,
              child: Text('Home', style: TextStyle(fontSize: 20)),
            ),

            Container(color: Colors.teal.shade700),
            
            Container(
              color: Colors.blue.shade700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: null,
                    child: Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
