import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import the login screen
import 'screens/home_screen.dart'; // Import the home screen
import 'screens/operation_screen.dart'; // Import the home screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contextual',
      debugShowCheckedModeBanner: true, // Removes the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue, // Sets the theme color
      ),
      initialRoute: '/', // Start with the login screen
      routes: {
        '/': (context) => LoginScreen(), // Route for login
        '/home': (context) => HomeScreen(username: 'default'),
        '/operation': (context) => OperationScreen(username: 'default'),
      },
    );
  }
}
