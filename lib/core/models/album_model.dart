import 'package:flutter/foundation.dart';

@immutable
class Album {
  const Album({required this.id, required this.name, required this.photos});

  final String id;
  final String name;
  final List<String> photos;

  Album copyWith({String? id, String? name, List<String>? photos}) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      photos: photos ?? this.photos,
    );
  }
}
