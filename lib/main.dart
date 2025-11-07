// lib/main.dart
import 'package:flutter/material.dart';
import 'package:mobile_project/user/test.dart';  // ✅ import หน้าที่เราแก้ไว้

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Status(), // ✅ หน้า Status() มาจากไฟล์ test.dart
    );
  }
}
