import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'operation_screen.dart';
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
    String code = codeController.text;
    try {
      bool isAuthenticated = await ApiService.signup(username, password, code);

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
            color: containerColor,
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
                  TextField(
                    controller: codeController,
                    decoration: (InputDecoration(
                        labelText: 'Validation code',
                        hintText: 'Enter the validation code')),
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        child: Text('Login'),
                      ),
                      ElevatedButton(
                        onPressed: _signup,
                        child: Text('Sign Up'),
                      ),
                    ],
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
