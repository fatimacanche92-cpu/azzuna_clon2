import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import '../../core/errors/failures.dart';

/// Servicio para interactuar con Supabase
class SupabaseService {
  static SupabaseClient? _client;

  /// Inicializa Supabase
  static Future<void> initialize() async {
    if (!AppConfig.validateConfig()) {
      throw const ValidationFailure(
        'Las variables de entorno de Supabase no están configuradas',
      );
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  /// Obtiene el cliente de Supabase
  static SupabaseClient get client {
    if (_client == null) {
      throw const ConnectionFailure('Supabase no ha sido inicializado');
    }
    return _client!;
  }

  /// Obtiene el usuario actual
  static User? get currentUser => client.auth.currentUser;

  /// Verifica si hay un usuario autenticado
  static bool get isAuthenticated => currentUser != null;

  /// Cierra la sesión del usuario
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      // ignore: avoid_print
      print('Error al cerrar sesión: $e');
    }
  }
}
