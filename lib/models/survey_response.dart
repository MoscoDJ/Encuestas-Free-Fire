import 'dart:convert';

class SurveyResponse {
  final String id;
  final DateTime createdAt;
  final Map<String, dynamic> answers;

  const SurveyResponse({
    required this.id,
    required this.createdAt,
    required this.answers,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'answers': answers,
      };

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      answers: Map<String, dynamic>.from(json['answers'] as Map),
    );
  }

  String toJsonLine() => jsonEncode(toJson());
}
