class Informasi {
  final int id;
  final String judul;
  final String sub_judul;
  final String isi_informasi;
  final String gambar;
  final String status;
  final String users;
  final String created_at;

  Informasi({
    required this.id,
    required this.judul,
    required this.sub_judul,
    required this.isi_informasi,
    required this.gambar,
    required this.status,
    required this.users,
    required this.created_at,
  });

  factory Informasi.fromJson(Map<String, dynamic> json) {
    return Informasi(
        id: json['id'], // Mengubah ID menjadi string
        judul: json['judul'] ?? "No Title", // Nilai default jika null
        sub_judul: json['sub_judul'] ?? "", // Nilai default jika null
        isi_informasi: json['isi_informasi'] ??
            "No Information", // Nilai default jika null
        gambar: json['gambar'] ?? "no_image.png", // Nilai default jika null
        status: json['status'] ?? "Unknown", // Nilai default jika null
        users: json['users']?['name'] ??
            "Unknown User", // Nilai default dan akses aman
        created_at: json['created_at'] ?? "");
  }
}
