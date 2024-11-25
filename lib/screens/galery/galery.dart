import 'package:flutter/material.dart';
import 'package:test_123/models/album.dart';
import 'package:test_123/repository/album.dart';
import 'package:test_123/screens/galery/albumCreate.dart';
import 'package:test_123/screens/galery/albumEdit.dart';
import 'package:image_picker/image_picker.dart'; // Tambahkan ini

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

  deleteAlbum(int id) async {
    try {
      await albumRepository.deleteAlbum(id);
      fetchAlbums();
    } catch (e) {
      print('Error deleting album: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: albums.isEmpty
            ? const Center(child: Text('Tidak Ada Album Tersedia'))
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
                    onTap: () async {
                      List<Album>? updatedAlbums = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDetailScreen(
                            judul: album.judul,
                            gambars: album.gambars,
                            albumId: album.id,
                          ),
                        ),
                      );

                      // Jika ada data albums yang diperbarui, perbarui state
                      if (updatedAlbums != null) {
                        setState(() {
                          albums = updatedAlbums;
                        });
                      }
                    },
                    child: Column(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .start, // Aligns text to the left
                          children: [
                            Expanded(
                              // Allows text to take full width
                              child: Text(
                                album.judul,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign:
                                    TextAlign.left, // Aligns text to the left
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Hapus Album'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin menghapus album ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmDelete) {
                                  deleteAlbum(album.id);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AlbumEditScreen(albumId: album.id),
                                  ),
                                ).then((_) => fetchAlbums());
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AlbumCreateScreen()),
          ).then((_) => fetchAlbums());
        },
        backgroundColor: const Color.fromARGB(255, 221, 221, 221),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ImageDetailScreen extends StatefulWidget {
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
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Album> albums = [];
  final AlbumRepository albumRepository = AlbumRepository();
  late List<Map<String, dynamic>>
      gambars; // Perbarui untuk menyimpan ID dan URL gambar
  double uploadProgress = 0.0; // Progres unggahan gambar

  @override
  void initState() {
    super.initState();
    gambars = widget.gambars;
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

  Future<void> _pickAndUploadImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          uploadProgress = 0.0; // Reset progres sebelum upload dimulai
        });

        // Simulasi pengunggahan gambar untuk demonstrasi
        for (var i = 0; i < images.length; i++) {
          // Anggap bahwa upload membutuhkan waktu untuk setiap gambar
          await albumRepository.uploadGambar(widget.albumId, [images[i]]);
          setState(() {
            uploadProgress = (i + 1) /
                images
                    .length; // Update progres berdasarkan gambar yang sudah di-upload
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar berhasil diunggah')),
        );

        // Ambil album terbaru setelah upload
        List<Album> updatedAlbums = await albumRepository.fetchAlbums();

        // Kembali ke layar sebelumnya dengan membawa data album terbaru
        Navigator.pop(context, updatedAlbums);
      }
    } catch (e) {
      print('Error uploading images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengunggah gambar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.judul),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Menampilkan GridView gambar
            Expanded(
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
                                  gambars: gambars
                                      .map((g) => g['url'] as String)
                                      .toList(),
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
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Gambar'),
                              content: const Text(
                                  'Apakah Anda yakin ingin menghapus gambar ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );

                          if (confirmDelete) {
                            try {
                              int idGambar = gambars[index]['id'];
                              await albumRepository.deleteGambar(idGambar);

                              setState(() {
                                gambars.removeAt(index);
                                fetchAlbums();
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Gambar berhasil dihapus')),
                              );
                            } catch (e) {
                              print('Error deleting image: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Gagal menghapus gambar')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // Menampilkan progres upload saat gambar sedang diunggah
            if (uploadProgress > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    Text(
                      'Mengunggah: ${(uploadProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: uploadProgress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadImages,
        backgroundColor: const Color.fromARGB(255, 221, 221, 221),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FullScreenImageGallery extends StatefulWidget {
  final List<String> gambars;
  final int initialIndex;

  const FullScreenImageGallery(
      {super.key, required this.gambars, required this.initialIndex});

  @override
  _FullScreenImageGalleryState createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gambar ${currentIndex + 1} dari ${widget.gambars.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.gambars.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Center(
            child: Image.network(
              widget.gambars[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(const MaterialApp(
    home: GalleryScreen(),
  ));
}
