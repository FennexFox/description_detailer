import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'json/definitions.dart';
import 'services/detailer_service.dart';
import 'widgets/detailer_preview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  JsonResponse? _jsonResponse;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _jsonResponse = null;
  }

  @override
  void dispose() {
    titleTextController.dispose();
    bodyTextController.dispose();
    super.dispose();
  }

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
    if (titleTextController.text.isEmpty || bodyTextController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = JsonToRequest(
        title: titleTextController.text,
        body: bodyTextController.text,
        requested: true,
      );
      
      final response = await DetailerService.postDetail(request);
      
      setState(() {
        _jsonResponse = response;
        _isLoading = false;
      });

      _showSuccessSnackBar();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar(e is TimeoutException 
        ? 'Server Timeout. Please try again.' 
        : 'Error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully sent request')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          DetailerTextFields(
            titleTextController: titleTextController,
            bodyTextController: bodyTextController,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressPost,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onSecondary
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))
                  ),
                ),
                child: const Text("Submit"),
                ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Divider(),
          ),
          DetailerPreviewGrid(
            jsonResponse: _jsonResponse,
            isLoading: _isLoading,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        useLegacyColorScheme: false,
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
            minLines: 8,
            maxLines: 8,
          ),
        ],
      ),
    );
  }
}