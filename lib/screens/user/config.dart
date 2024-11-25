import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:test_123/repository/config.dart';
import 'package:test_123/models/config.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  ConfigModel? config;
  File? backgroundImage;
  final TextEditingController _mapsLinkController = TextEditingController();
  final ConfigRepository _repository = ConfigRepository();

  @override
  void initState() {
    super.initState();
    _getByID(); // Fetch the existing configuration when the screen is initialized
  }

  Future<void> _getByID() async {
    try {
      config = await _repository.getByID();
      setState(() {
        _mapsLinkController.text = config?.mapLink ?? '';
        // If the background image is available as a URL, load it here
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _update() async {
    if (config != null) {
      config!.mapLink = _mapsLinkController.text; // Update the link

      try {
        await _repository.update(config!, backgroundImage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        backgroundImage = File(pickedFile.path); // Update the background image
      });
    }
  }

  void _saveChanges() {
    _update(); // Call the update method
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Configuration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the background image from URL if available, otherwise show the selected file
            config?.backgroundImageUrl != null
                ? Image.network(
                    config!.backgroundImageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : backgroundImage != null
                    ? Image.file(
                        backgroundImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(child: Text('No image selected')),
                      ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Banner Image'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _mapsLinkController,
              decoration: const InputDecoration(
                labelText: 'Maps coordinate',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
