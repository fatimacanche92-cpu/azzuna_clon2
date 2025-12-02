import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/login_provider.dart';

/// Formulario de inicio de sesión
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      await ref
          .read(loginProvider.notifier)
          .login(email: email, password: password, rememberMe: _rememberMe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final theme = Theme.of(context);

    // Listener para manejar la navegación y los dialogs sin interferir con el build
    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.isSuccess) {
        // Usar go_router para navegar. 'go' reemplaza el stack, ideal para post-login.
        context.go(AppConstants.welcomeRoute);
        ref.read(loginProvider.notifier).resetSuccess();
      }
      if (next.error == 'email_not_verified') {
        // Usar go_router para navegar, pasando el email como 'extra'.
        context.push(
          AppConstants.emailVerificationRoute,
          extra: _emailController.text.trim(),
        );
        ref.read(loginProvider.notifier).clearError();
      }
    });

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo de email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'tu@email.com',
              prefixIcon: Icon(Icons.email_outlined, color: theme.hintColor),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo electrónico';
              }
              if (!value.contains('@')) {
                return 'Ingresa un correo electrónico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Campo de contraseña
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outlined, color: theme.hintColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: theme.hintColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Recordarme toggle
          Row(
            children: [
              SizedBox(
                width: 48,
                height: 32,
                child: Switch(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value;
                    });
                  },
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text('Recordarme', style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 24),

          // Botón de iniciar sesión
          ElevatedButton(
            onPressed: loginState.isLoading ? null : _handleLogin,
            child: loginState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
          const SizedBox(height: 16),

          // Link de olvidé mi contraseña
          TextButton(
            onPressed: () {
              context.push('/forgot-password');
            },
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Link para ir a registro
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '¿No tienes una cuenta? ',
                style: TextStyle(fontSize: 14, color: theme.hintColor),
              ),
              GestureDetector(
                onTap: () {
                  // Usar go_router para navegar
                  context.push(AppConstants.registerRoute);
                },
                child: Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          // Mostrar errores
          if (loginState.error != null &&
              loginState.error != 'email_not_verified')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  loginState.error!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
