import 'package:freezed_annotation/freezed_annotation.dart';
import 'address_model.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required String id,
    required String name,
    required String email,
    String? phone,
    String? profilePictureUrl,
    String? profilePicturePath, // New field for local path
    @Default([]) List<AddressModel> addresses,
    @Default(true) bool notificationsEnabled,
    String? shop_address,
    String? shop_hours,
    String? shop_description,
    Map<String, dynamic>? social_links,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
}
