// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:test_123/repository/home.dart';
import 'package:test_123/models/home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository homeRepository = HomeRepository();
  late Future<HomeModel> futureHome;

  @override
  void initState() {
    super.initState();
    futureHome = homeRepository.fetchHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<HomeModel>(
        future: futureHome,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            // Data berhasil diambil dan ditampilkan
            HomeModel data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan gambar background dari API
                  Stack(
                    children: [
                      Image.network(
                        data.linkBackground,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.5), // Overlay warna
                      ),
                      const Positioned(
                        bottom: 20,
                        left: 20,
                        child: Text(
                          'Welcome to Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Bagian informasi dengan beberapa card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Latest Updates',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Card pertama - Total Informasi
                        Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.event,
                                size: 40, color: Colors.blue),
                            title: const Text('Informasi'),
                            subtitle:
                                Text('Total Informasi: ${data.totalInformasi}'),
                          ),
                        ),

                        // Card kedua - Total Agenda
                        Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.info,
                                size: 40, color: Colors.orange),
                            title: const Text('Agenda'),
                            subtitle: Text('Total Agenda: ${data.totalAgenda}'),
                          ),
                        ),

                        // Card ketiga - Total Album
                        Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.photo_album,
                                size: 40, color: Colors.red),
                            title: const Text('Album'),
                            subtitle: Text(
                                'Total Album: ${data.totalAlbum}, Total Gambar: ${data.totalGambar}'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}
