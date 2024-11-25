import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test_123/models/informasi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class infoRepository {
  Future<List<Informasi>> fetchInformasi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('https://schoovate.apps-project.com/api/informasi'),
      headers: {
        'Authorization': 'Bearer $token', // Tambahkan bearer token ke header
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['data'] is List) {
        return (jsonResponse['data'] as List)
            .map((json) => Informasi.fromJson(json))
            .toList();
      } else {
        throw Exception('Unexpected data format: expected a List inside data');
      }
    } else {
      throw Exception('Failed to load information');
    }
  }

  Future<http.Response> createInformasi({
    required String judul,
    required String subJudul,
    required String isiInformasi,
    required File gambar,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var uri =
        Uri.parse('https://schoovate.apps-project.com/api/informasi/create');
    var request = http.MultipartRequest('POST', uri);

    // Tambahkan token ke header
    request.headers['Authorization'] = 'Bearer $token';

    // Tambahkan field text ke request
    request.fields['judul'] = judul;
    request.fields['sub_judul'] = subJudul;
    request.fields['isi_informasi'] = isiInformasi;

    // Tambahkan file gambar
    var multipartFile =
        await http.MultipartFile.fromPath('gambar', gambar.path);
    request.files.add(multipartFile);

    // Kirim request dan tunggu respon
    var response = await request.send();

    if (response.statusCode == 201) {
      return http.Response.fromStream(response);
    } else {
      throw Exception('Failed to upload information');
    }
  }

  Future<Informasi> getInformasiById(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('https://schoovate.apps-project.com/api/informasi/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Informasi.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load information');
    }
  }

  Future<void> deleteInformasi(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('https://schoovate.apps-project.com/api/informasi/delete/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete information');
    }
  }

  Future<void> editInformasi(
    int id,
    String judul,
    String subJudul,
    String isiInformasi,
    File? gambar, // File gambar (bisa nullable)
    String status, // Tambahkan parameter status
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://schoovate.apps-project.com/api/informasi/update/$id'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    // Tambahkan field teks
    request.fields['judul'] = judul;
    request.fields['sub_judul'] = subJudul;
    request.fields['isi_informasi'] = isiInformasi;
    request.fields['status'] = status; // Tambahkan field status

    // Jika ada gambar, tambahkan sebagai multipart
    if (gambar != null) {
      request.files.add(
        await http.MultipartFile.fromPath('gambar', gambar.path),
      );
    }

    var response = await request.send();

    if (response.statusCode != 200) {
      print(response.statusCode);
      throw Exception('Failed to update information');
    }
  }
}
