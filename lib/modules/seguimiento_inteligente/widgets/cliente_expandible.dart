import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/modules/seguimiento_inteligente/seguimiento_inteligente_state.dart';

class ClienteExpandible extends StatelessWidget {
  final CrmClient client;
  const ClienteExpandible({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 24),
          _buildAiRecommendation(context, client.recommendation),
          const Divider(height: 24),
          _buildDetailRow(
            'Gasto Promedio',
            '\$${client.averageSpending.toStringAsFixed(2)}',
          ),
          _buildDetailRow('Frecuencia de Compra', client.purchaseFrequency),
          _buildDetailRow('Ocasión Favorita', client.favoriteOccasion),
          _buildDetailRow(
            'Flores Favoritas',
            client.favoriteFlowers.join(', '),
          ),
          _buildDetailRow(
            'Colores Favoritos',
            client.favoriteColors.join(', '),
          ),
          const SizedBox(height: 16),
          _buildHistorySection(
            'Historial de Compras',
            client.purchaseHistory
                .map(
                  (p) =>
                      '${p.arrangementType} - ${DateFormat.yMMMd().format(p.scheduledDate)}',
                )
                .toList(),
          ),
          _buildHistorySection(
            'Fechas Especiales',
            client.specialDates
                .map(
                  (d) =>
                      '${d.occasionName} - ${DateFormat.yMMMd().format(d.date)}',
                )
                .toList(),
          ),
          _buildHistorySection('Notas Anteriores', client.previousNotes),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  Widget _buildHistorySection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Text(
                'No hay datos',
                style: GoogleFonts.poppins(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: Text('• $item', style: GoogleFonts.poppins()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAiRecommendation(
    BuildContext context,
    AiRecommendation recommendation,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: theme.primaryColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendación Inteligente',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(recommendation.suggestion, style: GoogleFonts.poppins()),
                if (recommendation.reason.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      recommendation.reason,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
