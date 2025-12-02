import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response;
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    String? phone,
    String? address,
    String? schedule,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('profiles').update({
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'schedule': schedule,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  }
}