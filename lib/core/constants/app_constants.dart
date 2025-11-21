/// Constantes de la aplicación
class AppConstants {
  // API
  static const String apiTimeout = 'API_TIMEOUT';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  // Routes
  static const String loginRoute = '/';
  static const String registerRoute = '/register';
  static const String welcomeRoute = '/welcome';
  static const String homeRoute = '/home';
  static const String emailVerificationRoute = '/email-verification';
  static const String profileRoute = '/profile';
  static const String notificationsRoute = '/notifications';
  static const String languageRoute = '/language';
  static const String photoEditorRoute = '/photo-editor';
  static const String calendarRoute = '/calendar';
  static const String galleryRoute = '/gallery';
  static const String draftsRoute = '/drafts';
  static const String catalogsRoute = '/catalogs';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
