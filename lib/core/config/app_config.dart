import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de la aplicación
class AppConfig {
  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // App
  static String get appName => dotenv.env['APP_NAME'] ?? 'Flutter App';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  /// Verifica que todas las variables de entorno requeridas estén configuradas
  static bool validateConfig() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      return false;
    }
    return true;
  }
}
