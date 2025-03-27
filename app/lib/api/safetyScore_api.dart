import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> sendSafetyScoreRequest(String city) async {
  final Uri url = Uri.parse('https://ed8e-123-252-147-173.ngrok-free.app/safetyScore');
  print(url);
  // print('ssssssssssssent');
  // print('in');
  final Map<String, String> headers = {'Content-Type': 'application/json'};

  final Map<String, dynamic> body = {'city': city};

  try {
    print('trying');
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );
    print('midway');
    if (response.statusCode == 200) {
      print('Request successful: ${response.body}');
      // Parse the response body
      var data = json.decode(response.body);
      // Extract the safety_score
      var safetyScore = data['safety_score'];
      return safetyScore.toString();
    } else {
      print('Request failed with status: ${response.statusCode}');
      return 'Error';
    }
  } catch (e) {
    print('nah didnt work');
    print('Error: $e');
    return 'Error';
  }
}
