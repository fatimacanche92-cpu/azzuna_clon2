import 'package:flutter/foundation.dart';
import 'arreglo_model.dart';
import 'entrega_model.dart';
import 'pago_model.dart';

@immutable
class Encargo {
  const Encargo({this.arreglo, this.entrega, this.pago});

  final Arreglo? arreglo;
  final Entrega? entrega;
  final Pago? pago;

  Encargo copyWith({Arreglo? arreglo, Entrega? entrega, Pago? pago}) {
    return Encargo(
      arreglo: arreglo ?? this.arreglo,
      entrega: entrega ?? this.entrega,
      pago: pago ?? this.pago,
    );
  }

  bool get isArregloCompleted =>
      arreglo != null && arreglo!.size != null && arreglo!.flowerType != null;
  bool get isEntregaCompleted =>
      entrega != null && entrega!.deliveryType != null;
  bool get isPagoCompleted => pago != null && pago!.paymentMethod != null;
}
