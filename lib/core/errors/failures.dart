import 'package:equatable/equatable.dart';

/// Clase base para errores de la aplicación
abstract class Failure extends Equatable {
  const Failure([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Error de servidor
class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

/// Error de conexión
class ConnectionFailure extends Failure {
  const ConnectionFailure([super.message]);
}

/// Error de autenticación
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message]);
}

/// Error de autorización
class AuthorizationFailure extends Failure {
  const AuthorizationFailure([super.message]);
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure([super.message]);
}

/// Error desconocido
class UnknownFailure extends Failure {
  const UnknownFailure([super.message]);
}
