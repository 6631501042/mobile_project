import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_project/user/login.dart';
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final url = '192.168.50.51:3000';
  // final url = '172.27.10.98:3000';
  bool isWaiting = false;

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  void popDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Message'),
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

  // Register account
  Future<void> addAccount() async {
    if (username.text.isEmpty ||
        password.text.isEmpty ||
        confirmPassword.text.isEmpty) {
      popDialog('Please fill in all fields');
      return;
    }
    if (password.text != confirmPassword.text) {
      popDialog('Passwords do not match');
      return;
    }

    setState(() {
      isWaiting = true;
    });

    try {
      Uri uri = Uri.http(url, '/api/student/register');
      Map<String, dynamic> body = {
        'username': username.text.trim(),
        'password': password.text.trim(),
      };

      http.Response response = await http
          .post(
            uri,
            body: jsonEncode(body),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (!mounted) return;
        popDialog('Account created successfully!');
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        popDialog(response.body);
      }
    } on TimeoutException {
      popDialog('Connection timeout. Please try again.');
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
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D5A9),
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
              const Text('Register my account'),
              const SizedBox(height: 20),

              // Username
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Enter your username'),
              ),
              TextField(
                controller: username,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
              ),
              const SizedBox(height: 10),

              // Password
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Enter your password'),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
              ),
              const SizedBox(height: 10),

              // Confirm Password
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Confirm your password'),
              ),
              TextField(
                controller: confirmPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
              ),
              const SizedBox(height: 30),

              // Sign Up Button
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
                  onPressed: isWaiting ? null : addAccount,
                  child: isWaiting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // Cancel Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white70,
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Login()),
                      );
                    },
                    child: const Text('Cancel'),
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
