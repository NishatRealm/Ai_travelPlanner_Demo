import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {

  static final String _groqKey = dotenv.env['GROQ_API_KEY'] ?? "";

  static const String _url = "https://api.groq.com/openai/v1/chat/completions";

  static const String _model = "llama-3.1-8b-instant";

  static Future<String> _askGroq(String prompt) async {
    if (_groqKey.isEmpty) {
      return "GROQ_API_KEY missing. Please add it in the .env file.";
    }

    try {
      final body = {
        "model": _model,
        "messages": [
          {
            "role": "system",
            "content":
                "You are a helpful and friendly travel assistant. Answer clearly."
          },
          {
            "role": "user",
            "content": prompt,
          },
        ],
        "temperature": 0.7,
        "max_tokens": 1500,
      };

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_groqKey",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data["choices"]?[0]?["message"]?["content"];
        if (content is String && content.isNotEmpty) {
          return content;
        }
        return "AI response was empty. Please try again.";
      }

      if (response.statusCode == 401) {
        return "Invalid or missing Groq API key. Please check your GROQ_API_KEY.";
      }
      if (response.statusCode == 429) {
        return "Too many requests to Groq right now. Please wait a bit and try again.";
      }
      if (response.statusCode == 400) {
        return "The AI request was invalid. Please try again with simpler input.";
      }

      return "AI error (${response.statusCode}). Please try again later.";
    } catch (e) {
      return "Network error while calling AI: $e";
    }
  }

  /// 🧳 Trip plan generator
  static Future<String> generatePlan(
      String location, int days, int people) async {
    final prompt = """
Create a detailed travel itinerary.

Location: $location
Trip length: $days day(s)
Travelers: $people

Return with clear headings and bullet points:

1. Short trip summary
2. Day-by-day plan (Morning / Afternoon / Evening)
3. Must-visit places (with one-line reasons)
4. Budget estimate (total + breakdown: stay, food, transport, tickets)
5. 3–5 budget-friendly hotel suggestions (with approximate price range)
6. Local foods to try
7. Transport & safety tips
8. Packing checklist
""";

    return _askGroq(prompt);
  }

  /// Chat reply for TravelChatScreen
  static Future<String> chatReply(String message) async {
    final prompt = """
You are a friendly travel chat assistant.
Keep answers short, clear and helpful (3–6 sentences).

User: $message
""";

    return _askGroq(prompt);
  }
}
