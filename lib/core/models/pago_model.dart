import 'package:flutter/foundation.dart';

enum PaymentMethod { mastercard, visa, paypal }

@immutable
class Pago {
  const Pago({this.paymentMethod});

  final PaymentMethod? paymentMethod;

  Pago copyWith({PaymentMethod? paymentMethod}) {
    return Pago(paymentMethod: paymentMethod ?? this.paymentMethod);
  }
}
