// lib/repositories/info_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeRepository {
  final String baseUrl = 'https://schoovate.apps-project.com/api/home/admin';

  Future<HomeModel> fetchHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token', // Tambahkan bearer token ke header
        'Header': 'application/json', // Tambahkan bearer token ke header
      },
    );

    if (response.statusCode == 200) {
      return HomeModel.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to load information');
    }
  }
}
