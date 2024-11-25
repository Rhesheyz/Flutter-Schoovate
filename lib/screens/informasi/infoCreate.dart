import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_123/repository/informasi.dart';

class InfoCreateScreen extends StatefulWidget {
  const InfoCreateScreen({super.key});

  @override
  _InfoCreateScreenState createState() => _InfoCreateScreenState();
}

class _InfoCreateScreenState extends State<InfoCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String judul = '';
  String subJudul = '';
  String isiInformasi = '';
  File? gambar; // File for the selected image

  final ImagePicker _picker = ImagePicker();
  final infoRepository _repository = infoRepository();

  bool isLoading = false; // State for loading animation

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        gambar = File(pickedFile.path); // Convert to File
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (gambar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pilih gambar terlebih dahulu')));
        return;
      }

      _formKey.currentState!.save();

      setState(() {
        isLoading = true; // Show loading indicator and disable the button
      });

      try {
        await _repository.createInformasi(
          judul: judul,
          subJudul: subJudul,
          isiInformasi: isiInformasi,
          gambar: gambar!, // Send image file
        );

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Informasi berhasil dibuat')));

        Navigator.pop(context, true); // Return true after successful creation
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          isLoading = false; // Hide loading indicator and enable the button
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Informasi Baru'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Judul'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      judul = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Sub Judul'),
                    onSaved: (value) {
                      subJudul = value!;
                    },
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Isi Informasi'),
                    onSaved: (value) {
                      isiInformasi = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Button to pick an image
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pilih Gambar'),
                  ),
                  const SizedBox(height: 16),
                  // Show selected image
                  gambar != null
                      ? Image.file(
                          gambar!,
                          height: 150,
                        )
                      : const Text('Belum ada gambar yang dipilih'),
                  const SizedBox(height: 20),
                  // Submit button that is disabled when loading
                  ElevatedButton(
                    onPressed:
                        isLoading ? null : _submitForm, // Disable if loading
                    child: isLoading
                        ? const Text(
                            'Sedang memproses...') // Change text when loading
                        : const Text('Tambah Informasi'),
                  ),
                ],
              ),
            ),
          ),
          // Loading indicator
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black45, // Semi-transparent overlay
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
