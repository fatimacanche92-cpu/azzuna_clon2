import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_app/features/orders/domain/models/order_model.dart';
import 'package:flutter_app/shared/services/supabase_service.dart';

class OrderService {
  final SupabaseClient _supabase = SupabaseService.client;

  // Dummy data for development
  static final List<OrderModel> _dummyOrders = [
    OrderModel(
      id: '001',
      clientName: 'Cliente Ejemplo 1',
      arrangementType: 'Arreglo Floral',
      scheduledDate: DateTime.now(),
      deliveryType: OrderDeliveryType.envio,
      shippingStatus: OrderShippingStatus.enEspera,
      paymentStatus: OrderPaymentStatus.pagado,
      price: 50.0,
    ),
    OrderModel(
      id: '004',
      clientName: 'Ana López',
      arrangementType: 'Floral Grande',
      scheduledDate: DateTime.now(),
      deliveryType: OrderDeliveryType.recoger,
      paymentStatus: OrderPaymentStatus.conAnticipo,
      price: 650.0,
      downPayment: 300.0,
      remainingAmount: 350.0,
    ),
    OrderModel(
      id: '002',
      clientName: 'Cliente Ejemplo 2',
      arrangementType: 'Ramo de Rosas',
      scheduledDate: DateTime.now(),
      deliveryType: OrderDeliveryType.envio,
      shippingStatus: OrderShippingStatus.enCamino,
      paymentStatus: OrderPaymentStatus.pagado,
      price: 75.0,
    ),
    OrderModel(
      id: '005',
      clientName: 'Carlos Pérez',
      arrangementType: 'Rosa Premium',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      deliveryType: OrderDeliveryType.recoger,
      paymentStatus: OrderPaymentStatus.pagado,
      price: 420.0,
    ),
    OrderModel(
      id: '003',
      clientName: 'Cliente Ejemplo 3',
      arrangementType: 'Caja de Girasoles',
      scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
      deliveryType: OrderDeliveryType.envio,
      shippingStatus: OrderShippingStatus.entregado,
      paymentStatus: OrderPaymentStatus.pagado,
      price: 60.0,
    ),
  ];

  Future<List<OrderModel>> getOrders() async {
    try {
      final data = await _supabase
          .from('orders')
          .select()
          .order('scheduled_date', ascending: false);

      // Handle potential parsing errors
      final orders = data
          .map((json) {
            try {
              // Supabase returns snake_case keys; map them to the camelCase
              // names expected by the generated `fromJson`.
              final Map<String, dynamic> mapped = {
                'id': json['id'],
                'clientName': json['client_name'],
                'arrangementType': json['arrangement_type'],
                'scheduledDate': json['scheduled_date'],
                'deliveryType': json['delivery_type'],
                'shippingStatus': json['shipping_status'],
                'paymentStatus': json['payment_status'],
                'price': json['price'],
                'downPayment': json['down_payment'],
                'remainingAmount': json['remaining_amount'],
                'publicNote': json['public_note'],
                'clientPhone': json['client_phone'],
                'arrangementSize': json['arrangement_size'],
                'arrangementColor': json['arrangement_color'],
                'arrangementFlowerType': json['arrangement_flower_type'],
              };

              // Normalize arrangementSize values saved previously like "ArregloSize.p" or single-letter codes
              final sizeVal = mapped['arrangementSize'];
              if (sizeVal is String) {
                String normalized = sizeVal;
                if (normalized.startsWith('ArregloSize.')) {
                  normalized = normalized.split('.').last;
                }
                final sizeMap = {'p': 'pequeño', 'm': 'mediano', 'g': 'grande', 'eg': 'extra grande'};
                if (sizeMap.containsKey(normalized)) {
                  mapped['arrangementSize'] = sizeMap[normalized]!
;
                }
              }

              return OrderModel.fromJson(mapped);
            } catch (e) {
              print('Error parsing order: $json, error: $e');
              return null;
            }
          })
          .where((order) => order != null)
          .cast<OrderModel>()
          .toList();

      // If no orders from Supabase, return dummy data for development
      if (orders.isEmpty) {
        print('No orders from Supabase, returning dummy data');
        return _dummyOrders;
      }

      return orders;
    } catch (e) {
      print('Error getting orders from Supabase: $e, returning dummy data');
      // On error, return dummy data for development
      return _dummyOrders;
    }
  }
}
