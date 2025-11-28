import 'package:flutter_app/features/customer_tracking/domain/customer_event.dart';

class CustomerEventModel extends CustomerEvent {
  CustomerEventModel({
    required super.id,
    required super.userId,
    required super.clientName,
    super.clientPhone,
    required super.eventType,
    required super.eventDate,
    super.notes,
    super.lastPurchaseReference,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CustomerEventModel.fromJson(Map<String, dynamic> json) {
    return CustomerEventModel(
      id: json['id'],
      userId: json['user_id'],
      clientName: json['client_name'],
      clientPhone: json['client_phone'],
      eventType: json['event_type'],
      eventDate: DateTime.parse(json['event_date']),
      notes: json['notes'],
      lastPurchaseReference: json['last_purchase_reference'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'event_type': eventType,
      'event_date': eventDate.toIso8601String(),
      'notes': notes,
      'last_purchase_reference': lastPurchaseReference,
    };
  }
  
  Map<String, dynamic> toJsonForInsert() {
    // Exclude id, createdAt, updatedAt as they are handled by the database.
    return {
      'user_id': userId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'event_type': eventType,
      'event_date': eventDate.toIso8601String(),
      'notes': notes,
      'last_purchase_reference': lastPurchaseReference,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    // Exclude id, user_id, createdAt as they should not be updated.
    return {
      'client_name': clientName,
      'client_phone': clientPhone,
      'event_type': eventType,
      'event_date': eventDate.toIso8601String(),
      'notes': notes,
      'last_purchase_reference': lastPurchaseReference,
    };
  }
}
