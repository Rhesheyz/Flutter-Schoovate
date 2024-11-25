import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Library untuk picking image
import 'package:test_123/models/informasi.dart';
import 'package:test_123/repository/informasi.dart';

class InfoEditScreen extends StatefulWidget {
  final int infoId;

  const InfoEditScreen({super.key, required this.infoId});

  @override
  _InfoEditScreenState createState() => _InfoEditScreenState();
}

class _InfoEditScreenState extends State<InfoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String? judul, subJudul, isiInformasi, status;
  File? _imageFile; // File untuk gambar
  bool isLoading = false; // Add loading state here
  Informasi? informasi;
  final picker = ImagePicker(); // Picker untuk gambar

  infoRepository informasiRepo = infoRepository();

  @override
  void initState() {
    super.initState();
    fetchInformasiDetail(); // Fetch informasi detail by ID
  }

  // Fetch data for editing
  fetchInformasiDetail() async {
    setState(() {
      isLoading = true; // Set loading to true when fetching data
    });

    try {
      Informasi info = await informasiRepo.getInformasiById(widget.infoId);
      setState(() {
        informasi = info;
        judul = info.judul;
        subJudul = info.sub_judul;
        isiInformasi = info.isi_informasi;
        status = info.status; // Initialize status from API response
        isLoading = false; // Set loading to false after data is fetched
      });
    } catch (e) {
      print("Error fetching detail: $e");
      setState(() {
        isLoading = false; // Set loading to false if there is an error
      });
    }
  }

  // Pick image for the form
  Future<void> _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Simpan path file gambar
      });
    }
  }

  // Submit the edit form
  Future<void> editInformasi() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true; // Start the loading indicator
      });

      try {
        // API call to update the information
        await informasiRepo.editInformasi(
          widget.infoId,
          judul!,
          subJudul!,
          isiInformasi!,
          _imageFile, // Pass image if available
          status!, // Include status
        );

        // Go back and indicate success
        Navigator.pop(context, true);
      } catch (e) {
        // Debugging error
        print('Error editing data: $e');

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update information. Error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          isLoading = false; // Stop the loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Informasi")),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: judul,
                        decoration: const InputDecoration(labelText: 'Judul'),
                        onSaved: (value) => judul = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: subJudul,
                        decoration:
                            const InputDecoration(labelText: 'Sub Judul'),
                        onSaved: (value) => subJudul = value,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: isiInformasi,
                        decoration:
                            const InputDecoration(labelText: 'Isi Informasi'),
                        maxLines: 5,
                        onSaved: (value) => isiInformasi = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Isi informasi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : _pickImage, // Disable button if loading
                            child: const Text('Pilih Gambar'),
                          ),
                          const SizedBox(width: 16),
                          _imageFile == null
                              ? const Text('Tidak ada gambar dipilih')
                              : Image.file(
                                  _imageFile!,
                                  width: 100,
                                  height: 100,
                                ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Dropdown for Status
                      DropdownButtonFormField<String>(
                        value: status, // Current value of status
                        decoration: const InputDecoration(labelText: 'Status'),
                        onChanged: isLoading
                            ? null
                            : (newValue) {
                                // Disable dropdown if loading
                                setState(() {
                                  status = newValue; // Update status
                                });
                              },
                        onSaved: (newValue) => status = newValue,
                        items: const [
                          DropdownMenuItem(
                            value: 'guest',
                            child: Text('guest'),
                          ),
                          DropdownMenuItem(
                            value: 'user',
                            child: Text('user'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pilih status';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : editInformasi, // Disable button if loading
                        child: isLoading
                            ? const CircularProgressIndicator() // Show loading spinner inside button
                            : const Text('Simpan Perubahan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
