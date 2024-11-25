// config_repository.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigRepository {
  final String apiUrl = "https://schoovate.apps-project.com/api/mobile";

  Future<ConfigModel?> getByID() async {
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
      final data = json.decode(response.body)['Data'];
      return ConfigModel.fromJson(data);
    } else {
      // Handle the error
      throw Exception('Failed to load data');
    }
  }

  Future<void> update(ConfigModel config, File? backgroundImage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/edit'), // No ID appended
    );

    request.fields['map'] = config.mapLink;
    request.headers['Authorization'] = 'Bearer $token';

    if (backgroundImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'background',
        backgroundImage.path,
      ));
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      // Handle error
      throw Exception('Failed to save changes');
    }
  }
}
