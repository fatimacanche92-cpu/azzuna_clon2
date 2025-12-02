import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/features/customer_tracking/domain/ai_recommendation.dart';
import 'package:flutter_app/features/customer_tracking/domain/customer_event.dart';
import 'package:flutter_app/features/customer_tracking/presentation/providers/customer_tracking_providers.dart';
import 'package:intl/intl.dart';

class CustomerEventCard extends ConsumerWidget {
  final CustomerEvent event;

  const CustomerEventCard({super.key, required this.event});

  void _onSelected(BuildContext context, WidgetRef ref, String value) {
    if (value == 'edit') {
      context.go('/customer-tracking/edit-event', extra: event);
    } else if (value == 'delete') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar este evento?',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Eliminar'),
                onPressed: () {
                  ref
                      .read(customerTrackingNotifierProvider.notifier)
                      .deleteEvent(event.id);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _shareToWhatsApp(String message, String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final url = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timeDiff = event.eventDate.difference(DateTime.now());
    final daysUntil = timeDiff.inDays + 1;

    AIRecommendation? recommendation;
    if (daysUntil >= 3 && daysUntil <= 7) {
      recommendation = AIRecommendationService.generateRecommendation(
        event.eventType,
                                event.clientName ?? '',      );
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.clientName ?? '',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _onSelected(context, ref, value),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Editar evento'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Eliminar evento'),
                            ),
                          ],
                      icon: Icon(Icons.more_vert, color: theme.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.phone,
                  event.clientPhone ?? 'No disponible',
                  theme,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.calendar_today,
                  '${_capitalize(event.eventType)}: ${DateFormat.yMMMd('es_ES').format(event.eventDate)}',
                  theme,
                ),
                const SizedBox(height: 4),
                if (daysUntil > 0)
                  _buildInfoRow(
                    Icons.timelapse,
                    'Próximo en $daysUntil días',
                    theme,
                  ),
                const SizedBox(height: 12),
                _buildLastPurchaseInfo(theme),
              ],
            ),
          ),
          if (recommendation != null)
            _buildRecommendationSection(recommendation, theme),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection(
    AIRecommendation recommendation,
    ThemeData theme,
  ) {
    return Container(
      color: theme.primaryColor.withOpacity(0.15),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Sugerencia Inteligente',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"'
            '${recommendation.suggestedMessage}'
            '"',
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Ramo sugerido: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: recommendation.suggestedBouquet),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Color: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: recommendation.suggestedColor),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _shareToWhatsApp(
                recommendation.suggestedMessage,
                event.clientPhone,
              ),
              icon: const Icon(Icons.share, size: 16),
              label: const Text('Compartir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.primaryColor.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildLastPurchaseInfo(ThemeData theme) {
    return Text(
      'Última compra: Ramo de Girasoles (hace 2 meses)', // Placeholder
      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
