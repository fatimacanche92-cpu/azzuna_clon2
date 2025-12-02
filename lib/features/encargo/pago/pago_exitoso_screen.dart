import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PagoExitosoScreen extends StatelessWidget {
  final String? deliveryType; // 'envio' or 'recoger'

  const PagoExitosoScreen({super.key, this.deliveryType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 32),
              Text(
                'Pagado Exitosamente',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              const SizedBox(height: 8),
              if (deliveryType != null) ...[
                ElevatedButton(
                  onPressed: () {
                    if (deliveryType == 'envio') {
                      context.go('/shipping-orders');
                    } else {
                      context.go('/pickup-orders');
                    }
                  },
                  child: const Text('Ver mi pedido'),
                ),
                const SizedBox(height: 8),
              ],
              ElevatedButton(
                onPressed: () {
                  context.go('/home');
                },
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
