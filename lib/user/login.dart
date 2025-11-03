import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_project/approver/approver.dart';
import 'package:mobile_project/staff/staff.dart';
import 'package:mobile_project/user/user.dart';
import 'package:mobile_project/user/register.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Change to your backend IP
  final url = '192.168.50.51:3000';
  bool isWaiting = false;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  // Alert dialog for messages
  void popDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Login function
  void login() async {
    // if (username.text.isEmpty || password.text.isEmpty) {
    //   popDialog('Please enter username and password');
    //   return;
    // }

    setState(() {
      isWaiting = true;
    });

    try {
      Uri uri = Uri.http(url, '/api/login');
      Map account = {'username': username.text, 'password': password.text};
      http.Response response = await http
          .post(
            uri,
            body: jsonEncode(account),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        String token = response.body;

        // Save token locally
        final storage = await SharedPreferences.getInstance();
        await storage.setString('token', token);
        final user = jsonDecode(response.body);

        if (!mounted) return;

        // Navigate by role
        if (user['role'] == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const User()),
          );
        } else if (user['role'] == 'staff') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Staff()),
          );
        } else if (user['role'] == 'approver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Approver()),
          );
        } else {
          popDialog('Unknown user role');
        }
      } else {
        popDialog(response.body);
      }
    } on TimeoutException {
      popDialog('Connection timeout. Try again.');
    } catch (e) {
      debugPrint(e.toString());
      popDialog('Unexpected error. Please try again.');
    } finally {
      setState(() {
        isWaiting = false;
      });
    }
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8C38A),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/bird.png', height: 80),
              const SizedBox(height: 20),

              const Text(
                'Room Reservation System',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text('Please login to your account'),
              const SizedBox(height: 20),

              // Username field
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Username'),
              ),
              TextField(
                controller: username,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Password field
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Password'),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E5B4C),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFF4E5B4C)),
                    ),
                  ),
                  onPressed: isWaiting ? null : login,
                  child: isWaiting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Create new account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Register()),
                      );
                    },
                    child: const Text(
                      'Create new',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.teal,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
