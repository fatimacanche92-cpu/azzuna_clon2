import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/gallery_service.dart';

class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key, required this.albumId});
  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(albumProvider(albumId));

    if (album == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Álbum no encontrado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(album.name),
      ),
      body: album.photos.isEmpty
          ? const Center(
              child: Text(
                'Este álbum está vacío.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: album.photos.length,
              itemBuilder: (context, index) {
                final photoPath = album.photos[index];
                return GridTile(
                  child: Image.file(
                    File(photoPath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: Colors.grey);
                    },
                  ),
                  footer: GridTileBar(
                    backgroundColor: Colors.black45,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        ref
                            .read(galleryServiceProvider.notifier)
                            .deletePhoto(albumId, photoPath);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'album_fab',
        onPressed: () {
          ref.read(galleryServiceProvider.notifier).addPhotoToAlbum(albumId);
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
