import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/modules/seguimiento_inteligente/seguimiento_inteligente_state.dart';
import 'cliente_expandible.dart';

class ClienteCard extends StatefulWidget {
  final CrmClient client;

  const ClienteCard({super.key, required this.client});

  @override
  State<ClienteCard> createState() => _ClienteCardState();
}

class _ClienteCardState extends State<ClienteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  backgroundImage: widget.client.photoUrl != null
                      ? NetworkImage(widget.client.photoUrl!)
                      : null,
                  child: widget.client.photoUrl == null
                      ? Text(
                          widget.client.name.isNotEmpty
                              ? widget.client.name[0]
                              : '?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.client.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Última compra: ${DateFormat.yMMMd().format(widget.client.lastPurchaseDate)}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.client.nextSpecialDateSummary != null)
              _buildHighlightChip(
                icon: Icons.cake_outlined,
                label: widget.client.nextSpecialDateSummary!,
                color: Colors.pink,
              ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(_isExpanded ? 'Ocultar detalles' : 'Ver más'),
              ),
            ),

            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Container(),
              secondChild: ClienteExpandible(client: widget.client),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(label),
      labelStyle: GoogleFonts.poppins(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
    );
  }
}
