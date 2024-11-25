import 'package:flutter/material.dart';

import 'home/home_user.dart';
import 'informasi/infoscreen_user.dart';
import 'agenda/agenda_user.dart';
import 'galery/galery_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart'; // Import untuk kembali ke layar login

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeTab(),
    const InfoScreen(),
    const AgendaScreen(),
    const GalleryScreen(),
  ];

  // Fungsi untuk melakukan logout
  Future<void> logout() async {
    const String apiUrl =
        'https://schoovate.apps-project.com/api/logout'; // Sesuaikan URL logout

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token', // Sertakan token di header
            'Accept': 'application/json', // Sertakan token di header
          },
        );

        if (response.statusCode == 200 || response.statusCode == 401) {
          // Hapus token dari SharedPreferences setelah logout berhasil
          await prefs.remove('token');

          // Navigasi ke halaman login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout berhasil')),
          );
        } else {
          print(response.statusCode);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout gagal')),
          );
        }
      } catch (error) {
        print('Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan, coba lagi.')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schoovate',
          style: TextStyle(
            color: Colors.white, // Warna teks
            fontWeight: FontWeight.bold, // Teks tebal
            fontSize: 24, // Ukuran teks
          ),
        ),
        centerTitle: false, // Judul di tengah
        backgroundColor:
            const Color.fromARGB(255, 124, 123, 123), // Warna background AppBar
        elevation: 4, // Bayangan AppBar
        shadowColor: Colors.black.withOpacity(0.5), // Warna bayangan

        // Tambahkan IconButton untuk logout
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Tampilkan dialog konfirmasi sebelum logout
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Apakah Anda yakin ingin logout?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                        },
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                          logout(); // Panggil fungsi logout
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline), // Ikon info
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event), // Ikon agenda
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album), // Ikon galeri
            label: 'Gallery',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, //test
        unselectedItemColor: Colors.grey, // Warna item yang tidak dipilih
        onTap: _onItemTapped,
        // Sesuaikan ukuran ikon dan label
        selectedIconTheme:
            const IconThemeData(size: 28), // Ukuran ikon terpilih
        unselectedIconTheme:
            const IconThemeData(size: 24), // Ukuran ikon tidak terpilih
        selectedFontSize: 14, // Ukuran font terpilih
        unselectedFontSize: 12, // Ukuran font tidak terpilih
        type: BottomNavigationBarType
            .fixed, // Tetapkan ke 'fixed' jika lebih dari 3 item
      ),
    );
  }
}
