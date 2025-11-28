// lib/features/customer_tracking/domain/customer_tracking_repository.dart

import 'package:flutter_app/features/customer_tracking/domain/customer_event.dart';

abstract class CustomerTrackingRepository {
  Future<List<CustomerEvent>> getCustomerEvents();
  Future<void> addCustomerEvent(CustomerEvent event);
  Future<void> updateCustomerEvent(CustomerEvent event);
  Future<void> deleteCustomerEvent(String eventId);
}
