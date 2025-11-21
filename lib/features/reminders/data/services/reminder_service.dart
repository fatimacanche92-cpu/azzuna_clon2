import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/reminder_model.dart';
import 'dart:math';

class ReminderService {
  // Mock data - In-memory list of reminders
  final List<ReminderModel> _reminders = [
    ReminderModel(
      id: 'r1',
      title: 'Llamar a Cliente A',
      date: DateTime.utc(2025, 11, 20),
      isCompleted: false,
    ),
    ReminderModel(
      id: 'r2',
      title: 'Comprar materiales',
      date: DateTime.utc(2025, 11, 20),
      isCompleted: false,
    ),
    ReminderModel(
      id: 'r3',
      title: 'Enviar presupuesto',
      date: DateTime.utc(2025, 11, 21),
      isCompleted: true, // Completed reminder
    ),
    ReminderModel(
      id: 'r4',
      title: 'Revisar inventario',
      date: DateTime.utc(2025, 11, 22),
      isCompleted: false,
    ),
  ];

  Future<List<ReminderModel>> getReminders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_reminders); // Return a copy to prevent external modification
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newReminder = reminder.copyWith(id: Random().nextInt(100000).toString());
    _reminders.add(newReminder);
  }

  Future<void> toggleReminderCompletion(String id, bool isCompleted) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(isCompleted: isCompleted);
    }
  }

  Future<void> deleteReminder(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _reminders.removeWhere((r) => r.id == id);
  }
}

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService();
});
