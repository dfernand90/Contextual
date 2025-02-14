import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class OperationScreen extends StatefulWidget {
  final String username;
  const OperationScreen({Key? key, required this.username}) : super(key: key);

  @override
  _OperationScreenState createState() => _OperationScreenState();
}

class _OperationScreenState extends State<OperationScreen> {
  final TextEditingController numberController = TextEditingController();
  int accumulatedTotal = 0;
  double sliderValue = 0.5;
  String selectedEntry = "entry1";
  final List<String> dropdownEntries = [
    "entry1",
    "entry2",
    "entry3",
    "entry4",
    "entry5"
  ];
  File? selectedFile;
  List<String> files = [];

  @override
  void initState() {
    super.initState();
    _fetchTotal();
  }

  void _fetchTotal() async {
    try {
      int total = await ApiService.getTotal(widget.username);
      setState(() {
        accumulatedTotal = total;
      });
    } catch (e) {
      print("Error fetching total: $e");
    }
  }

  void _addNumber() async {
    try {
      int newTotal = await ApiService.addNumber(
          widget.username, int.parse(numberController.text));
      setState(() {
        accumulatedTotal = newTotal;
      });
      numberController.clear();
    } catch (e) {
      print("Error adding number: $e");
    }
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      // User canceled the file picker
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No file selected")));
      return;
    }

    bool success;
    if (kIsWeb) {
      // Web: Get bytes and file name
      Uint8List fileBytes = result.files.first.bytes!;
      String fileName = result.files.first.name;
      success = await ApiService.uploadFileBytes(
          widget.username, fileBytes, fileName);
    } else {
      // Mobile/Desktop: Get file path
      File selectedFile = File(result.files.first.path!);
      success = await ApiService.uploadFile(widget.username, selectedFile);
    }

    // Show upload result
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("File uploaded successfully")));
      // Refresh the file list after successful upload
      _refreshFileList();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("File upload failed")));
    }
  }

  // Method to refresh the file list
  Future<void> _refreshFileList() async {
    List<String> updatedFiles = await ApiService.fetchFiles(widget.username);
    setState(() {
      files = updatedFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, ${widget.username}!")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (1/6 width)
            SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: Column(
                children: [
                  Text("Your context folder ${widget.username}:"),
                  FutureBuilder<List<String>>(
                    future: ApiService.fetchFiles(widget.username),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Loading indicator
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text("No files found.");
                      }

                      // Display file list
                      return Container(
                        height: 628,
                        decoration: BoxDecoration(
                          //border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(255, 234, 237, 253),
                        ),
                        child: ListView.builder(
                          itemCount: files.isNotEmpty
                              ? files.length
                              : snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(files.isNotEmpty
                                  ? files[index]
                                  : snapshot.data![index]),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickAndUploadFile,
                    child: Text("Upload PDF"),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            // Middle Column (4/6 width)
            SizedBox(
              width: (MediaQuery.of(context).size.width * 4) / 6,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          //border: Border.all(color: Colors.grey),
                          //borderRadius: BorderRadius.circular(8),
                          ),
                      height: 80,
                      width: 200,
                      child: Column(
                        children: [
                          DropdownButton<String>(
                            value: selectedEntry,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedEntry = newValue!;
                              });
                            },
                            items: dropdownEntries
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 413,
                    alignment: Alignment.topLeft,
                    child: TextField(
                      controller: TextEditingController(
                          text: "Accumulated Number: $accumulatedTotal"),
                      readOnly: true, // Make the TextField non-editable
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .black, // You can adjust the color to match your theme
                      ),

                      decoration: InputDecoration(
                        border: InputBorder
                            .none, // Removes the border for a cleaner look
                        contentPadding: EdgeInsets
                            .zero, // Adjusts padding inside the text field
                        isDense:
                            true, // Helps reduce space between the text and the edges of the container
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    height: 150,
                    //color: const Color.fromARGB(255, 234, 237, 253),
                    decoration: BoxDecoration(
                      //border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 234, 237, 253),
                    ),
                    child: TextField(
                      minLines: 4,
                      maxLines: 10,
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Enter a number",
                        alignLabelWithHint:
                            true, // Aligns the label to the top of the box
                        contentPadding: EdgeInsets.only(top: 2),
                        border: InputBorder.none, // No border for cleaner look
                      ),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: _addNumber, child: Text("Add")),
                      SizedBox(width: 10),
                      ElevatedButton(onPressed: _logout, child: Text("Logout")),
                    ],
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment(-0.35, 0),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: 50,
                      width: 600,
                      alignment: Alignment.center,
                      //color: const Color.fromARGB(255, 234, 237, 253),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 5,
                            width: 200,
                          ),
                          Text("Creative"),
                          Slider(
                            value: sliderValue,
                            onChanged: (newValue) {
                              setState(() {
                                sliderValue = newValue;
                              });
                            },
                            min: 0,
                            max: 1,
                            divisions: 24,
                            label: sliderValue.toStringAsFixed(1),
                          ),
                          Text("Precise"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
