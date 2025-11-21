import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder_model.freezed.dart';
part 'reminder_model.g.dart';

@freezed
class ReminderModel with _$ReminderModel {
  const factory ReminderModel({
    required String id,
    required String title,
    required DateTime date,
    @Default(false) bool isCompleted,
  }) = _ReminderModel;

  factory ReminderModel.fromJson(Map<String, dynamic> json) => _$ReminderModelFromJson(json);
}
