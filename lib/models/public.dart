import 'package:latlong2/latlong.dart';

class PublicModel {
  final String judul;
  final String tanggal;

  PublicModel({required this.judul, required this.tanggal});

  // Factory method untuk parsing dari JSON
  factory PublicModel.fromJson(Map<String, dynamic> json) {
    return PublicModel(
      judul: json['judul'] ?? '',
      tanggal: json['tanggal'] ?? '',
    );
  }
}

class Informasi {
  final String judul;
  final String tanggal;
  final String gambar;

  Informasi({required this.judul, required this.tanggal, required this.gambar});

  factory Informasi.fromJson(Map<String, dynamic> json) {
    return Informasi(
      judul: json['judul'],
      tanggal: json['tanggal'],
      gambar: json['gambar'],
    );
  }
}

class Album {
  final String judul;
  final String tanggal;
  final String gambar;

  Album({required this.judul, required this.tanggal, required this.gambar});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      judul: json['judul'],
      tanggal: json['tanggal'],
      gambar: json['gambar'],
    );
  }
}

class PublicResponse {
  final List<PublicModel> agenda;
  final List<Informasi> informasi;
  final List<Album> album;
  final String linkBackground;
  final LatLng mapCoordinates;

  PublicResponse({
    required this.agenda,
    required this.informasi,
    required this.album,
    required this.linkBackground,
    required this.mapCoordinates,
  });

  factory PublicResponse.fromJson(Map<String, dynamic> json) {
    // Split and parse the 'map' string
    List<String> mapData = (json['map'] ?? '0,0').split(',');
    double latitude = double.parse(mapData[0].trim());
    double longitude = double.parse(mapData[1].trim());

    return PublicResponse(
      agenda: (json['agenda'] as List)
          .map((item) => PublicModel.fromJson(item))
          .toList(),
      informasi: (json['informasi'] as List)
          .map((i) => Informasi.fromJson(i))
          .toList(),
      album: (json['album'] as List)
          .map((a) => Album.fromJson(a))
          .toList(),
      linkBackground: json['link_background'] ?? '',
      mapCoordinates: LatLng(latitude, longitude), // Convert to LatLng
    );
  }
}
