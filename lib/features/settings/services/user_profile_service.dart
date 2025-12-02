import 'dart:convert';
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
    // ignore: avoid_print
    print('Supabase profile response: $response');
    return UserProfileModel.fromJson(response);
  }

  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Not authenticated');
    }

    final profileJson = profile.toJson();
    if (profile.social_links != null) {
      profileJson['social_links'] = jsonEncode(profile.social_links);
    }

    final response = await _client
        .from('profiles')
        .update(profileJson)
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

    try {
      print('Starting profile picture upload for user: ${user.id}');

      final fileName = '${user.id}/profile.png';

      // Verify bucket exists by attempting a lightweight list; if it fails, surface a clearer error
      try {
        await _client.storage.from('avatars').list();
      } catch (bucketErr) {
        print('Bucket "avatars" not accessible or does not exist: $bucketErr');
        throw Exception('Storage bucket "avatars" not available.');
      }

      // Retry upload with exponential backoff
      const int maxAttempts = 3;
      int attempt = 0;
      dynamic uploadResponse;
      while (attempt < maxAttempts) {
        attempt++;
        try {
          uploadResponse = await _client.storage
              .from('avatars')
              .upload(
                fileName,
                file,
                fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
              );
          print('Upload response (attempt $attempt): $uploadResponse');
          break;
        } catch (uploadErr) {
          print('Upload attempt $attempt failed: $uploadErr');
          if (attempt >= maxAttempts) {
            rethrow;
          }
          // wait before retrying
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }

      // Get the public URL
      final imageUrl = _client.storage.from('avatars').getPublicUrl(fileName);
      print('Public URL: $imageUrl');

      // Update the profile picture URL in the database
      try {
        final updateResponse = await _client
            .from('profiles')
            .update({'avatar_url': imageUrl})
            .eq('id', user.id)
            .select();
        print('Profile update response: $updateResponse');
      } catch (dbError) {
        print('Warning: Could not update database with image URL: $dbError');
        // Continue anyway, the image is still uploaded to storage
      }

      return imageUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  // Use the actual Supabase client
  return UserProfileService(SupabaseService.client);
});
