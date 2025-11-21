import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/supabase_service.dart';

/// Estado del registro
class RegisterState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const RegisterState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  RegisterState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Provider del registro
class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier() : super(const RegisterState());

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name, // Esto es importante para el trigger de la DB
        },
      );

      if (response.user != null) {
        // Si no hay sesión, significa que el email necesita confirmación
        final needsEmailConfirmation = response.session == null;

        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          error: needsEmailConfirmation ? 'email_verification_required' : null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al crear la cuenta. Por favor intenta de nuevo.',
        );
      }
    } catch (e, s) {
      // ignore: avoid_print
      print('Error de registro: $e');
      // ignore: avoid_print
      print('Stacktrace: $s');

      String errorMessage;
      if (e.toString().contains('User already registered')) {
        errorMessage = 'Este correo electrónico ya está en uso.';
      } else if (e.toString().contains('weak_password')) {
        errorMessage = 'La contraseña es demasiado débil. Intenta con una más segura.';
      } else if (e.toString().contains('network') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'Error de red. Por favor, comprueba tu conexión a internet.';
      } else {
        errorMessage = 'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }
}

/// Provider del registro
final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) => RegisterNotifier(),
);
