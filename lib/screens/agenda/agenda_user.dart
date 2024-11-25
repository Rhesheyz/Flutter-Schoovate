import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    fetchAccessToken(); // Fetch token first and then load data
  }

  // Fetch access token from SharedPreferences
  Future<void> fetchAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('token'); // Get the stored token
    });

    if (accessToken != null) {
      fetchAgendaData(); // Fetch agenda data if token is available
    } else {
      setState(() {
        isLoading = false; // Stop loading if token is not available
      });
      throw Exception('Access token not found');
    }
  }

  // Fetch agenda data with Bearer token
  Future<void> fetchAgendaData() async {
    const String apiUrl =
        'https://schoovate.apps-project.com/api/agenda'; // Adjust your URL

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken', // Add bearer token to headers
        },
      );

      if (response.statusCode == 200) {
        // Decode JSON response into Map
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Retrieve the agenda list from the 'data' key
        setState(() {
          agendaList = responseData['data']; // Adjust to match the 'data' key
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load agenda');
      }
    } catch (error) {
      print('Error fetching agenda: $error');
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred while loading agenda data.'),
      ));
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : agendaList.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada agenda',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
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
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Calendar-like date section
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 151, 151, 151),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          formatDate(agenda['tanggal']),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatDay(agenda['tanggal']),
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
                                // Agenda details
                                Expanded(
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
                                      const SizedBox(height: 4),
                                      Text(
                                        'Dibuat oleh: ${agenda['users']['name']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
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
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.day}'; // Return only day
  }

  String formatDay(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return getMonth(dateTime.month); // Return month name
  }

  String getMonth(int month) {
    const List<String> months = [
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
    ];
    return months[month - 1];
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}

// Detail agenda remains the same
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
      appBar: AppBar(
        title: const Text('Detail Agenda'),
      ),
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
            if (agenda['sub_judul'] != null &&
                agenda['sub_judul'].isNotEmpty) ...[
              Text(
                agenda['sub_judul'],
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Divider(
                thickness: 2,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              agenda['isi_agenda'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Dibuat Oleh: ${agenda['users']['name']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuat pada: ${formatDateTime(agenda['created_at'])}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AgendaScreen(),
  ));
}
