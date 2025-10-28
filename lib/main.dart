import 'package:flutter/material.dart';
import 'user/status.dart'; // หรือ package import ให้ตรงชื่อโปรเจ็กต์

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Room Reservation',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.hampton,
        primaryColor: AppColors.finlandia,
      ),
      // ใช้คลาสที่มีอยู่จริงใน status.dart
      home: const ApproverStatusPage(
        approverName: 'Ajarn.Tick',
        approverId: 'teacher-001',
      ),
    );
  }
}
