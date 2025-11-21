import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_model.freezed.dart';
part 'address_model.g.dart';

@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({
    required String id,
    required String name, // e.g., "Casa", "Oficina"
    required String fullAddress,
    required String city,
    required String state,
    required String zipCode,
    @Default(false) bool isDefault,
  }) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) => _$AddressModelFromJson(json);
}
