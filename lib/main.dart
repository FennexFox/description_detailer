import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'json/definitions.dart';
import 'services/detailer_service.dart';

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
      setState(() => _isLoading = true);
      
      if (titleTextController.text.isEmpty || bodyTextController.text.isEmpty) {
        throw Exception('Please fill in all fields');
      }

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully sent request')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is TimeoutException 
            ? 'Server Timeout. Please try again.' 
            : 'Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget responsePreview(String answerKey) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.all(12.0),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: _isLoading 
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : _jsonResponse == null 
                    ? const Icon(Icons.circle, size: 12, color: Colors.grey)
                    : Icon(
                        Icons.circle,
                        size: 12,
                        color: _getStatusColor(_jsonResponse!.fiveWoneH[answerKey]?.isProvided),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  answerKey,
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch(status) {
      case "true": return Colors.green;
      case "implied": return Colors.yellow;
      default: return Colors.red;
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
        spacing: 4.0,
        children: [
          DetailerTextFields(titleTextController: titleTextController, bodyTextController: bodyTextController,),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                onPressed: onPressPost,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.onSurface
                  ),
                  shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))
                  ),
                  textStyle: WidgetStateProperty.all(
                  TextStyle(
                    foreground: Paint()..color = Colors.black,
                    fontWeight: FontWeight.bold,
                  )
                  ),
                ),
                child: Text("Submit"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: const Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: responsePreview("Who")),
                Expanded(child: responsePreview("When")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: responsePreview("Where")),
                Expanded(child: responsePreview("What")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: responsePreview("Why")),
                Expanded(child: responsePreview("How")),
              ],
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

class DetailerPreviewViewer extends StatelessWidget {
  final Answer5W1H? fiveWoneH;
  final String answrKey;

  const DetailerPreviewViewer({super.key, required this.fiveWoneH, required this.answrKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.0,
      children: [
        Text(answrKey),
        const Divider(),
        Text('answer: ${fiveWoneH?.answer}'),
        Text('isProvided: ${fiveWoneH?.isProvided}'),
      ],
    );
  }
}