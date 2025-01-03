import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../json/definitions.dart';
import 'network_service.dart';


class DetailerService {
  static Future<JsonResponse> postDetail(JsonToRequest request) async {
    final jsonString = jsonEncode(request.toJson());
    final response = await http.post(
      Uri.parse(NetworkService.getAdjustedUrl('${NetworkService.baseUrl}/detailer')),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonString,
    ).timeout(
      NetworkService.timeout,
      onTimeout: () => throw TimeoutException('Server Timeout'),
    );

    if (response.statusCode == 200) {
      String cleanResponse = response.body
          .replaceAll(RegExp(r'\\n'), '')
          .replaceAll("```", "")
          .replaceAll("json", "");
      
      final jsonMap = jsonDecode(jsonDecode(cleanResponse));
      return JsonResponse.fromJson(jsonMap);
    }
    throw Exception('Failed to send request: ${response.statusCode}');
  }
}