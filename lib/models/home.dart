// lib/models/info_model.dart
class HomeModel {
  final int totalInformasi;
  final int totalAgenda;
  final int totalAlbum;
  final int totalGambar;
  final String linkBackground;

  HomeModel({
    required this.totalInformasi,
    required this.totalAgenda,
    required this.totalAlbum,
    required this.totalGambar,
    required this.linkBackground,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      totalInformasi: json['total_informasi'],
      totalAgenda: json['total_agenda'],
      totalAlbum: json['total_album'],
      totalGambar: json['total_gambar'],
      linkBackground: json['link_background'],
    );
  }
}
