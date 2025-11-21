import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder_model.dart';

class ReminderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _getUserId() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated.');
    }
    return user.id;
  }

  Future<List<Reminder>> getReminders() async {
    try {
      final userId = _getUserId();
      final data = await _supabase
          .from('reminders')
          .select()
          .eq('user_id', userId)
          .order(
            'reminder_datetime',
            ascending: true,
          ); // FIX: Column name is reminder_datetime

      return data.map((json) => Reminder.fromJson(json)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error in getReminders: $e');
      throw Exception(
        'Error getting reminders. Please check your connection and try again.',
      );
    }
  }

  Future<void> addReminder({
    required String title,
    String? description,
    required DateTime date,
    String? clientName,
    String? clientPhoneNumber,
    String? clientAddress,
    String? paymentStatus,
    double? amountPaid,
    double? amountDue,
    String? orderSpecification,
    bool hasNote = false, // This parameter seems unused in the new schema
    bool isAnonymous = false,
    String? flowerArrangementSize,
    double? flowerArrangementPrice,
    String? flowerArrangementColor,
    List<String>? flowerTypes,
    String? specialFlowerInstructions,
    String? classification,
  }) async {
    try {
      final userId = _getUserId();

      // Combine title and description into a single note.
      final note = (title.isNotEmpty ? '$title\n' : '') + (description ?? '');

      // Combine order specifications
      final customization = [
        orderSpecification,
        specialFlowerInstructions,
      ].where((s) => s != null && s.isNotEmpty).join('\n');

      final reminder = {
        'user_id': userId,
        'client_name': clientName,
        'client_phone': clientPhoneNumber,
        'client_address': clientAddress,
        'has_paid':
            paymentStatus != null && paymentStatus.toLowerCase() == 'paid',
        'advance_amount': amountPaid,
        'remaining_amount': amountDue,
        'is_anonymous': isAnonymous,
        'note': note,
        'product_size': flowerArrangementSize,
        'product_price': flowerArrangementPrice,
        'product_color': flowerArrangementColor,
        'product_flowers': flowerTypes?.join(', '),
        'product_customization': customization,
        'reminder_type': classification,
        'reminder_datetime': date.toIso8601String(),
        'status': 'pending', // Explicitly set status
      };

      await _supabase.from('reminders').insert(reminder);
    } catch (e) {
      // ignore: avoid_print
      print('Error in addReminder: $e');
      throw Exception('Error adding reminder.');
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      final userId = _getUserId();
      // Omit fields that should not be changed during an update.
      final updates = reminder.toJson()
        ..remove('user_id')
        ..remove('id');

      await _supabase
          .from('reminders')
          .update(updates)
          .eq('id', reminder.id)
          .eq(
            'user_id',
            userId,
          ); // Ensure user can only update their own reminders
    } catch (e) {
      // ignore: avoid_print
      print('Error in updateReminder: $e');
      throw Exception('Error updating reminder.');
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final userId = _getUserId();
      await _supabase
          .from('reminders')
          .delete()
          .eq('id', id)
          .eq(
            'user_id',
            userId,
          ); // Ensure user can only delete their own reminders
    } catch (e) {
      // ignore: avoid_print
      print('Error in deleteReminder: $e');
      throw Exception('Error deleting reminder.');
    }
  }
}
