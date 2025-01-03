import 'dart:convert';

class JsonToRequest {
  String title;
  String body;
  bool requested;

  JsonToRequest({
    required this.title,
    required this.body,
    this.requested = false
  });

  JsonToRequest.fromJson(Map<String, dynamic> json) :
    title = json['title'],
    body = json['body'],
    requested = json['requested'];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'requested': requested,
    };
  }
}

class JsonResponse {
  final Map<String, Answer5W1H> fiveWoneH;
  final String detailed;

  JsonResponse({required this.fiveWoneH, required this.detailed});

  JsonResponse.fromJson(Map<String, dynamic> json) :
    fiveWoneH = (json['5W1H'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, Answer5W1H.fromJson(value as Map<String, dynamic>)),
    ),
    detailed = json['detailed'];

  Map<String, dynamic> toJson() => {
    '5W1H': fiveWoneH.map((key, value) => MapEntry(key, value.toJson())),
    'detailed': detailed,
  };
}

class Answer5W1H {
  final String isProvided;
  final dynamic answer;

  Answer5W1H({required this.isProvided, required this.answer});

  factory Answer5W1H.fromJson(Map<String, dynamic> json) => Answer5W1H(
    isProvided: json['isProvided'],
    answer: json['answer'],
  );

  Map<String, dynamic> toJson() => {
    'ifProvided': isProvided,
    'answer': answer,
  };
}