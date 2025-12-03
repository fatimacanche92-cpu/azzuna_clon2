import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'template_base.dart';
import 'background_helper.dart';

class RomanticTemplate extends CardTemplateBase {
  const RomanticTemplate({
    super.key,
    required super.cardData,
    super.width,
    super.height,
  });

  @override
  Widget buildCard(BuildContext context) {
    return Stack(
      children: [
        // Fondo (gradiente o imagen generada)
        BackgroundHelper.buildBackground(
          cardData: cardData,
          gradientBuilder: () => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cardData.primaryColor,
                  cardData.secondaryColor,
                  cardData.primaryColor.withOpacity(0.9),
                  cardData.secondaryColor.withOpacity(0.8),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
            child: CustomPaint(
              painter: RomanticPatternPainter(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ),
        // Contenido
        Stack(
        children: [
          // Decoraciones de fondo
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Icono de flor con efecto brillante
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Text(
                    '🌹',
                    style: TextStyle(fontSize: 70),
                  ),
                ),
                const SizedBox(height: 30),
                // Nombre del destinatario
                if (cardData.recipientName.isNotEmpty)
                  Text(
                    'Para ${cardData.recipientName}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(height: 20),
                // Mensaje
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        cardData.message,
                        style: GoogleFonts.dancingScript(
                          fontSize: 18,
                          color: Colors.white,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Nombre del remitente
                if (cardData.senderName.isNotEmpty)
                  Text(
                    'Con cariño,\n${cardData.senderName}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
      ],
    );
  }
}

class RomanticPatternPainter extends CustomPainter {
  final Color color;

  RomanticPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Dibujar corazones decorativos
    for (int i = 0; i < 8; i++) {
      final x = (i * size.width / 7);
      final y = size.height * 0.2 + (i % 2) * 50;
      _drawHeart(canvas, Offset(x, y), 15, paint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.2,
      center.dx - size, center.dy + size * 0.1,
      center.dx, center.dy + size * 0.5,
    );
    path.cubicTo(
      center.dx + size, center.dy + size * 0.1,
      center.dx + size * 0.5, center.dy - size * 0.2,
      center.dx, center.dy + size * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

