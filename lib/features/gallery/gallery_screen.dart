import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/services/gallery_service.dart';
import 'package:flutter_app/core/models/album_model.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  void _showCreateAlbumDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Nuevo Álbum'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nombre del álbum'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref
                      .read(galleryServiceProvider.notifier)
                      .createAlbum(controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(galleryServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Galería')),
      body: albums.isEmpty
          ? const Center(
              child: Text(
                'No hay álbumes. ¡Crea uno!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return _AlbumCard(album: album);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'gallery_fab',
        onPressed: () => _showCreateAlbumDialog(context, ref),
        label: const Text('Crear Álbum'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album});
  final Album album;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/gallery/album/${album.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: GridTile(
          footer: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.black.withAlpha((255 * 0.5).round()),
            child: Text(
              album.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          child: album.photos.isEmpty
              ? const Icon(Icons.photo_album, size: 50, color: Colors.grey)
              : Image.file(
                  File(album.photos.first), // Show first photo as thumbnail
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
