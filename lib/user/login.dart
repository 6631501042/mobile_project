import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController username = TextEditingController();
    final TextEditingController password = TextEditingController();
    
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
              Text(
                'Please login to your account',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),

              // Username
              Align(alignment: Alignment.centerLeft, child: Text('Username')),
              TextField(
                controller: username,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Password
              Align(alignment: Alignment.centerLeft, child: Text('Password')),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Login Button
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
                  child: Text('Login', style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),

              // Create new
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white70,
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () {},
                    child: Text('Create new'),
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
