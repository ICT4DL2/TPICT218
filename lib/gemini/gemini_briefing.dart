// lib/gemini/gemini_briefing.dart
class GeminiBriefing {
  final String advice;
  final String summary;

  GeminiBriefing({required this.advice, required this.summary});

  factory GeminiBriefing.fromJson(Map<String, dynamic> json) {
    return GeminiBriefing(
      advice: json['advice'] ?? '',
      summary: json['summary'] ?? '',
    );
  }
}