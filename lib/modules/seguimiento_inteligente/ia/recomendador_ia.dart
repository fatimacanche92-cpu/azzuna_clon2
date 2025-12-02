import 'package:flutter_app/features/orders/domain/models/order_model.dart';
import 'package:flutter_app/modules/seguimiento_inteligente/seguimiento_inteligente_state.dart';

class AIRecommender {
  /// Analyzes a client's purchase history and personal data to generate a smart recommendation.
  /// This is a simulated AI that uses a set of business rules.
  Future<AiRecommendation> analizarCliente(
    List<OrderModel> pedidos,
    Map<String, dynamic> datosCliente,
  ) async {
    // Simulate network delay for an "AI" process
    await Future.delayed(const Duration(milliseconds: 200));

    final now = DateTime.now();

    // Rule 1: Check for important dates coming up soon.
    final List<DateTime> specialDates = datosCliente['special_dates'] ?? [];
    for (final date in specialDates) {
      final difference = date.difference(now).inDays;
      if (difference >= 0 && difference <= 3) {
        return AiRecommendation(
          suggestion: 'Sugerir envío de regalo o tarjeta pre-hecha.',
          reason:
              'Fecha especial del cliente (${date.day}/${date.month}) en ${difference + 1} día(s).',
          requiresAction: true,
        );
      }
    }

    // Rule 2: Check for purchases made around the same time last year.
    for (final order in pedidos) {
      final daysSinceOrder = now.difference(order.scheduledDate).inDays;
      // Check if order was made around this time in a previous year
      if (daysSinceOrder > 330 && daysSinceOrder < 400) {
        final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
        final orderDayOfYear = order.scheduledDate
            .difference(DateTime(order.scheduledDate.year, 1, 1))
            .inDays;

        if ((dayOfYear - orderDayOfYear).abs() < 15) {
          // Within a 15-day window year-over-year
          return AiRecommendation(
            suggestion:
                'Enviar promoción de ${order.arrangementFlowerType ?? 'flores'} esta semana.',
            reason:
                'El cliente compró un ${order.arrangementType} en esta fecha el año pasado.',
            requiresAction: true,
          );
        }
      }
    }

    // Rule 3: Detect frequent customers with no recent activity.
    if (pedidos.length > 3) {
      // A "frequent" customer
      final lastPurchase = pedidos
          .map((p) => p.scheduledDate)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      if (now.difference(lastPurchase).inDays > 120) {
        // No purchase in 4 months
        return AiRecommendation(
          suggestion: 'Contactar con una oferta especial de "te extrañamos".',
          reason: 'Cliente recurrente sin compras recientes.',
          requiresAction: false, // Or true, depending on business rules
        );
      }
    }

    // Default recommendation if no specific pattern is found
    return const AiRecommendation(
      suggestion: 'Mantener en seguimiento regular.',
      reason: 'No se detectaron patrones de acción inmediata.',
      requiresAction: false,
    );
  }
}
