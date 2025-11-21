import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/album_model.dart';

class AlbumService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _getUserId() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated.');
    }
    return user.id;
  }

  Future<List<Album>> getAlbums(AlbumType type) async {
    try {
      final userId = _getUserId();
      final data = await _supabase
          .from('albums')
          .select()
          .eq('user_id', userId)
          .eq(
            'type',
            type.name,
          ) // .name is used to get the string representation of the enum
          .order('created_at', ascending: false);

      return data.map((json) => Album.fromJson(json)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error in getAlbums: $e');
      throw Exception(
        'Error getting albums. Please check your connection and try again.',
      );
    }
  }

  Future<void> addAlbum({
    required String title,
    String? description,
    required AlbumType type,
  }) async {
    try {
      final userId = _getUserId();
      final album = {
        'user_id': userId,
        'title': title,
        'description': description,
        'album_type': type.name, // Use album_type to match schema
      };
      await _supabase.from('albums').insert(album);
    } catch (e) {
      // ignore: avoid_print
      print('Error in addAlbum: $e');
      throw Exception('Error adding album.');
    }
  }

  Future<void> updateAlbum(Album album) async {
    try {
      final userId = _getUserId();
      final updates = album.toJson()
        ..remove('user_id')
        ..remove('id')
        ..remove('created_at'); // These should not be updated

      await _supabase
          .from('albums')
          .update(updates)
          .eq('id', album.id)
          .eq('user_id', userId);
    } catch (e) {
      // ignore: avoid_print
      print('Error in updateAlbum: $e');
      throw Exception('Error updating album.');
    }
  }

  Future<void> deleteAlbum(String id) async {
    try {
      final userId = _getUserId();
      await _supabase
          .from('albums')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      // ignore: avoid_print
      print('Error in deleteAlbum: $e');
      throw Exception('Error deleting album.');
    }
  }
}
