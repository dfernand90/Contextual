import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'operation_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  // Handle login
  void _login() async {
    String username = usernameController.text;
    String password = passwordController.text;

    try {
      bool isAuthenticated = await ApiService.login(username, password);

      if (isAuthenticated) {
        // If login is successful, navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OperationScreen(username: username),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Invalid credentials';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error logging in: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Transform.translate(
          offset: Offset(0, -150),
          child: Container(
            margin: const EdgeInsets.all(10.0),
            color: const Color.fromARGB(255, 234, 237, 253),
            height: 300,
            width: 500,
            alignment: Alignment(100, 1.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: (InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter the 16 characters you got by mail')),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                  SizedBox(height: 25),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
