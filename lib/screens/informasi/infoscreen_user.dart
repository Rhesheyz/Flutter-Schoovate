import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import untuk format tanggal
import 'package:test_123/models/informasi.dart';
import 'package:test_123/repository/informasi.dart';

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
                'Tidak ada informasi',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
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
                          // Gambar di atas dengan ukuran tetap
                          SizedBox(
                            height: 150, // Set a fixed height
                            width: double.infinity, // Full width
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Rounded corners for the image
                              child: Image.network(
                                info.gambar, // Assuming your 'Informasi' model has an image URL
                                fit: BoxFit
                                    .cover, // Ensure the image fills the space
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
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
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
                              Text(
                                'Dibuat Pada : $formattedDate', // Use the formatted date
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                              Icon(Icons.access_time,
                                  size: 12, color: Colors.grey[600]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
              SizedBox(
                height: 200, // Fixed height for consistency
                width: double.infinity, // Full width
                child: Image.network(
                  info.gambar, // Image displayed after title
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
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

void main() {
  runApp(const MaterialApp(
    home: InfoScreen(),
  ));
}
