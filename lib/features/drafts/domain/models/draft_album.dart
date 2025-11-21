import 'package:freezed_annotation/freezed_annotation.dart';

part 'draft_album.freezed.dart';
part 'draft_album.g.dart';

@freezed
class DraftAlbum with _$DraftAlbum {
  const factory DraftAlbum({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    String? description,
    @Default([])
    List<String> photoUrls, // List of URLs or local paths to photos
    @Default('Incompleto')
    String classification, // e.g., "Completo", "En Revisión", "Incompleto"
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _DraftAlbum;

  factory DraftAlbum.fromJson(Map<String, dynamic> json) =>
      _$DraftAlbumFromJson(json);
}
