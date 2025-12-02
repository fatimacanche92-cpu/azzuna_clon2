import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/orders/domain/models/order_model.dart';
import 'package:flutter_app/features/orders/domain/services/order_service.dart';

// Provider for the OrderService
final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

// Provider to fetch all orders
final allOrdersProvider = FutureProvider<List<OrderModel>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrders();
});

// Provider to filter for pickup orders
final pickupOrdersProvider = Provider<List<OrderModel>>((ref) {
  final ordersAsyncValue = ref.watch(allOrdersProvider);
  return ordersAsyncValue.when(
    data: (orders) => orders
        .where((order) => order.deliveryType == OrderDeliveryType.recoger)
        .toList(),
    loading: () => [],
    error: (err, stack) => [],
  );
});

// Provider to filter for shipping orders
final shippingOrdersProvider = Provider<List<OrderModel>>((ref) {
  final ordersAsyncValue = ref.watch(allOrdersProvider);
  return ordersAsyncValue.when(
    data: (orders) => orders
        .where((order) => order.deliveryType == OrderDeliveryType.envio)
        .toList(),
    loading: () => [],
    error: (err, stack) => [],
  );
});
