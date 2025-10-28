import 'package:flutter/material.dart';

// user
//import 'package:mobile_project/user/login.dart'; // Login
//import 'package:mobile_project/user/register.dart'; // Register
//import 'package:mobile_project/user/browse_room_list_user.dart'; //BrowseRoomListUser

// staff
 //import 'package:mobile_project/staff/dashboard_staff.dart'; // DashboardStaff
//import 'package:mobile_project/staff/staff.dart'; // Staff
//import 'package:mobile_project/staff/browse_room_list_staff.dart'; //BrowseRoomListStaff

// approver
//import 'package:mobile_project/approver/dashboard_approver.dart'; // DashboardApprover
import 'package:mobile_project/approver/browse_room_list_approver.dart'; //BrowseRoomListApprover
//import 'package:mobile_project/approver/approver.dart'; // Approver

void main() {
  runApp(const MaterialApp(
    home: BrowseRoomListApprover(), // หรือ BrowseRoomListApprover(), BrowseRoomListUser()
    debugShowCheckedModeBanner: false,
  ));
}