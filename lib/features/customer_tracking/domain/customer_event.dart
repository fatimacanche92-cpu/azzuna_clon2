// lib/features/customer_tracking/domain/customer_event.dart

class CustomerEvent {
  final String id;
  final String userId;
  final String clientName;
  final String? clientPhone;
  final String eventType;
  final DateTime eventDate;
  final String? notes;
  final String? lastPurchaseReference;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerEvent({
    required this.id,
    required this.userId,
    required this.clientName,
    this.clientPhone,
    required this.eventType,
    required this.eventDate,
    this.notes,
    this.lastPurchaseReference,
    required this.createdAt,
    required this.updatedAt,
  });
}
