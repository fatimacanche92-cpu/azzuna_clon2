import 'package:flutter/foundation.dart';

enum PaymentMethod { mastercard, visa, paypal }

@immutable
class Pago {
  const Pago({this.paymentMethod, this.basePrice = 0.0, this.shippingCost = 0.0});

  final PaymentMethod? paymentMethod;
  final double basePrice;
  final double shippingCost;

  double get totalPrice => (basePrice) + (shippingCost);

  Pago copyWith({
    PaymentMethod? paymentMethod,
    double? basePrice,
    double? shippingCost,
  }) {
    return Pago(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      basePrice: basePrice ?? this.basePrice,
      shippingCost: shippingCost ?? this.shippingCost,
    );
  }
}
