import 'dart:convert';
import 'package:http/http.dart' as http;

// Function to fetch chatbot response
Future<String> fetchResponse(String query) async {
  final url = Uri.parse('https://healthbot.pythonanywhere.com/api/chat/');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'hid': '00001',
      'query': query,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['response']; // Assuming API returns a JSON with 'response' key
  } else {
    throw Exception('Failed to fetch response: ${response.statusCode}');
  }
}

// Function to fetch hospitals based on location
Future<List<dynamic>> fetchHospitals(String location) async {
  final url =
      Uri.parse('https://healthbot.pythonanywhere.com/api/get-hospitals/');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'hid': '00001',
      'location': "Sanpada, Navi Mumbai.",
    }),
  );
  print("RESPONSE: ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("DATA $data");
    return data['hospitals']; // Assuming API returns a JSON list of hospitals
  } else {
    throw Exception('Failed to fetch hospitals: ${response.statusCode}');
  }
}
