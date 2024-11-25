class Album {
  final String judul;
  final int id;
  final String gambar;
  final String status;
  final int idGambar; // ID dari gambar pertama
  final List<Map<String, dynamic>> gambars;

  Album({
    required this.judul,
    required this.gambar,
    required this.status,
    required this.gambars,
    required this.id,
    required this.idGambar,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    List<dynamic> gambarList = json['gambars'] ??
        []; // Mengambil gambars dan berikan nilai default jika null

    return Album(
      id: int.parse(json['id'].toString()),
      judul: json['judul'] ?? '',
      status: json['status'] ?? '',
      gambar: json['gambar'] ?? '',
      idGambar: gambarList.isNotEmpty
          ? int.parse(gambarList[0]['id'].toString())
          : 0, // Berikan ID default jika gambars kosong
      gambars: List<Map<String, dynamic>>.from(
        gambarList.map((gambar) => {
              'id': int.parse(gambar['id'].toString()), // Konversi id ke int
              'url': gambar['gambar'] ?? '', // Nilai default jika null
            }),
      ),
    );
  }
}
