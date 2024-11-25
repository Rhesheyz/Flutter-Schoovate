import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:test_123/repository/album.dart'; // Repository untuk create album

class AlbumCreateScreen extends StatefulWidget {
  const AlbumCreateScreen({super.key});

  @override
  _AlbumCreateScreenState createState() => _AlbumCreateScreenState();
}

class _AlbumCreateScreenState extends State<AlbumCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String? judul;
  File? _imageFile;
  final picker = ImagePicker();
  final AlbumRepository albumRepository = AlbumRepository();
  bool isLoading = false; // Track loading status for button

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> saveAlbum() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_imageFile != null) {
        setState(() {
          isLoading = true; // Set loading state to true when saving
        });

        try {
          await albumRepository.createAlbum(
            judul: judul!,
            imageFile: _imageFile!,
          );
          Navigator.pop(context, true); // Kembali ke galeri setelah berhasil
        } catch (e) {
          print('Error creating album: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menambahkan album')),
          );
        } finally {
          setState(() {
            isLoading = false; // Set loading state to false after process
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih gambar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Album'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Judul Album'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => judul = value,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.file(_imageFile!, height: 150, width: 150),
                ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : saveAlbum, // Disable button while loading
                  child: isLoading
                      ? const CircularProgressIndicator() // Show loading indicator while processing
                      : const Text('Simpan Album'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
