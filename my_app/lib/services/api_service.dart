import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb

class ApiService {
  static const String baseUrl =
      "https://1db7-85-252-83-74.ngrok-free.app"; //"http://127.0.0.1:8000"; // Your Django backend URL

  // Signup the user with username and password
  static Future<bool> signup(
      String username, String password, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/signup/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'password': password,
        'code': code,
      }),
    );

    return response.statusCode == 200;
  }

  // Login the user with username and password
  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    return response.statusCode == 200;
  }

  // Fetch total for the user
  static Future<int> getTotal(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/total/$username/'),
      headers: {"Content-Type": "application/json"},
      //body: jsonEncode({'user': username}),
    );
    //print(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['total'];
    } else {
      throw Exception('Failed to fetch total');
    }
  }

  // Add number for the user
  static Future<int> addNumber(String username, int number) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/add/$username/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'number': number}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['new_total'];
    } else {
      throw Exception('Failed to add number');
    }
  }

  // Upload file (Mobile/Desktop)
  static Future<bool> uploadFile(String username, File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload/'),
      );

      request.fields['username'] = username; // Send username along with file

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Must match Django backend field name
          file.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 201) {
        print('File uploaded successfully');
        return true;
      } else {
        print('File upload failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return false;
    }
  }

  // Upload file (Web)
  static Future<bool> uploadFileBytes(
      String username, Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload/'),
      );

      request.fields['username'] = username;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 201) {
        print('File uploaded successfully');
        return true;
      } else {
        print('File upload failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return false;
    }
  }

  // Fetch list of files for a user
  static Future<List<String>> fetchFiles(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/files/$username/'),
      headers: {"Content-Type": "application/json"},
    );
    // print(response.body);
    print('Response Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['files']);
    } else {
      throw Exception('Failed to load files');
    }
  }
}
