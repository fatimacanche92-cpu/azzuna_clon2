import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

enum OrderShippingStatus {
  @JsonValue('en_espera')
  enEspera,
  @JsonValue('en_camino')
  enCamino,
  @JsonValue('entregado')
  entregado,
}

enum OrderPaymentStatus {
  @JsonValue('pendiente')
  pendiente,
  @JsonValue('con_anticipo')
  conAnticipo,
  @JsonValue('pagado')
  pagado,
}

enum OrderDeliveryType {
  @JsonValue('envio')
  envio,
  @JsonValue('recoger')
  recoger,
}

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String clientName,
    required String arrangementType,
    required DateTime scheduledDate,
    required OrderDeliveryType deliveryType,
    OrderShippingStatus? shippingStatus,
    required OrderPaymentStatus paymentStatus,
    required double price,
    double? downPayment,
    double? remainingAmount,
    String? publicNote,
    String? clientPhone,
    String? arrangementSize,
    String? arrangementColor,
    String? arrangementFlowerType,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}
