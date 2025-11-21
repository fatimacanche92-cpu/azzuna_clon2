import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/services/supabase_service.dart';
import '../models/user_profile_model.dart';
import 'dart:io';

class UserProfileService {
  final SupabaseClient _client;

  UserProfileService(this._client);

  Future<UserProfileModel> getUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Not authenticated');
    }

    // Fetch the profile from the 'profiles' table
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    
    // Supabase returns a map, we need to convert it to our model
    return UserProfileModel.fromJson(response);
  }

  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Not authenticated');
    }

    final response = await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', user.id)
        .select()
        .single();
    
    return UserProfileModel.fromJson(response);
  }

  Future<String> uploadProfilePicture(File file) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Not authenticated');
    }

    final fileName = '${user.id}/profile.png';
    await _client.storage.from('avatars').upload(
          fileName,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
        
    final imageUrl = _client.storage.from('avatars').getPublicUrl(fileName);
    
    // Update the profile_picture_url in the profiles table
    await _client.from('profiles').update({'profile_picture_url': imageUrl}).eq('id', user.id);

    return imageUrl;
  }
}

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  // Use the actual Supabase client
  return UserProfileService(SupabaseService.client);
});