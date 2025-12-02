import 'package:flutter_app/features/customer_tracking/domain/customer_event.dart';

class CustomerEventModel extends CustomerEvent {
  CustomerEventModel({
    required super.id,
    required super.userId,
    required super.eventType,
    required super.eventDate,
    super.notes,
    required super.createdAt,
    super.updatedAt,
    required super.status,
    super.clientName,
    super.clientPhone,
    super.lastPurchaseReference,
  });

  factory CustomerEventModel.fromJson(Map<String, dynamic> json) {
    return CustomerEventModel(
      id: json['id'],
      userId: json['user_id'],
      eventType: json['event_type'],
      eventDate: DateTime.parse(json['event_date']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      status: json['status'],
      clientName: json['client_name'],
      clientPhone: json['client_phone'],
      lastPurchaseReference: json['last_purchase_reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_type': eventType,
      'event_date': eventDate.toIso8601String(),
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'client_name': clientName,
      'client_phone': clientPhone,
      'last_purchase_reference': lastPurchaseReference,
    };
  }

  Map<String, dynamic> toJsonForInsert() {
    // Exclude id, createdAt as they are handled by the database.
    return {
      'user_id': userId,
      'event_type': eventType,
      'event_date': eventDate.toIso8601String(),
      'notes': notes,
      'status': status,
      'client_name': clientName,
      'client_phone': clientPhone,
      'last_purchase_reference': lastPurchaseReference,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    // Exclude id, user_id, createdAt as they should not be updated.
    return {
      'event_type': eventType,
      'event_date': eventDate.toIso8601String(),
      'notes': notes,
      'status': status,
      'client_name': clientName,
      'client_phone': clientPhone,
      'last_purchase_reference': lastPurchaseReference,
    };
  }
}
