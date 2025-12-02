import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/reminder_model.dart';
import '../../data/services/reminder_service.dart';

class ReminderState {
  final List<ReminderModel> reminders;
  final bool isLoading;
  final String? error;

  ReminderState({
    this.reminders = const [],
    this.isLoading = false,
    this.error,
  });

  ReminderState copyWith({
    List<ReminderModel>? reminders,
    bool? isLoading,
    String? error,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReminderNotifier extends StateNotifier<ReminderState> {
  final ReminderService _reminderService;

  ReminderNotifier(this._reminderService) : super(ReminderState()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    state = state.copyWith(isLoading: true);
    try {
      final allReminders = await _reminderService.getReminders();
      state = state.copyWith(reminders: allReminders, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  List<ReminderModel> getRemindersForDay(DateTime day) {
    return state.reminders
        .where(
          (r) =>
              !r.isCompleted &&
              r.date.year == day.year &&
              r.date.month == day.month &&
              r.date.day == day.day,
        )
        .toList();
  }

  List<ReminderModel> getPendingReminders() {
    // Sort by date, then by completion status
    final pending = state.reminders.where((r) => !r.isCompleted).toList();
    pending.sort((a, b) => a.date.compareTo(b.date));
    return pending;
  }

  Future<void> addReminder(ReminderModel reminder) async {
    state = state.copyWith(isLoading: true);
    try {
      await _reminderService.addReminder(reminder);
      await loadReminders(); // Reload to get updated list
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> toggleReminderCompletion(String id, bool isCompleted) async {
    state = state.copyWith(isLoading: true);
    try {
      await _reminderService.toggleReminderCompletion(id, isCompleted);
      await loadReminders(); // Reload to get updated list
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final reminderNotifierProvider =
    StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
      final reminderService = ref.watch(reminderServiceProvider);
      return ReminderNotifier(reminderService);
    });
