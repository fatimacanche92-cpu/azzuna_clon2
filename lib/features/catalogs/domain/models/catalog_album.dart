import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_album.freezed.dart';
part 'catalog_album.g.dart';

@freezed
class CatalogAlbum with _$CatalogAlbum {
  const factory CatalogAlbum({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    String? description,
    @Default([])
    List<String> photoUrls, // List of URLs or local paths to photos
    @Default('Pendiente Subir')
    String status, // e.g., "Pendiente Subir", "Subido"
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CatalogAlbum;

  factory CatalogAlbum.fromJson(Map<String, dynamic> json) =>
      _$CatalogAlbumFromJson(json);
}
