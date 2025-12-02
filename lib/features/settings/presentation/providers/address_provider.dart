import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';

class AddressState {
  final List<AddressModel> addresses;
  final bool isLoading;
  final String? error;

  AddressState({this.addresses = const [], this.isLoading = false, this.error});

  AddressState copyWith({
    List<AddressModel>? addresses,
    bool? isLoading,
    String? error,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AddressNotifier extends StateNotifier<AddressState> {
  final AddressService _addressService;

  AddressNotifier(this._addressService) : super(AddressState()) {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true);
    try {
      final addresses = await _addressService.getAddresses();
      state = state.copyWith(addresses: addresses, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addAddress(AddressModel address) async {
    state = state.copyWith(isLoading: true);
    try {
      await _addressService.addAddress(address);
      await loadAddresses();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    state = state.copyWith(isLoading: true);
    try {
      await _addressService.updateAddress(address);
      await loadAddresses();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteAddress(String addressId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _addressService.deleteAddress(addressId);
      await loadAddresses();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _addressService.setDefaultAddress(addressId);
      await loadAddresses();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final addressNotifierProvider =
    StateNotifierProvider<AddressNotifier, AddressState>((ref) {
      final addressService = ref.watch(addressServiceProvider);
      return AddressNotifier(addressService);
    });
