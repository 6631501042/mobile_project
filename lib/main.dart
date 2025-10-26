import 'package:flutter/material.dart';
// user
// import 'package:mobile_project/user/login.dart'; // Login
// import 'package:mobile_project/user/register.dart'; // Register

// staff
import 'package:mobile_project/staff/dashboard_staff.dart'; // DashboardStaff
// import 'package:mobile_project/staff/dashboard_staff_example.dart'; // DashboardStaff

// approver
// import 'package:mobile_project/approver/dashboard_approver.dart'; // DashboardApprover

// import 'package:mobile_project/gridcard_example.dart';

void main() {
  runApp(MaterialApp(home: DashboardStaff(), debugShowCheckedModeBanner: false));
}