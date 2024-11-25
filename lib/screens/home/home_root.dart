import 'package:flutter/material.dart';

import 'package:test_123/repository/home.dart';
import 'package:test_123/models/home.dart';
import '../user/user.dart'; // Pastikan ini mengimpor UserScreen
import '../user/config.dart'; // Pastikan ini mengimpor ConfigScreen

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
            return Center(child: Text('Error: Coba Login Ulang'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            HomeModel data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        color: Colors.black.withOpacity(0.5),
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

                  // Bagian grid layout untuk Quick Links
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Links',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3 / 2,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildQuickLinkItem(
                              icon: Icons.settings,
                              label: 'Config',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ConfigScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildQuickLinkItem(
                              icon: Icons.person,
                              label: 'Users',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UserScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
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

  // Fungsi untuk membangun item di quick link
  Widget _buildQuickLinkItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 40, color: const Color.fromARGB(255, 121, 121, 121)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}
