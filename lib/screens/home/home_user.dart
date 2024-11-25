// pages/home_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_123/repository/public.dart';
import 'package:test_123/models/public.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<PublicResponse> _publicData;
  late PageController _pageController;
  int _currentIndex = 0;
  late PageController _galleryPageController;
  int _galleryCurrentIndex = 0;

  @override
  void initState() {
    super.initState();
    _publicData = PublicRepository().fetchPublicData();
    _pageController = PageController();
    _galleryPageController = PageController(); // Controller untuk galeri
  }

  @override
  void dispose() {
    _pageController.dispose();
    _galleryPageController.dispose(); // Dispose galeri controller
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PublicResponse>(
        future: _publicData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final publicData = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Background Image with Welcome Text
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(publicData.linkBackground),
                          fit: BoxFit.cover,
                        ),
                      ),
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
                        'Welcome to Schoovate',
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

                // Section: Agenda
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Agenda Terbaru',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (publicData.agenda.isEmpty)
                        const Text('Agenda tidak tersedia'),
                      ...publicData.agenda.map((agenda) => AgendaCard(
                            tanggal: agenda.tanggal,
                            judul: agenda.judul,
                            createdAt: 'Dibuat pada: ${agenda.tanggal}',
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section: Informasi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Terbaru',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (publicData.informasi.isEmpty)
                        const Text('Informasi tidak tersedia'),
                      if (publicData.informasi.isNotEmpty)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: publicData.informasi.length,
                                onPageChanged: _onPageChanged,
                                itemBuilder: (context, index) {
                                  final info = publicData.informasi[index];
                                  return _buildBackgroundCard(
                                    imageUrl: info.gambar,
                                    label: info.judul,
                                    onTap: () {},
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              left: 16,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  if (_currentIndex > 0) {
                                    _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                              ),
                            ),
                            Positioned(
                              right: 16,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () {
                                  if (_currentIndex <
                                      publicData.informasi.length - 1) {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section: Galeri
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Galeri Terbaru',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (publicData.album.isEmpty)
                        const Text('Galeri tidak tersedia'),
                      if (publicData.album.isNotEmpty)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              child: PageView.builder(
                                controller: _galleryPageController,
                                itemCount: publicData.album.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _galleryCurrentIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final album = publicData.album[index];
                                  return _buildBackgroundCard(
                                    imageUrl: album.gambar,
                                    label: album.judul,
                                    onTap: () {
                                      // Implementasi aksi lainnya di sini
                                    },
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              left: 16,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  if (_galleryCurrentIndex > 0) {
                                    _galleryPageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                              ),
                            ),
                            Positioned(
                              right: 16,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () {
                                  if (_galleryCurrentIndex <
                                      publicData.album.length - 1) {
                                    _galleryPageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Section: Maps
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lokasi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: FlutterMap(
                          options: MapOptions(
                            center: publicData.mapCoordinates,
                            zoom: 15.0,
                            maxZoom: 18.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                              userAgentPackageName: 'com.example.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point: publicData.mapCoordinates,
                                  builder: (ctx) => const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundCard({
    required String imageUrl,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          children: [
            // Gambar sebagai latar belakang
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Overlay untuk membuat teks lebih terbaca
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            // Teks di atas gambar
            Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AgendaCard extends StatelessWidget {
  final String tanggal;
  final String judul;
  final String createdAt;

  const AgendaCard({
    super.key,
    required this.tanggal,
    required this.judul,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Bagian tanggal dan bulan di kiri
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 151, 151, 151),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formatDay(tanggal),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatMonth(tanggal),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Judul agenda dan tanggal dibuat
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul.length > 25 ? '${judul.substring(0, 25)}...' : judul,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dibuat pada: ${formatDateTime(createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mendapatkan hari (tanggal)
  String formatDay(String dateTimeString) {
    DateTime dateTime = parseDate(dateTimeString);
    return '${dateTime.day}';
  }

  // Fungsi untuk mendapatkan bulan
  String formatMonth(String dateTimeString) {
    DateTime dateTime = parseDate(dateTimeString);
    return getMonth(dateTime.month);
  }

  // Fungsi untuk mengonversi angka bulan menjadi nama bulan singkat
  String getMonth(int month) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }

  // Fungsi untuk parsing tanggal dengan pemeriksaan kesalahan format
  DateTime parseDate(String dateTimeString) {
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return DateTime.now(); // Return current date if format is invalid
    }
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = parseDate(dateTimeString);
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
