import 'package:flutter/material.dart';
import 'package:test_123/models/album.dart';
import 'package:test_123/repository/album.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Album> albums = [];
  AlbumRepository albumRepository = AlbumRepository();

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  fetchAlbums() async {
    try {
      List<Album> data = await albumRepository.fetchAlbums();
      setState(() {
        albums = data;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: albums.isEmpty
            ? const Center(
                child: Text(
                  'Tidak ada album tersedia',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDetailScreen(
                            judul: album.judul,
                            gambars: album.gambars,
                            albumId: album.id,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Ensure children align to the left
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              album.gambar,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          album.judul,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Widget baru untuk menampilkan jumlah gambar
                        Text(
                          '${album.gambars.length} gambar',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class ImageDetailScreen extends StatelessWidget {
  final String judul;
  final List<Map<String, dynamic>> gambars; // Simpan ID dan URL gambar
  final int albumId;

  const ImageDetailScreen({
    super.key,
    required this.judul,
    required this.gambars,
    required this.albumId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(judul),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 0.8,
          ),
          itemCount: gambars.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageGallery(
                            gambars:
                                gambars.map((g) => g['url'] as String).toList(),
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        gambars[index]['url'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FullScreenImageGallery extends StatelessWidget {
  final List<String> gambars;
  final int initialIndex;

  const FullScreenImageGallery(
      {super.key, required this.gambars, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gambar ${initialIndex + 1} dari ${gambars.length}'),
      ),
      body: PageView.builder(
        itemCount: gambars.length,
        itemBuilder: (context, index) {
          return Center(
            child: Image.network(
              gambars[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: GalleryScreen(),
  ));
}
