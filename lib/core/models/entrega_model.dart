import 'package:flutter/foundation.dart';

enum DeliveryType { pasaPorEl, porEntrega }
enum PaymentStatus { pagado }

@immutable
class Entrega {
  const Entrega({
    this.deliveryType,
    this.pickupName,
    this.pickupPhone,
    this.paymentStatus,
    this.deliveryAddress,
    this.recipientName,
    this.note,
    this.remitente,
  });

  // Common fields
  final DeliveryType? deliveryType;
  final PaymentStatus? paymentStatus;

  // 'Pasa por él' fields
  final String? pickupName;
  final String? pickupPhone;

  // 'Por entrega' fields
  final String? deliveryAddress;
  final String? recipientName;
  final String? note;
  final String? remitente;


  Entrega copyWith({
    DeliveryType? deliveryType,
    PaymentStatus? paymentStatus,
    String? pickupName,
    String? pickupPhone,
    String? deliveryAddress,
    String? recipientName,
    String? note,
    String? remitente,
  }) {
    return Entrega(
      deliveryType: deliveryType ?? this.deliveryType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      pickupName: pickupName ?? this.pickupName,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      recipientName: recipientName ?? this.recipientName,
      note: note ?? this.note,
      remitente: remitente ?? this.remitente,
    );
  }
}
