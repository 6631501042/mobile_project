import 'package:flutter/material.dart';
import 'package:mobile_project/user/login.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController username = TextEditingController();
    final TextEditingController password = TextEditingController();
    final TextEditingController confirm_password = TextEditingController();
    final TextEditingController email = TextEditingController();

    return Scaffold(
      backgroundColor: Color(0xFFD8C38A),
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/bird.png', height: 80),
              SizedBox(height: 20),

              // Title
              Text(
                'Room Reservation System',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text('Register my account', style: TextStyle(fontSize: 14)),
              SizedBox(height: 20),

              // Username
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Enter your username'),
              ),
              TextField(
                controller: username,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Email
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Enter your email'),
              ),
              TextField(
                controller: email,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Password
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Enter your password'),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Confirm Password
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Confirm your password'),
              ),
              TextField(
                controller: confirm_password,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Sign up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4E5B4C),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Color(0xFF4E5B4C)),
                    ),
                  ),
                  onPressed: () {},
                  child: Text('Sign Up', style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 10),

              // Create new
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white70,
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    child: Text('Cancel'),
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
