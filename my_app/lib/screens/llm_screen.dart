import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class llmScreen extends StatefulWidget {
  final String username;
  const llmScreen({Key? key, required this.username}) : super(key: key);

  @override
  _llmScreenState createState() => _llmScreenState();
}

class _llmScreenState extends State<llmScreen> {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController queryController = TextEditingController();
  int accumulatedTotal = 0;
  String currentResponse = "welcome";
  double sliderValue = 0.5;
  String selectedEntry = "deepseek-r1:1.5b";
  final List<String> dropdownEntries = [
    "llama3.2:1b",
    "deepseek-r1:1.5b",
    "qwen2.5-coder:3b ",
    "deepseek-r1:latest",
    "llama3:8b"
  ];
  File? selectedFile;
  List<String> files = [];
  final containerColor = const Color.fromARGB(238, 229, 229, 255);
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

  void _queryLlm() async {
    try {
      String response = await ApiService.queryLlm(
          widget.username,
          queryController.text, // No need for String.parse
          sliderValue, // Convert sliderValue properly
          selectedEntry // Directly pass selectedEntry (already a String)
          );
      setState(() {
        currentResponse = response;
      });
      queryController.clear();
    } catch (e) {
      print("Error proccesing the query: $e");
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
      appBar: AppBar(title: Text("DEBUG MODE")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile =
              constraints.maxWidth < 800; // Adjust threshold for mobile

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isMobile
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildContent(context, constraints, isMobile),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildContent(context, constraints, isMobile),
                  ),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(
      BuildContext context, BoxConstraints constraints, bool isMobile) {
    double screenWidth = constraints.maxWidth;

    return [
      // Left Column (Files)
      SizedBox(
        width: isMobile ? screenWidth : screenWidth / 4,
        child: Column(
          children: [
            Text("Your context folder ${widget.username}:"),
            FutureBuilder<List<String>>(
              future: ApiService.fetchFiles(widget.username),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No files found.");
                }

                return Container(
                  height: isMobile ? 400 : 628,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: containerColor,
                  ),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index]),
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
      SizedBox(width: isMobile ? 0 : 10),

      // Middle Column (Main Content)
      SizedBox(
        width: isMobile ? screenWidth : (screenWidth * 4) / 6,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.all(12),
                height: 80,
                width: isMobile ? screenWidth * 0.7 : 200,
                child: DropdownButton<String>(
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
              ),
            ),
            Container(
              height: 413,
              alignment: Alignment.topLeft,
              child: TextField(
                controller: TextEditingController(text: " $currentResponse"),
                readOnly: true,
                style: TextStyle(
                    fontSize: 20, color: Color.fromARGB(202, 61, 61, 61)),
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                    border: InputBorder.none, contentPadding: EdgeInsets.zero),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: containerColor,
              ),
              child: TextField(
                minLines: 4,
                maxLines: 10,
                controller: queryController,
                decoration: InputDecoration(
                  labelText: "How can I help you?",
                  alignLabelWithHint: true,
                  contentPadding: EdgeInsets.only(top: 2),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _queryLlm, child: Text("Send")),
                SizedBox(width: 10),
                ElevatedButton(onPressed: _logout, child: Text("Logout")),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10),
              height: 50,
              width: isMobile ? screenWidth * 0.8 : 600,
              alignment: Alignment.center,
              child: Row(
                children: [
                  Text("Precise"),
                  Expanded(
                    child: Slider(
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
                  ),
                  Text("Creative"),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
