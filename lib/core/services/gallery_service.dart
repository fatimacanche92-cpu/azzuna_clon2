import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/album_model.dart';
import 'dart:math';

// 1. State Notifier
class GalleryStateNotifier extends StateNotifier<List<Album>> {
  GalleryStateNotifier() : super([]);

  final _picker = ImagePicker();

  String _generateRandomId() {
    return Random().nextInt(999999).toString();
  }

  Future<void> createAlbum(String name) async {
    final newAlbum = Album(id: _generateRandomId(), name: name, photos: []);
    state = [...state, newAlbum];
  }

  Future<void> addPhotoToAlbum(String albumId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // In a real app, you'd upload this to a server.
    // Here, we'll save it to the app's documents directory to simulate persistence.
    final directory = await getApplicationDocumentsDirectory();
    final fileName = p.basename(image.path);
    final savedImage = await File(
      image.path,
    ).copy('${directory.path}/$fileName');

    state = [
      for (final album in state)
        if (album.id == albumId)
          album.copyWith(photos: [...album.photos, savedImage.path])
        else
          album,
    ];
  }

  void deletePhoto(String albumId, String photoPath) {
    // Also delete the file from local storage
    final file = File(photoPath);
    if (file.existsSync()) {
      file.delete();
    }

    state = [
      for (final album in state)
        if (album.id == albumId)
          album.copyWith(
            photos: album.photos.where((p) => p != photoPath).toList(),
          )
        else
          album,
    ];
  }
}

// 2. Provider
final galleryServiceProvider =
    StateNotifierProvider<GalleryStateNotifier, List<Album>>((ref) {
      return GalleryStateNotifier();
    });

// 3. Helper providers
final albumProvider = Provider.family<Album?, String>((ref, albumId) {
  final albums = ref.watch(galleryServiceProvider);
  try {
    return albums.firstWhere((album) => album.id == albumId);
  } catch (e) {
    return null;
  }
});
