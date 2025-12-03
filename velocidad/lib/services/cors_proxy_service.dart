/// Servicio para manejar CORS en Flutter Web
/// 
/// NOTA: Hugging Face API no permite peticiones directas desde el navegador
/// debido a políticas CORS. Para Flutter Web, necesitamos usar un proxy.
/// 
/// Opciones:
/// 1. Usar un proxy CORS público (temporal, no recomendado para producción)
/// 2. Crear tu propio backend/proxy
/// 3. Usar la app solo en Android (no tiene problema de CORS)

class CORSProxyService {
  // Proxy CORS público (solo para desarrollo/testing)
  // ⚠️ NO usar en producción - estos servicios pueden ser lentos o no confiables
  static const String _corsProxy = 'https://cors-anywhere.herokuapp.com/';
  
  // Alternativa: usar un proxy propio o backend
  // static const String _corsProxy = 'https://tu-backend.com/api/proxy/';
  
  /// Agrega el proxy a la URL si es necesario
  static String getProxiedUrl(String url) {
    // Para desarrollo web, usar proxy
    // Para Android/iOS, usar URL directa
    return url; // Por ahora, retornamos directo - necesitarás configurar un proxy
  }
  
  /// Verifica si estamos en web
  static bool get isWeb {
    try {
      return Uri.base.scheme == 'http' || Uri.base.scheme == 'https';
    } catch (e) {
      return false;
    }
  }
}

