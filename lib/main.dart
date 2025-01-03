import 'dart:io';

import 'package:flutter/material.dart';
import 'json/definitions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detailer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DetailerHome(title: 'Detailer Homepage'),
    );
  }
}

class DetailerHome extends StatefulWidget {
  const DetailerHome({super.key, required this.title});

  final String title;

  @override
  State<DetailerHome> createState() => DetailerHomeState();
}

class DetailerHomeState extends State<DetailerHome> {
  int _selectedIndex = 1;

  final titleTextController = TextEditingController();
  final bodyTextController = TextEditingController();
  late JsonResponse jsonResponse;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String getAdjustedUrl(String inputUrl) { // adjust Localhost for Android Emulator
    try {
      if (Platform.isAndroid) {
        return inputUrl
            .replaceAll('localhost', '10.0.2.2')
            .replaceAll('127.0.0.1', '10.0.2.2');
      }      
      return inputUrl;
    }
    catch (e) { // for other platforms that can't run 'Platform.isAndroid'
      return inputUrl;
    }
  }

  Future<void> onPressPost() async {
    try {
      if (titleTextController.text.isEmpty || bodyTextController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }

      final requestBody = JsonToRequest(
        title: titleTextController.text,
        body: bodyTextController.text,
        requested: true,
      );
      
      final jsonString = jsonEncode(requestBody.toJson());
      debugPrint('Sending JSON: $jsonString'); // Debug print

      final response = await http.post(
        Uri.parse(getAdjustedUrl('http://127.0.0.1:5000/detailer')),
        headers: {
          'Content-Type': 'application/json',  // Simplified header
          'Accept': 'application/json',
        },
        body: jsonString,
      );

      if (response.statusCode == 200) {
        String cleanResponse = response.body.replaceAll(RegExp(r'\\n'), '');
        cleanResponse = cleanResponse.replaceAll("```", "");
        cleanResponse = cleanResponse.replaceAll("json", "");

        debugPrint('Response cleaned: $cleanResponse');

        final Map<String, dynamic> jsonMap = jsonDecode(jsonDecode(cleanResponse));
        debugPrint('Response JSON: $jsonMap');
        final JsonResponse jsonResponse = JsonResponse.fromJson(jsonMap);
        debugPrint('Response: $jsonResponse');

        debugPrint('Response type: ${jsonMap.runtimeType}');
        debugPrint('Response Detailed: ${jsonResponse.detailed}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully sent request')),
        );
        
        // Optional: Update state with response
        // setState(() {
        //   jsonResponse = JsonResponse.fromJson(jsonMap);
        // });
      } else {
        throw Exception('Failed to send request: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      debugPrint('Error in onPressPost: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        spacing: 16.0,
        children: [
          DetailerTextFields(titleTextController: titleTextController, bodyTextController: bodyTextController,),
          ElevatedButton(
            onPressed: onPressPost,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.deepOrange[300]),
              textStyle: WidgetStateProperty.all(
                TextStyle(
                  foreground: Paint()..color = Colors.black,
                  fontWeight: FontWeight.bold,
                )
              ),
            ),
            child: Text("Submit"),
          )
          // DetailerPreviewViewer(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'inspect',
            backgroundColor: Colors.deepOrange,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'write',
            backgroundColor: Colors.deepOrange,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'response',
            backgroundColor: Colors.deepOrange,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange[300],
        onTap: _onItemTapped,
      ),
    );
  }
}

class DetailerTextFields extends StatelessWidget {
  final TextEditingController titleTextController;
  final TextEditingController bodyTextController;

  const DetailerTextFields({super.key, required this.titleTextController, required this.bodyTextController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: [
          TextField(
            controller: titleTextController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Title',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: 'Enter the title of the event',
            ),
            textInputAction: TextInputAction.next,
            autofocus: true,
          ),
          TextField(
            controller: bodyTextController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Body',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Describe the event',
              ),
            textInputAction: TextInputAction.done,
            minLines: 5,
            maxLines: 20,
          ),
        ],
      ),
    );
  }
}
