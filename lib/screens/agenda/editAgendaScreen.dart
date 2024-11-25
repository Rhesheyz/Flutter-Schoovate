import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditAgendaScreen extends StatefulWidget {
  final int agendaId;

  const EditAgendaScreen({super.key, required this.agendaId});

  @override
  _EditAgendaScreenState createState() => _EditAgendaScreenState();
}

class _EditAgendaScreenState extends State<EditAgendaScreen> {
  final _formKey = GlobalKey<FormState>();
  String? accessToken;

  // Tambahkan TextEditingController untuk judul, subjudul, isi, tanggal, dan status
  TextEditingController titleController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController dateController =
      TextEditingController(); // Controller untuk tanggal

  String? selectedStatus; // Untuk menyimpan status yang dipilih
  List<String> statusOptions = [
    'user',
    'admin',
    'archive'
  ]; // Contoh pilihan status

  bool isLoading = true; // Loading saat ambil data
  bool isButtonDisabled = false; // Untuk mengontrol status tombol simpan

  @override
  void initState() {
    super.initState();
    fetchAccessToken(); // Panggil fetch token dan agenda setelah token ada
  }

  Future<void> fetchAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('token'); // Ambil token yang disimpan
    });

    if (accessToken != null) {
      print(accessToken);
      fetchAgendaData(); // Panggil data agenda jika token tersedia
    } else {
      setState(() {
        isLoading = false; // Berhenti loading jika token tidak ada
      });
      throw Exception('Access token not found');
    }
  }

  // Fetch agenda data dengan Bearer token
  Future<void> fetchAgendaData() async {
    final String apiUrl =
        'https://schoovate.apps-project.com/api/agenda/${widget.agendaId}';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization':
              'Bearer $accessToken', // Tambahkan bearer token ke header
        },
      );

      print('Status Code: ${response.statusCode}'); // Debugging

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Response Data: $responseData'); // Debugging

        if (responseData['message'] == 'Anda Belum Login') {
          // Arahkan ke halaman login jika tidak login
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }

        setState(() {
          // Setel nilai TextEditingController dengan data dari API
          titleController.text = responseData['data']['judul'];
          subtitleController.text = responseData['data']['sub_judul'] ?? '';
          contentController.text = responseData['data']['isi_agenda'];
          dateController.text =
              responseData['data']['tanggal']; // Mengisi tanggal
          selectedStatus = responseData['data']['status']; // Mengisi status
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode} - ${response.body}'); // Debugging
        setState(() {
          isLoading = false;
        });
        throw Exception('Gagal memuat agenda');
      }
    } catch (error) {
      print('Error fetching agenda: $error'); // Debugging
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Terjadi kesalahan saat memuat data agenda.'),
      ));
    }
  }

  Future<void> updateAgenda() async {
    final String apiUrl =
        'https://schoovate.apps-project.com/api/agenda/update/${widget.agendaId}';

    setState(() {
      isButtonDisabled = true; // Nonaktifkan tombol saat proses update
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'judul': titleController.text,
          'sub_judul': subtitleController.text,
          'isi_agenda': contentController.text,
          'tanggal': dateController.text, // Kirim tanggal
          'status': selectedStatus, // Kirim status
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Agenda berhasil diperbarui.'),
        ));
        Navigator.pop(
            context, true); // Kembali ke halaman sebelumnya setelah berhasil
      } else {
        throw Exception('Gagal memperbarui agenda');
      }
    } catch (error) {
      print('Error updating agenda: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Terjadi kesalahan saat memperbarui agenda.'),
      ));
    } finally {
      setState(() {
        isButtonDisabled =
            false; // Aktifkan kembali tombol setelah proses selesai
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Agenda'),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Tampilkan loading jika isLoading true
          : SingleChildScrollView(
              // Membungkus body dengan SingleChildScrollView agar bisa di-scroll
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey, // Form key untuk validasi
                  child: Column(
                    children: [
                      // Field untuk input Judul Agenda
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Judul'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul tidak boleh kosong'; // Validasi jika kosong
                          }
                          return null;
                        },
                      ),
                      // Field untuk input Sub Judul (Opsional)
                      TextFormField(
                        controller: subtitleController,
                        decoration: const InputDecoration(
                            labelText: 'Sub Judul (Opsional)'),
                      ),
                      // Field untuk input Isi Agenda
                      TextFormField(
                        controller: contentController,
                        decoration:
                            const InputDecoration(labelText: 'Isi Agenda'),
                        maxLines: 5, // Field ini bisa lebih dari satu baris
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Isi agenda tidak boleh kosong'; // Validasi jika kosong
                          }
                          return null;
                        },
                      ),
                      // Field untuk input Tanggal dalam format YYYY-MM-DD
                      TextFormField(
                        controller: dateController,
                        decoration: const InputDecoration(
                            labelText: 'Tanggal (YYYY-MM-DD)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tanggal tidak boleh kosong'; // Validasi jika kosong
                          }
                          return null;
                        },
                      ),
                      // Dropdown untuk memilih status (user/guest)
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: ['user', 'guest'].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStatus = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Status tidak boleh kosong'; // Validasi jika kosong
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                          height: 20), // Jarak antara field dan tombol
                      // Tombol untuk menyimpan perubahan
                      ElevatedButton(
                        onPressed: isButtonDisabled
                            ? null // Nonaktifkan tombol jika isButtonDisabled true
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  updateAgenda(); // Panggil fungsi updateAgenda jika validasi berhasil
                                }
                              },
                        child: const Text('Simpan Perubahan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
