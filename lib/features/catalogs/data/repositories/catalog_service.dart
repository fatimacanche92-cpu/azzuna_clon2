import '../../domain/models/catalog_album.dart';
import '../../../drafts/domain/models/draft_album.dart'; // Import DraftAlbum

class CatalogService {
  // final SupabaseClient _supabase = Supabase.instance.client;

  // String _getUserId() {
  //   final user = _supabase.auth.currentUser;
  //   if (user == null) {
  //     throw Exception('User is not authenticated.');
  //   }
  //   return user.id;
  // }

  Future<List<CatalogAlbum>> getCatalogAlbums() async {
    // Mock implementation
    // ignore: avoid_print
    print('MOCK: getCatalogAlbums called, returning empty list.');
    return Future.value([]);
  }

  Future<void> addCatalogAlbum({
    required String title,
    String? description,
    List<String>? photoUrls,
    String? status,
  }) async {
    // Mock implementation
    // ignore: avoid_print
    print('MOCK: addCatalogAlbum called with title: $title');
    return Future.value();
  }

  Future<void> updateCatalogAlbum(CatalogAlbum catalogAlbum) async {
    // Mock implementation
    // ignore: avoid_print
    print('MOCK: updateCatalogAlbum called for ID: ${catalogAlbum.id}');
    return Future.value();
  }

  Future<void> deleteCatalogAlbum(String id) async {
    // Mock implementation
    // ignore: avoid_print
    print('MOCK: deleteCatalogAlbum called for ID: $id');
    return Future.value();
  }

  Future<void> importDraftAlbumToCatalog(DraftAlbum draftAlbum) async {
    // Mock implementation
    // ignore: avoid_print
    print(
      'MOCK: importDraftAlbumToCatalog called for draft: ${draftAlbum.title}',
    );
    return Future.value();
  }
}
