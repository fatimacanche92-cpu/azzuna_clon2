import 'dart:typed_data';
import 'dart:math';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_app/shared/services/supabase_service.dart';
import '../models/encargo_model.dart';
import '../models/arreglo_model.dart';
import '../models/entrega_model.dart';
import '../models/pago_model.dart';

// 1. State Notifier
class EncargoStateNotifier extends StateNotifier<Encargo> {
  final SupabaseClient _supabase = SupabaseService.client;

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

  // Save the encargo (order) to Supabase
  Future<bool> saveEncargo() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('User not authenticated');
        return false;
      }

      final arreglo = state.arreglo;
      final entrega = state.entrega;
      final pago = state.pago;

      if (arreglo == null || entrega == null || pago == null) {
        print('Incomplete encargo data');
        return false;
      }

      // Determine price for order: prefer Pago values, otherwise fallback to random
      final double computedBase = pago.basePrice;
      final double computedShipping = pago.shippingCost;
      double computedPrice;
      if (computedBase > 0 || computedShipping > 0) {
        computedPrice = computedBase + computedShipping;
      } else {
        final rnd = Random();
        // fallback base between 500-1500
        final base = 500 + rnd.nextInt(1001);
        // fallback shipping between 50-200
        final shipping = 50 + rnd.nextInt(151);
        computedPrice = (base + shipping).toDouble();
      }

      String _sizeToWord(ArregloSize? s) {
        switch (s) {
          case ArregloSize.p:
            return 'pequeño';
          case ArregloSize.m:
            return 'mediano';
          case ArregloSize.g:
            return 'grande';
          case ArregloSize.eg:
            return 'extra grande';
          default:
            return 'mediano';
        }
      }

      final orderData = {
        'user_id': user.id,
        'client_name': entrega.recipientName ?? entrega.pickupName ?? 'Cliente',
        'arrangement_type': arreglo.flowerType ?? 'Arreglo Floral',
        'arrangement_size': _sizeToWord(arreglo.size),
        'arrangement_color': arreglo.colors.isNotEmpty ? arreglo.colors.join(', ') : 'Mixtos',
        'arrangement_flower_type': arreglo.flowerType,
        'price': computedPrice,
        'delivery_type': entrega.deliveryType == DeliveryType.pasaPorEl ? 'recoger' : 'envio',
        'delivery_address': entrega.deliveryAddress,
        'public_note': entrega.note,
        'sender_name': entrega.remitente,
        'payment_status': 'pendiente',
        'scheduled_date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // If there's card data in the encargo, try to upload it to Supabase Storage
      if (state.cardData != null && state.cardData!.isNotEmpty) {
        try {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final localFileName = 'card_$timestamp.png';
          final bucketPath = '${user.id}/$localFileName';

          final tmpDir = Directory.systemTemp;
          final tmpFile = File('${tmpDir.path}/$localFileName');
          await tmpFile.writeAsBytes(state.cardData!);

          // Attempt upload with retries
          const int maxAttempts = 3;
          int attempt = 0;
          while (attempt < maxAttempts) {
            attempt++;
            try {
              await _supabase.storage
                  .from('cards')
                  .upload(
                    bucketPath,
                    tmpFile,
                    fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
                  );
              break;
            } catch (uploadErr) {
              print('Upload attempt $attempt failed for card: $uploadErr');
              if (attempt >= maxAttempts) rethrow;
              await Future.delayed(Duration(milliseconds: 500 * attempt));
            }
          }

          // Get public URL and attach
          try {
            final imageUrl = _supabase.storage.from('cards').getPublicUrl(bucketPath);
            orderData['card_image_url'] = imageUrl;
            print('Card image public URL: $imageUrl');
          } catch (urlErr) {
            print('Warning: could not obtain public URL for card image: $urlErr');
          }

          // cleanup temp file
          try {
            if (await tmpFile.exists()) await tmpFile.delete();
          } catch (_) {}
        } catch (e) {
          print('Warning: failed to upload card image: $e');
        }
      }

      final response = await _supabase.from('orders').insert(orderData).select();

      print('Order saved successfully: $response');
      resetEncargo();
      return true;
    } catch (e, st) {
      // Improved logging to surface the real error and stacktrace
      print('Error saving encargo: $e');
      print('Stacktrace: $st');
      return false;
    }
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
