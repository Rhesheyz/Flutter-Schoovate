import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../repository/album.dart';
import '../../models/album.dart';

class AlbumEditScreen extends StatefulWidget {
  final int albumId;

  const AlbumEditScreen({super.key, required this.albumId});

  @override
  _AlbumEditScreenState createState() => _AlbumEditScreenState();
}

class _AlbumEditScreenState extends State<AlbumEditScreen> {
  final AlbumRepository albumRepository = AlbumRepository();
  final TextEditingController _judulController = TextEditingController();
  File? _selectedImage;
  Album? album;
  String _status = 'user'; // Set nilai default sebagai "user" atau "guest"
  bool isLoading = false; // Track loading status for button

  @override
  void initState() {
    super.initState();
    fetchAlbumData();
  }

  fetchAlbumData() async {
    Album? fetchedAlbum = await albumRepository.getAlbumById(widget.albumId);
    if (fetchedAlbum != null) {
      setState(() {
        album = fetchedAlbum;
        _judulController.text = album?.judul ?? '';
        _status = album?.status ?? 'user'; // Set nilai default jika status null
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  editAlbum() async {
    String judul = _judulController.text;

    // Prevent double tap while loading
    if (isLoading) return;

    setState(() {
      isLoading = true; // Set loading to true when editing starts
    });

    if (await albumRepository.editAlbum(
        widget.albumId, judul, _status, _selectedImage)) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengedit album.')),
      );
    }

    setState(() {
      isLoading = false; // Set loading to false after process is done
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Album'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: album == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _judulController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Album',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('User'),
                      ),
                      DropdownMenuItem(
                        value: 'guest',
                        child: Text('Guest'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value ?? 'user';
                      });
                    },
                    validator: (value) => value == null
                        ? 'Pilih status antara user atau guest'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Gambar Album:'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: pickImage,
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            album!.gambar,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : editAlbum, // Disable button while loading
                    child: isLoading
                        ? const CircularProgressIndicator() // Show loading indicator while processing
                        : const Text('Simpan Perubahan'),
                  ),
                ],
              ),
      ),
    );
  }
}
