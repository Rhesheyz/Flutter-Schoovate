import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import untuk format tanggal
import 'package:test_123/models/informasi.dart';
import 'package:test_123/repository/informasi.dart';
import 'package:test_123/screens/informasi/infoCreate.dart'; // Import screen untuk menambahkan informasi
import 'package:test_123/screens/informasi/infoEdit.dart'; // Import screen untuk edit informasi

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<Informasi>? infoList = []; // Nullable List
  infoRepository informasi = infoRepository();

  fetchInformasi() async {
    try {
      List<Informasi> data = await informasi.fetchInformasi();
      setState(() {
        infoList = data; // Set the fetched data to the list
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> deleteInformasi(int id) async {
    try {
      await informasi.deleteInformasi(id); // Call delete API
      setState(() {
        infoList!
            .removeWhere((info) => info.id == id); // Remove from local list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informasi berhasil dihapus')),
      );
    } catch (e) {
      print('Error deleting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus informasi')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInformasi(); // Fetch data on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: infoList == null || infoList!.isEmpty
          ? const Center(
              child: Text(
                  'Tidak ada informasi tersedia')) // Show a loading spinner
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: infoList!.length, // Null check and assertion (!)
              itemBuilder: (context, index) {
                final info = infoList![index]; // Null assertion (!)

                // Format tanggal menggunakan intl
                String formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                    .format(DateTime.parse(info.created_at));

                return InkWell(
                  onTap: () {
                    // Navigasi ke DetailScreen saat kartu di-tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(info: info),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gambar di atas
                          // Gambar pada Card
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                            child: AspectRatio(
                              aspectRatio:
                                  16 / 9, // Rasio tetap persegi panjang
                              child: Image.network(
                                info.gambar, // URL gambar
                                fit: BoxFit.cover, // Crop jika melebihi rasio
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          // Judul dan Subtitle
                          Text(
                            info.judul,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 0, 0,
                                  0), // Match the title color from image
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            info.sub_judul,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          // Truncate 'isi_informasi' to one line with an ellipsis
                          Text(
                            info.isi_informasi,
                            maxLines: 1, // Restrict to 1 line
                            overflow:
                                TextOverflow.ellipsis, // Ellipsis if too long
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          // Additional information section (category and time)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Dibuat Pada : $formattedDate', // Use the formatted date
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(Icons.access_time,
                                      size: 12, color: Colors.grey[600]),
                                ],
                              ),
                              // Buttons Edit and Delete
                              Row(
                                children: [
                                  // Tombol Edit
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InfoEditScreen(
                                            infoId: info
                                                .id, // Pass the information ID to the edit screen
                                          ),
                                        ),
                                      );

                                      // Check the result: if true, refresh the information list
                                      if (result == true) {
                                        fetchInformasi();
                                      }
                                    },
                                  ),

                                  // Tombol Delete
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      // Konfirmasi hapus
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Konfirmasi"),
                                            content: const Text(
                                                "Apakah Anda yakin ingin menghapus informasi ini?"),
                                            actions: [
                                              TextButton(
                                                child: const Text("Batal"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("Hapus"),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Tutup dialog
                                                  deleteInformasi(info
                                                      .id); // Hapus informasi berdasarkan ID
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Arahkan pengguna ke layar penambahan informasi
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const InfoCreateScreen(), // Layar untuk menambahkan informasi baru
            ),
          );

          // If the result is true, refresh the page (triggering the refresh function)
          if (result == true) {
            fetchInformasi(); // Call your function to refresh data (e.g., fetch the latest list)
          }
        },
        backgroundColor: const Color.fromARGB(255, 221, 221, 221),
        child: const Icon(Icons.add), // Warna tombol
      ),
    );
  }
}

// Screen to show full information when the card is clicked
class DetailScreen extends StatelessWidget {
  final Informasi info;

  const DetailScreen({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(info.judul),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                info.judul,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Insert Image after title
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FullScreenImage(imageUrl: info.gambar),
                    ),
                  );
                },
                child: AspectRatio(
                  aspectRatio: 16 / 9, // Tentukan rasio untuk gambar
                  child: Image.network(
                    info.gambar,
                    fit: BoxFit.cover, // Potong jika gambar melebihi area
                  ),
                ),
              ),

              // Subtitle
              Text(
                info.sub_judul,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Full content without restriction
              Text(
                info.isi_informasi, // Show full 'isi_informasi' here without line limit
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              // Display "Dibuat oleh" with info.users
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Dibuat oleh: ${info.users}', // Show the 'users' name
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Latar belakang hitam
      body: Stack(
        children: [
          InteractiveViewer(
            panEnabled: true, // Aktifkan geser
            minScale: 1.0, // Skala minimum
            maxScale: 4.0, // Skala maksimum
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain, // Pastikan gambar pas dalam layar
              ),
            ),
          ),
          Positioned(
            top: 40, // Posisi tombol tutup
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context); // Kembali ke layar sebelumnya
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: InfoScreen(),
  ));
}
