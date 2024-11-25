import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'createAgendaScreen.dart';
import 'editAgendaScreen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  List<dynamic> agendaList = [];
  bool isLoading = true;
  String? accessToken;

  @override
  void initState() {
    super.initState();
    fetchAccessToken();
  }

  Future<void> fetchAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('token');
    });

    if (accessToken != null) {
      fetchAgendaData();
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Access token not found');
    }
  }

  Future<void> fetchAgendaData() async {
    const String apiUrl = 'https://schoovate.apps-project.com/api/agenda';

    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          agendaList = responseData['data']; // Update agenda list
        });
      } else {
        throw Exception(
            'Failed to load agenda. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching agenda: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch agenda: ${error.toString()}'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> deleteAgenda(int id) async {
    final String apiUrl =
        'https://schoovate.apps-project.com/api/agenda/delete/$id';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          agendaList.removeWhere((agenda) => agenda['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agenda berhasil dihapus.')),
        );
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Gagal menghapus agenda');
      }
    } catch (error) {
      print('Error deleting agenda: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Terjadi kesalahan saat menghapus agenda.')),
      );
    }
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  // Fungsi untuk format tanggal menjadi "12 Nov"
  String formatDateForCard(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][dateTime.month - 1];
    return '$day\n$month';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : agendaList.isEmpty
              ? const Center(child: Text('Tidak ada agenda tersedia'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: agendaList.length,
                    itemBuilder: (context, index) {
                      final agenda = agendaList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AgendaDetailScreen(agenda: agenda),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              // Kotak tanggal di kiri
                              Container(
                                width: 60,
                                height: 60,
                                margin: const EdgeInsets.only(
                                    left: 8), // Menambahkan margin kiri
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 116, 116, 116),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  formatDateForCard(agenda['tanggal']),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Isi kartu
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        agenda['judul'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (agenda['sub_judul'] != null &&
                                          agenda['sub_judul'].isNotEmpty) ...[
                                        Text(
                                          agenda['sub_judul'],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      Text(
                                        'Dibuat oleh: ${agenda['users']['name']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Dibuat pada: ${formatDateTime(agenda['created_at'])}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Tombol Edit dan Delete
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditAgendaScreen(
                                                  agendaId: agenda['id']),
                                        ),
                                      );

                                      // Check if the result is true, indicating a successful edit
                                      if (result == true) {
                                        fetchAgendaData(); // Refresh the agenda list
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      // Konfirmasi sebelum menghapus
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Konfirmasi"),
                                            content: const Text(
                                                "Apakah Anda yakin ingin menghapus agenda ini?"),
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
                                                  deleteAgenda(agenda['id']);
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
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateAgendaScreen()),
          );

          if (result == true) fetchAgendaData();
        },
        backgroundColor: const Color.fromARGB(255, 221, 221, 221),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AgendaDetailScreen extends StatelessWidget {
  final Map<String, dynamic> agenda;

  const AgendaDetailScreen({super.key, required this.agenda});

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Agenda')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal Agenda: ${agenda['tanggal']}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              agenda['judul'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (agenda['sub_judul'] != null && agenda['sub_judul'].isNotEmpty)
              Text(
                agenda['sub_judul'],
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 8),
            const Divider(thickness: 2, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              agenda['isi_agenda'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Dibuat Oleh: ${agenda['users']['name']}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuat pada: ${formatDateTime(agenda['created_at'])}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
