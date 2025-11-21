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
    } catch (e) {
      String errorMessage = 'Error al crear la cuenta';
      final errorString = e.toString();

      // Debug: imprimir el error completo
      // print('Error de registro: $errorString');

      if (errorString.contains('User already registered') ||
          errorString.contains('already_registered') ||
          errorString.contains('already exists')) {
        errorMessage = 'Este correo electrónico ya está registrado';
      } else if (errorString.contains('Password') ||
          errorString.contains('password')) {
        errorMessage = 'La contraseña no cumple con los requisitos';
      } else if (errorString.contains('Email') ||
          errorString.contains('email')) {
        errorMessage = 'El correo electrónico no es válido';
      } else if (errorString.contains('network') ||
          errorString.contains('Network') ||
          errorString.contains('connection')) {
        errorMessage = 'Error de conexión. Verifica tu internet';
      } else {
        // Mostrar el error real para debugging
        errorMessage = 'Error: ${errorString.split(':').last.trim()}';
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
