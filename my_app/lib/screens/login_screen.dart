import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'llm_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  String errorMessage = '';
  final containerColor = const Color.fromARGB(238, 229, 229, 255);

  // create user
  void _signup() async {
    String username = usernameController.text;
    String password = passwordController.text;

    try {
      bool isAuthenticated = await ApiService.signup(username, password);

      if (isAuthenticated) {
        // If login is successful, navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => llmScreen(username: username),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Invalid signup';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error signing up in: $e';
      });
    }
  }

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
            builder: (context) => llmScreen(username: username),
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
          title: Text(
              'Please log with your verification code, our site is anonymus')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10.0),
            color: containerColor,
            width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 500,
            height: isMobile ? 400 : 300,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Verification code',
                    hintText: 'Enter the 16 characters you got by mail',
                  ),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: _login, child: Text('Login')),
                    SizedBox(width: 10),
                    ElevatedButton(onPressed: _signup, child: Text('Sign Up')),
                  ],
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
