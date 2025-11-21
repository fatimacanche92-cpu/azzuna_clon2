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
    } catch (e, s) {
      // ignore: avoid_print
      print('Error de login: $e');
      // ignore: avoid_print
      print('Stacktrace: $s');

      String errorMessage;
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Correo o contraseña incorrectos.';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Por favor, confirma tu correo electrónico para continuar.';
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

/// Provider del login
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(),
);
