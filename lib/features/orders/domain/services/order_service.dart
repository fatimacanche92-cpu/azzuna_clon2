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
              return OrderModel.fromJson(json);
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
