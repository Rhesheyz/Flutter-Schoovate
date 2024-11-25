// lib/repositories/user_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final String apiUrl = 'https://schoovate.apps-project.com/api/getUser';

  Future<List<User>> fetchUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Tambahkan token di header
      },
    );

    if (response.statusCode == 200) {
      // Parse JSON respons
      final jsonResponse = json.decode(response.body);

      // Ambil data dari kunci 'data' dalam JSON respons
      List<dynamic> jsonData = jsonResponse['data'];

      // Map JSON ke List User
      return jsonData.map((user) => User.fromJson(user)).toList();
    } else {
      print(response.statusCode);
      throw Exception('Failed to load users');
    }
  }

  Future<void> addUser(String name, String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('https://schoovate.apps-project.com/api/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      // Biasanya 201 untuk created
      throw Exception('Failed to add post');
    }
  }

  Future<void> deleteUser(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('$apiUrl/delete/$userId'),
      headers: {
        'Authorization': 'Bearer $token', // Tambahkan token di header
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  Future<User> getById(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$apiUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token', // Tambahkan token di header
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // Pastikan mengambil objek 'data' dari JSON sebelum parsing ke model User
      final userData = jsonResponse['data'];
      return User.fromJson(userData);
    } else {
      print(response.statusCode);
      throw Exception('Failed to load user');
    }
  }

  // Method untuk memperbarui data pengguna
  Future<void> updateUser(String id, String name, String email, String role,
      {String? password, String? isRoot}) async {
    final body = {
      'name': name,
      'email': email,
      'role': role,
    };

    // Menambahkan password jika diisi
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    // Menambahkan is_root jika diisi
    if (isRoot != null) {
      body['is_root'] = isRoot;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('$apiUrl/update/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }
}
