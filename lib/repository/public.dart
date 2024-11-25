// repositories/public_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_123/models/public.dart';

class PublicRepository {
  final String apiUrl = 'https://schoovate.apps-project.com/api/home/user';
  Future<PublicResponse> fetchPublicData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PublicResponse.fromJson(data['data']);
    } else {
      throw Exception('Failed to load public data');
    }
  }
}
