import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'template_base.dart';

class WeddingTemplate extends CardTemplateBase {
  const WeddingTemplate({
    super.key,
    required super.cardData,
    super.width,
    super.height,
  });

  @override
  Widget buildCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            cardData.primaryColor.withOpacity(0.08),
            const Color(0xFFFFF8F0),
            cardData.secondaryColor.withOpacity(0.08),
            Colors.white,
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decoraciones doradas
          Positioned.fill(
            child: CustomPaint(
              painter: WeddingPatternPainter(
                color: const Color(0xFFFFD700).withOpacity(0.1),
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Corona de flores
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🌿',
                      style: TextStyle(fontSize: 30, color: Colors.green[300]),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '💐',
                      style: TextStyle(fontSize: 50),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '🌿',
                      style: TextStyle(fontSize: 30, color: Colors.green[300]),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Nombre
                if (cardData.recipientName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cardData.primaryColor.withOpacity(0.1),
                            cardData.secondaryColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        cardData.recipientName,
                        style: GoogleFonts.greatVibes(
                          fontSize: 40,
                          color: const Color(0xFF8B4513),
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 25),
                // Línea decorativa
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFFFFD700),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        '💍',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFFFFD700),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // Mensaje
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      cardData.message,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        color: const Color(0xFF8B4513),
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // Remitente
                if (cardData.senderName.isNotEmpty)
                  Text(
                    'Con nuestros mejores deseos,\n${cardData.senderName}',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      color: const Color(0xFF8B4513),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
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

class WeddingPatternPainter extends CustomPainter {
  final Color color;

  WeddingPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Patrón de corazones pequeños
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 12; j++) {
        if ((i + j) % 3 == 0) {
          canvas.drawCircle(
            Offset(i * size.width / 7, j * size.height / 11),
            2,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

