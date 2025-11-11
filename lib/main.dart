// lib/main.dart
import 'package:flutter/material.dart';
import 'package:mobile_project/approver/approver_status.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ApproverStatusPage(
        approverId: '29', // ✅ ใส่เป็น id ของ approver จริง
      ),
    );
  }
}
