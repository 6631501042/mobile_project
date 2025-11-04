import 'package:flutter/material.dart';
import 'package:mobile_project/user/status.dart'; // หน้า StatusUserPage

void main() {
  runApp(
    MaterialApp(
      home: StatusTab(userId: '24'), // 👈 ให้ตรงกับที่ทดสอบ
      debugShowCheckedModeBanner: false,
    ),
  );
}
