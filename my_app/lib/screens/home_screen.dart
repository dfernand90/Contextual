import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController numberController = TextEditingController();
  int accumulatedTotal = 0;

  @override
  void initState() {
    super.initState();
    _fetchTotal();
  }

  // Fetch the total from the backend
  void _fetchTotal() async {
    try {
      int total = await ApiService.getTotal(
          widget.username); // Include username in API request
      setState(() {
        accumulatedTotal = total;
      });
    } catch (e) {
      print("Error fetching total: $e");
    }
  }

  // Add the entered number to the accumulated total
  void _addNumber() async {
    try {
      int newTotal = await ApiService.addNumber(
          widget.username, int.parse(numberController.text)); // Pass username
      setState(() {
        accumulatedTotal = newTotal;
      });
      numberController.clear();
    } catch (e) {
      print("Error adding number: $e");
    }
  }

  // Log out and navigate back to the login screen
  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/', // Redirects to the login screen
      (route) => false, // Removes all previous routes from the stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, ${widget.username}!")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Accumulated Number:", style: TextStyle(fontSize: 18)),
            Text("$accumulatedTotal",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: numberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter a number"),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: _addNumber, child: Text("Add")),
                ElevatedButton(onPressed: _logout, child: Text("Logout")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
