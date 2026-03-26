import 'package:flutter_dotenv/flutter_dotenv.dart';

String get apiBaseUrl => dotenv.env['API_URL'] ?? 'http://0.0.0.0:8000';
