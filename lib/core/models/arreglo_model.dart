import 'package:flutter/foundation.dart';

enum ArregloSize { p, m, g, eg }

@immutable
class Arreglo {
  const Arreglo({this.size, this.colors = const [], this.flowerType});

  final ArregloSize? size;
  final List<String> colors;
  final String? flowerType;

  Arreglo copyWith({
    ArregloSize? size,
    List<String>? colors,
    String? flowerType,
  }) {
    return Arreglo(
      size: size ?? this.size,
      colors: colors ?? this.colors,
      flowerType: flowerType ?? this.flowerType,
    );
  }
}
