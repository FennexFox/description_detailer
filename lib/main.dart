import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'json/definitions.dart';
import 'services/detailer_service.dart';
import 'widgets/detailer_preview.dart';
import 'widgets/inspector_page.dart';
import 'widgets/response_page.dart';
import 'widgets/credit_page.dart';
import 'constants/app_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DetailerHome(title: AppConstants.appName),
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
  late final PageController _pageController;
  final titleTextController = TextEditingController();
  final bodyTextController = TextEditingController();

  JsonResponse? _jsonResponse;
  int _selectedIndex = AppConstants.defaultPageIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _jsonResponse = null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    titleTextController.dispose();
    bodyTextController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: AppConstants.pageTransitionDuration,
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
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
      _showErrorSnackBar(AppConstants.emptyFieldsMessage);
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
        ? AppConstants.timeoutMessage 
        : 'Error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppConstants.successMessage),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreditPage()),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          InspectorPage(jsonResponse: _jsonResponse),
          SingleChildScrollView(
            child: Column(
              children: [
                DetailerTextFields(
                  titleTextController: titleTextController,
                  bodyTextController: bodyTextController,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      child: const Text("Send Draft"),
                      ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DetailerPreviewGrid(
                    jsonResponse: _jsonResponse,
                    isLoading: _isLoading,
                    ),
                ),
              ],
            ),
          ),
          ResponsePage(jsonResponse: _jsonResponse),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        useLegacyColorScheme: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: AppConstants.inspectLabel,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: AppConstants.writeLabel,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: AppConstants.responseLabel,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ],
        currentIndex: _selectedIndex,
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