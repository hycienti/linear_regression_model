import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/student_features.dart';

class ApiService {
  static Future<double> predictScore(StudentFeatures features) async {
    final url = Uri.parse('$apiBaseUrl/predict');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(features.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['predicted_math_score'] as num).toDouble();
      } else {
        throw Exception('Server error: ${response.statusCode}\n${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    }
  }
}
