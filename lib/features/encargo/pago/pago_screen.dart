import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/models/pago_model.dart';
import 'package:flutter_app/core/models/arreglo_model.dart';
import 'package:flutter_app/core/services/encargo_service.dart';
import 'package:flutter_app/features/orders/presentation/providers/order_provider.dart';

class PagoScreen extends ConsumerStatefulWidget {
  const PagoScreen({super.key});

  @override
  ConsumerState<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends ConsumerState<PagoScreen> {
  PaymentMethod? _paymentMethod;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(encargoServiceProvider).pago;
    if (existing != null) {
      _paymentMethod = existing.paymentMethod;
    }
  }

  void _onSave() {
    if (_paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un método de pago'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Procesando pedido...'),
        duration: Duration(seconds: 3),
      ),
    );

    // Use dynamic price stored in the UI (based on selected arreglo)
    final encargo = ref.watch(encargoServiceProvider);
    final arreglo = encargo.arreglo;

    double _computeBasePrice() {
      switch (arreglo?.size) {
        case ArregloSize.p:
          return 500.0;
        case ArregloSize.m:
          return 750.0;
        case ArregloSize.g:
          return 1000.0;
        case ArregloSize.eg:
          return 1500.0;
        default:
          return 750.0;
      }
    }

    double _computeShipping() {
      final colorsCount = arreglo?.colors.length ?? 0;
      final base = 50.0 + (colorsCount * 10);
      return base.clamp(50.0, 200.0);
    }

    final basePrice = encargo.pago?.basePrice ?? _computeBasePrice();
    final shippingCost = encargo.pago?.shippingCost ?? _computeShipping();
    final total = basePrice + shippingCost;

    final newPago = Pago(
      paymentMethod: _paymentMethod,
      basePrice: basePrice,
      shippingCost: shippingCost,
    );
    ref.read(encargoServiceProvider.notifier).updatePago(newPago);
    
    // Save the encargo to Supabase
    ref.read(encargoServiceProvider.notifier).saveEncargo().then((success) {
      if (success && mounted) {
        print('Order saved successfully, invalidating provider');
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Pedido completado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Invalidate the orders provider to refresh the list
        ref.invalidate(allOrdersProvider);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) context.go('/encargo/pago-exitoso');
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✗ Error al guardar el pedido. Intenta de nuevo.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      print('Error saving order: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final encargo = ref.watch(encargoServiceProvider);
    final arreglo = encargo.arreglo;
    const price = 750.0; // Hardcoded price
    const shippingCost = 100.0; // Hardcoded shipping
    const total = price + shippingCost;

    return Scaffold(
      appBar: AppBar(title: const Text('Paso 4: Pago')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen del Cobro
          Text(
            'Resumen del Cobro',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(
                    'Arreglo',
                    arreglo?.flowerType ?? 'No seleccionado',
                  ),
                  _buildSummaryRow(
                    'Tamaño',
                    arreglo?.size?.name.toUpperCase() ?? 'N/A',
                  ),
                  _buildSummaryRow(
                    'Colores',
                    arreglo?.colors.join(', ') ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow('Precio', '\$${price.toStringAsFixed(2)}'),
                  _buildSummaryRow(
                    'Costo de Envío',
                    '\$${shippingCost.toStringAsFixed(2)}',
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Total',
                    '\$${total.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Métodos de Pago
          Text(
            'Métodos de Pago',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          RadioListTile<PaymentMethod>(
            title: const Text('Mastercard'),
            value: PaymentMethod.mastercard,
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v),
          ),
          RadioListTile<PaymentMethod>(
            title: const Text('Visa'),
            value: PaymentMethod.visa,
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v),
          ),
          RadioListTile<PaymentMethod>(
            title: const Text('PayPal'),
            value: PaymentMethod.paypal,
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _onSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Confirmar Pago'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      fontSize: isTotal ? 18 : 16,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
