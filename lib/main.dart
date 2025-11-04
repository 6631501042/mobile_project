import 'package:flutter/material.dart';


// user
//import 'package:mobile_project/user/login.dart'; // Login
//import 'package:mobile_project/user/register.dart'; // Register
import 'package:mobile_project/user/user.dart';


// staff
 //import 'package:mobile_project/staff/dashboard_staff.dart'; // DashboardStaff
// import 'package:mobile_project/staff/staff.dart'; //staff

// approver
//import 'package:mobile_project/approver/dashboard_approver.dart'; // DashboardApprover
//import 'package:mobile_project/approver/approver.dart'; // Approver

void main() {
  runApp(const MaterialApp(
    home: User(), // หรือ BrowseRoomListApprover(), BrowseRoomListUser()
    debugShowCheckedModeBanner: false,
  ));
}