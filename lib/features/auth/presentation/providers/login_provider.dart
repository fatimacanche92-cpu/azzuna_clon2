import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Estado del login
class LoginState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  LoginState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Provider del login
class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Guardar credenciales si "Recordarme" está activado
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            AppConstants.authTokenKey,
            response.session?.accessToken ?? '',
          );
          await prefs.setString(AppConstants.userIdKey, response.user!.id);
        }

        state = state.copyWith(isLoading: false, isSuccess: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al iniciar sesión. Por favor intenta de nuevo.',
        );
      }
    } catch (e) {
      String errorMessage = 'Error al iniciar sesión';
      final errorString = e.toString();

      // Debug: imprimir el error completo
      // print('Error de login: $errorString');

      if (errorString.contains('Invalid login credentials') ||
          errorString.contains('invalid_credentials') ||
          errorString.contains('Invalid credentials')) {
        errorMessage = 'Correo o contraseña incorrectos';
      } else if (errorString.contains('Email not confirmed') ||
          errorString.contains('email_not_confirmed') ||
          errorString.contains('email_not_verified')) {
        errorMessage = 'email_not_verified';
      } else if (errorString.contains('network') ||
          errorString.contains('Network') ||
          errorString.contains('connection')) {
        errorMessage = 'Error de conexión. Verifica tu internet';
      } else if (errorString.contains('User not found')) {
        errorMessage = 'Usuario no encontrado. Verifica tu correo electrónico';
      } else {
        // Mostrar el error real para debugging
        errorMessage = 'Error: ${e.toString().split(':').last.trim()}';
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

/// Provider del login
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(),
);
