import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Description Detailer';
  static const String appVersion = '0.5.0';
  static const String createdBy = 'AnotherFireFox';
  static const String poweredBy = 'Flutter & FastAPI';

  // Navigation
  static const int defaultPageIndex = 1;
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);

  // Theme
  static const Color seedColor = Colors.deepOrange;

  // Labels
  static const String inspectLabel = 'inspect';
  static const String writeLabel = 'write';
  static const String responseLabel = 'detailed';
  static const String aboutLabel = 'About';

  // Messages
  static const String noDataMessage = 'No data available.\nPlease submit a request first.';
  static const String emptyFieldsMessage = 'Please fill in all fields.';
  static const String timeoutMessage = 'Server Timeout. Please try again.';
  static const String successMessage = 'Successfully sent request';
}
