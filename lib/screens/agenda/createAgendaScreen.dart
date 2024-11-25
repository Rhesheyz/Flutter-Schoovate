import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CreateAgendaScreen extends StatefulWidget {
  const CreateAgendaScreen({super.key});

  @override
  _CreateAgendaScreenState createState() => _CreateAgendaScreenState();
}

class _CreateAgendaScreenState extends State<CreateAgendaScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _judul, _subJudul, _isiAgenda, _tanggal;
  bool isSubmitting = false;

  // Fungsi untuk membuat agenda baru dengan token
  Future<void> _submitAgenda() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs
        .getString('token'); // Mengambil Bearer Token dari SharedPreferences

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isSubmitting = true; // Menampilkan loading saat data dikirim
      });

      const String apiUrl =
          'https://schoovate.apps-project.com/api/agenda/create';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization':
                'Bearer $token', // Mengirim Bearer Token dalam header
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'judul': _judul,
            'sub_judul': _subJudul,
            'isi_agenda': _isiAgenda,
            'tanggal': _tanggal,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agenda berhasil dibuat!')),
          );
          Navigator.pop(context, true); // Kembali ke halaman sebelumnya
        } else {
          throw Exception('Gagal membuat agenda');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $error')),
        );
      } finally {
        setState(() {
          isSubmitting =
              false; // Sembunyikan loading setelah pengiriman selesai
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Agenda Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) {
                  _judul = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Sub Judul'),
                onSaved: (value) {
                  _subJudul = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Isi Agenda'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Isi agenda wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) {
                  _isiAgenda = value;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) {
                  _tanggal = value;
                },
              ),
              const SizedBox(height: 20),
              isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitAgenda,
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
