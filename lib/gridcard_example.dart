import 'package:flutter/material.dart';

class GridCardExample extends StatelessWidget {
  const GridCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grid of Cards"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2, // number of columns
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          
          children: List.generate(6, (index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  // handle tap here
                  print("Card $index tapped");
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, size: 40, color: Colors.blue),
                      const SizedBox(height: 10),
                      Text(
                        'Card ${index + 1}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
