import 'dart:convert';
import 'package:http/http.dart' as http;

class GenerateQuiz {
  Future<Map<String, dynamic>> fetchQuestionsFromGemini(
      String topic, int count) async {
    const String apiKey = 'AIzaSyDqufA71RbMkBZHYZxed1rz3rg4G6u2HZY';
    const String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": "Generate $count multiple-choice questions about $topic. "
                  "The response should be in raw JSON format, without any markdown or ```json code block. "
                  "Use this structure: \n"
                  "{\n"
                  '  "quizTitle": "Your Quiz Title",\n'
                  '  "questions": [\n'
                  '    {\n'
                  '      "question": "Question text",\n'
                  '      "options": ["Option 1", "Option 2", "Option 3", "Option 4"],\n'
                  '      "correctOptionIndex": Correct answer index (0-3)\n'
                  '    }\n'
                  '  ]\n'
                  "}"
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String rawText =
            responseData['candidates'][0]['content']['parts'][0]['text'];

        rawText =
            rawText.replaceAll("```json", "").replaceAll("```", "").trim();

        Map<String, dynamic> quizData = jsonDecode(rawText);
        return quizData;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (error) {
      print('Error fetching quiz data: $error');
      return {};
    }
  }
}
