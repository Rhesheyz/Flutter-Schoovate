import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_123/models/album.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class AlbumRepository {
  final String baseUrl = 'https://schoovate.apps-project.com/api/albums';

  // Metode untuk mengambil album
  Future<List<Album>> fetchAlbums() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token =
        prefs.getString('token'); // Ambil token dari SharedPreferences

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token', // Tambahkan token di header
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData != null && jsonData['data'] is List) {
        final List albums = jsonData['data'];
        return albums.map((albumJson) => Album.fromJson(albumJson)).toList();
      } else {
        throw Exception('Unexpected JSON format: expected a List inside data');
      }
    } else {
      throw Exception('Failed to load albums');
    }
  }

  Future<void> createAlbum(
      {required String judul, required File imageFile}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token =
        prefs.getString('token'); // Ambil token dari SharedPreferences
    final uri =
        Uri.parse("https://schoovate.apps-project.com/api/album/create");

    var request = http.MultipartRequest('POST', uri)
      ..fields['judul'] = judul
      ..files.add(await http.MultipartFile.fromPath('gambar', imageFile.path));
    request.headers['Authorization'] = 'Bearer $token';

    final response = await request.send();
    if (response.statusCode != 201) {
      print(response.statusCode);
      throw Exception("Gagal menambahkan album");
    }
  }

  Future<void> deleteAlbum(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final url =
        Uri.parse('https://schoovate.apps-project.com/api/album/delete/$id');
    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      print("Album deleted successfully");
    } else {
      print(response.statusCode);
      throw Exception('Failed to delete album');
    }
  }

  Future<Album?> getAlbumById(int id) async {
    final url = Uri.parse('https://schoovate.apps-project.com/api/albums/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return Album.fromJson(data);
      } else {
        print("Failed to load album with id $id: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching album by id: $e");
      return null;
    }
  }

  // Fungsi untuk mengedit album
  Future<bool> editAlbum(
      int id, String judul, String status, File? gambar) async {
    var uri =
        Uri.parse('https://schoovate.apps-project.com/api/album/edit/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest('POST', uri);
    request.fields['judul'] = judul;
    request.fields['status'] = status;
    request.headers['Authorization'] = 'Bearer $token';

    // Tambahkan file gambar jika tersedia
    if (gambar != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'gambar',
          gambar.path,
          contentType: MediaType('image', 'jpeg'), // Sesuaikan tipe file
        ),
      );
    }

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print("Album updated successfully");
        return true;
      } else {
        String responseBody = await response.stream.bytesToString();
        print("Failed to update album: $responseBody");
        return false;
      }
    } catch (e) {
      print("Error editing album: $e");
      return false;
    }
  }

  Future<void> uploadGambar(int albumId, List<XFile> imageFiles) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri =
        Uri.parse('https://schoovate.apps-project.com/api/gambar/$albumId');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Tambahkan setiap gambar yang dipilih ke dalam permintaan upload
    for (var imageFile in imageFiles) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'gambar[]', // Sesuaikan dengan API
          imageFile.path,
          contentType: MediaType('image', 'jpeg'), // Sesuaikan dengan format
        ),
      );
    }

    // Kirim permintaan
    var response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Gagal mengunggah gambar');
    }
  }

  Future<void> deleteGambar(int idGambar) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final url = Uri.parse(
        'https://schoovate.apps-project.com/api/gambar/delete/$idGambar');

    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus gambar');
    }
  }
}
