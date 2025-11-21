import 'dart:io'; // Import for File
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile_model.dart';
import '../../services/user_profile_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileState {
  final UserProfileModel? profile;
  final bool isLoading;
  final String? error;
  final bool notificationsEnabled; // Add this

  ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.notificationsEnabled = false, // Default value
  });

  ProfileState copyWith({
    UserProfileModel? profile,
    bool? isLoading,
    String? error,
    bool? notificationsEnabled,
  }) {
    final newNotificationsEnabled = notificationsEnabled ?? this.notificationsEnabled;

    return ProfileState(
      profile: profile ?? this.profile?.copyWith(notificationsEnabled: newNotificationsEnabled),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      notificationsEnabled: newNotificationsEnabled,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final UserProfileService _profileService;

  ProfileNotifier(this._profileService) : super(ProfileState()) {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _profileService.getUserProfile();
      state = state.copyWith(profile: profile, isLoading: false, notificationsEnabled: profile.notificationsEnabled);
    } catch (e, s) {
      // ignore: avoid_print
      print('ERROR loading user profile: $e');
      // ignore: avoid_print
      print('Stack trace: $s');
      state = state.copyWith(error: e.toString(), isLoading: false, notificationsEnabled: false);
    }
  }

  Future<void> updateUserProfile(UserProfileModel profile) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedProfile = await _profileService.updateUserProfile(profile);
      state = state.copyWith(profile: updatedProfile, isLoading: false, notificationsEnabled: updatedProfile.notificationsEnabled);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateProfilePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        state = state.copyWith(isLoading: true);
        // First, update UI with local path for immediate feedback
        final tempProfile = state.profile!.copyWith(profilePicturePath: pickedFile.path, profilePictureUrl: null);
        state = state.copyWith(profile: tempProfile);

        // Then, upload the file and get the permanent URL
        final newImageUrl = await _profileService.uploadProfilePicture(File(pickedFile.path));
        
        // Final state update with the network URL
        final finalProfile = state.profile!.copyWith(profilePictureUrl: newImageUrl, profilePicturePath: null);
        state = state.copyWith(profile: finalProfile, isLoading: false);

      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void toggleNotifications(bool isEnabled) {
    if (state.profile != null) {
      final updatedProfile = state.profile!.copyWith(notificationsEnabled: isEnabled);
      state = state.copyWith(notificationsEnabled: isEnabled); // Also update ProfileState's own property
      updateUserProfile(updatedProfile); // This will update the profile in the service and then re-set the state
    }
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final profileService = ref.watch(userProfileServiceProvider);
  return ProfileNotifier(profileService);
});
