import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address_model.dart';
import 'dart:math';

class AddressService {
  // Mock data
  final List<AddressModel> _addresses = [
    AddressModel(
      id: '1',
      name: 'Casa',
      fullAddress: 'Av. Siempre Viva 123, Col. Springfield',
      city: 'Ciudad de México',
      state: 'CDMX',
      zipCode: '12345',
      isDefault: true,
    ),
    AddressModel(
      id: '2',
      name: 'Oficina',
      fullAddress: 'Blvd. de los Sueños Rotos 456',
      city: 'Guadalajara',
      state: 'Jalisco',
      zipCode: '67890',
    ),
  ];

  Future<List<AddressModel>> getAddresses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _addresses;
  }

  Future<void> addAddress(AddressModel address) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newAddress = address.copyWith(id: Random().nextInt(1000).toString());
    _addresses.add(newAddress);
  }

  Future<void> updateAddress(AddressModel address) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      _addresses[index] = address;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _addresses.removeWhere((a) => a.id == addressId);
  }

  Future<void> setDefaultAddress(String addressId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final currentDefault = _addresses.indexWhere((a) => a.isDefault);
    if (currentDefault != -1) {
      _addresses[currentDefault] = _addresses[currentDefault].copyWith(
        isDefault: false,
      );
    }
    final newDefault = _addresses.indexWhere((a) => a.id == addressId);
    if (newDefault != -1) {
      _addresses[newDefault] = _addresses[newDefault].copyWith(isDefault: true);
    }
  }
}

final addressServiceProvider = Provider<AddressService>((ref) {
  return AddressService();
});
