import 'package:flutter/material.dart';
import 'package:mobile_project/user/user.dart';
import 'package:mobile_project/user/register.dart';
import 'package:mobile_project/staff/staff.dart';
import 'package:mobile_project/approver/approver.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController username = TextEditingController();
    final TextEditingController password = TextEditingController();

    void handleLogin() {
      final String user = username.text.trim();
      final String pass = password.text.trim();

      if (pass == '1234') {
        if (user == 'staff001') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Staff()),
          );
        } else if (user == '6631501xxx') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const User()),
          );
        } else if (user == 'approver001') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Approver()),
          );
        } else {
          _showError(context, 'Invalid username.');
        }
      } else {
        _showError(context, 'Incorrect password.');
      }
    }

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

              // Title
              const Text(
                'Room Reservation System',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                'Please login to your account',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Username
              const Align(alignment: Alignment.centerLeft, child: Text('Username')),
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

              // Password
              const Align(alignment: Alignment.centerLeft, child: Text('Password')),
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
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFF4E5B4C)),
                    ),
                  ),
                  onPressed: handleLogin,
                  child: const Text('Login', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              // Create new
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white70,
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
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
                        MaterialPageRoute(builder: (context) => const Register()),
                      );
                    },
                    child: const Text('Create new'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
