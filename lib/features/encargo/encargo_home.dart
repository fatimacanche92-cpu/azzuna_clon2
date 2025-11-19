import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/services/encargo_service.dart';

class EncargoHomeScreen extends ConsumerWidget {
  const EncargoHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final encargo = ref.watch(encargoServiceProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Crear Encargo'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement final save/summary logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Encargo consolidado (simulación)')),
              );
              // ref.read(encargoServiceProvider.notifier).resetEncargo();
            },
            child: const Text('Finalizar'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _EncargoStepCard(
              title: '1. Arreglo',
              subtitle: 'Define el tamaño, color y flores.',
              isCompleted: encargo.isArregloCompleted,
              onTap: () => context.push('/encargo/arreglo'),
            ),
            const SizedBox(height: 16),
            _EncargoStepCard(
              title: '2. Entrega',
              subtitle: 'Elige el método y datos de entrega.',
              isCompleted: encargo.isEntregaCompleted,
              onTap: () => context.push('/encargo/entrega'),
            ),
            const SizedBox(height: 16),
            _EncargoStepCard(
              title: '3. Pago',
              subtitle: 'Selecciona el método de pago.',
              isCompleted: encargo.isPagoCompleted,
              onTap: () => context.push('/encargo/pago'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EncargoStepCard extends StatelessWidget {
  const _EncargoStepCard({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text(title, style: theme.textTheme.titleLarge),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}