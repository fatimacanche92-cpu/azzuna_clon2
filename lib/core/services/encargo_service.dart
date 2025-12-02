import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/encargo_model.dart';
import '../models/arreglo_model.dart';
import '../models/entrega_model.dart';
import '../models/pago_model.dart';

// 1. State Notifier
class EncargoStateNotifier extends StateNotifier<Encargo> {
  EncargoStateNotifier() : super(const Encargo());

  void updateArreglo(Arreglo arreglo) {
    state = state.copyWith(arreglo: arreglo);
  }

  void updateEntrega(Entrega entrega) {
    state = state.copyWith(entrega: entrega);
  }

  void updatePago(Pago pago) {
    state = state.copyWith(pago: pago);
  }

  void updateCardData(Uint8List? cardData) {
    state = state.copyWith(cardData: cardData);
  }

  void resetEncargo() {
    state = const Encargo();
  }

  // Getters for easy access in the UI
  Arreglo? get arreglo => state.arreglo;
  Entrega? get entrega => state.entrega;
  Pago? get pago => state.pago;
  Uint8List? get cardData => state.cardData;
}

// 2. Provider
final encargoServiceProvider =
    StateNotifierProvider<EncargoStateNotifier, Encargo>((ref) {
      return EncargoStateNotifier();
    });
