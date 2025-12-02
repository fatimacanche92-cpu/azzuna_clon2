import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_app/features/orders/domain/models/order_model.dart';
import 'package:flutter_app/shared/services/supabase_service.dart';

class OrderService {
  final SupabaseClient _supabase = SupabaseService.client;

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

      return orders;
    } catch (e) {
      throw Exception('Error getting orders: $e');
    }
  }
}
