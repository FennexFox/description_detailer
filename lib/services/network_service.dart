import 'dart:io';

class NetworkService {
  static const baseUrl = 'https://e569-112-187-131-140.ngrok-free.app';
  static const timeout = Duration(seconds: 30);

  static String getAdjustedUrl(String inputUrl) {
    try {
      if (Platform.isAndroid) {
        return inputUrl
            .replaceAll('localhost', '10.0.2.2')
            .replaceAll('127.0.0.1', '10.0.2.2');
      }
      return inputUrl;
    } catch (e) {
      return inputUrl;
    }
  }
}