import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/customer_tracking/data/customer_tracking_repository_impl.dart';
import 'package:flutter_app/features/customer_tracking/domain/customer_tracking_repository.dart';
import 'package:flutter_app/features/customer_tracking/domain/customer_event.dart';

// Provider for the CustomerTrackingRepository implementation
final customerTrackingRepositoryProvider = Provider<CustomerTrackingRepository>((ref) {
  return CustomerTrackingRepositoryImpl();
});

// 1. State Definition
class CustomerTrackingState extends Equatable {
  final bool isLoading;
  final List<CustomerEvent> events;
  final String? errorMessage;

  const CustomerTrackingState({
    this.isLoading = false,
    this.events = const [],
    this.errorMessage,
  });

  CustomerTrackingState copyWith({
    bool? isLoading,
    List<CustomerEvent>? events,
    String? errorMessage,
  }) {
    return CustomerTrackingState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, events, errorMessage];
}

// 2. Notifier Definition
class CustomerTrackingNotifier extends StateNotifier<CustomerTrackingState> {
  final CustomerTrackingRepository _repository;

  CustomerTrackingNotifier(this._repository) : super(const CustomerTrackingState()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final events = await _repository.getCustomerEvents();
      state = state.copyWith(isLoading: false, events: events);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load events: ${e.toString()}');
    }
  }

  Future<bool> addEvent(CustomerEvent event) async {
    try {
      await _repository.addCustomerEvent(event);
      await loadEvents();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to add event: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateEvent(CustomerEvent event) async {
    try {
      await _repository.updateCustomerEvent(event);
      await loadEvents();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update event: ${e.toString()}');
      return false;
    }
  }
  
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _repository.deleteCustomerEvent(eventId);
      await loadEvents();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete event: ${e.toString()}');
      return false;
    }
  }
}

// 3. Provider for the Notifier
final customerTrackingNotifierProvider = StateNotifierProvider<CustomerTrackingNotifier, CustomerTrackingState>((ref) {
  final repository = ref.watch(customerTrackingRepositoryProvider);
  return CustomerTrackingNotifier(repository);
});
