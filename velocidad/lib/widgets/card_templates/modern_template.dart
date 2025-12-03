import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'template_base.dart';

class ModernTemplate extends CardTemplateBase {
  const ModernTemplate({
    super.key,
    required super.cardData,
    super.width,
    super.height,
  });

  @override
  Widget buildCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Fondo con gradiente vibrante
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cardData.primaryColor.withOpacity(0.15),
                  cardData.secondaryColor.withOpacity(0.15),
                  cardData.primaryColor.withOpacity(0.1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Formas geométricas decorativas
          Positioned.fill(
            child: CustomPaint(
              painter: ModernBackgroundPainter(
                primaryColor: cardData.primaryColor,
                secondaryColor: cardData.secondaryColor,
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Icono moderno con gradiente
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cardData.primaryColor.withOpacity(0.2),
                        cardData.secondaryColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cardData.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cardData.primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Text(
                    '💐',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
                const Spacer(),
                // Nombre
                if (cardData.recipientName.isNotEmpty)
                  Text(
                    cardData.recipientName,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cardData.primaryColor,
                    ),
                  ),
                const SizedBox(height: 15),
                // Mensaje
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: cardData.primaryColor,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    cardData.message,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                ),
                const Spacer(),
                // Remitente
                if (cardData.senderName.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '— ${cardData.senderName}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModernBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  ModernBackgroundPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Formas geométricas decorativas más vibrantes
    paint.color = primaryColor.withOpacity(0.12);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.15,
      paint,
    );

    paint.color = secondaryColor.withOpacity(0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.7,
          size.width * 0.3,
          size.width * 0.3,
        ),
        const Radius.circular(20),
      ),
      paint,
    );

    // Agregar más formas decorativas
    paint.color = primaryColor.withOpacity(0.08);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      size.width * 0.1,
      paint,
    );

    paint.color = secondaryColor.withOpacity(0.08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.7,
          size.height * 0.6,
          size.width * 0.2,
          size.width * 0.2,
        ),
        const Radius.circular(15),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

