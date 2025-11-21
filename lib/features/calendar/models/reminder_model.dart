import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder_model.freezed.dart';
part 'reminder_model.g.dart';

@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    String? description,
    required DateTime date,
    String? clientName,
    String? clientPhoneNumber,
    String? clientAddress,
    String? paymentStatus, // e.g., "Pagado", "Anticipo", "Pendiente"
    double? amountPaid,
    double? amountDue,
    String? orderSpecification,
    @Default(false) bool hasNote,
    @Default(false) bool isAnonymous,
    String? flowerArrangementSize,
    double? flowerArrangementPrice,
    String? flowerArrangementColor,
    List<String>? flowerTypes,
    String? specialFlowerInstructions,
    String?
    classification, // e.g., "Pedido", "Entrega", "Publicación Pendiente"
    @Default(false) bool completed,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
