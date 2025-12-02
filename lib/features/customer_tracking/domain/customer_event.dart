// lib/features/customer_tracking/domain/customer_event.dart

class CustomerEvent {
  final String id;
  final String userId;

    final String eventType;

    final DateTime eventDate;

    final String? notes;

    final DateTime createdAt;
  final DateTime? updatedAt;

    final String status;
  final String? clientName;
  final String? clientPhone;
  final String? lastPurchaseReference;


  CustomerEvent({
    required this.id,
    required this.userId,

    required this.eventType,
    required this.eventDate,
        this.notes,
        required this.createdAt,
    this.updatedAt,
        required this.status,
    this.clientName,
    this.clientPhone,
    this.lastPurchaseReference,

  });
}
