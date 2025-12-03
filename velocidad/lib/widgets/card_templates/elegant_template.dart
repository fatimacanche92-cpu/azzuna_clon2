import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'template_base.dart';

class ElegantTemplate extends CardTemplateBase {
  const ElegantTemplate({
    super.key,
    required super.cardData,
    super.width,
    super.height,
  });

  @override
  Widget buildCard(BuildContext context) {
    // Obtener dimensiones reales del contenedor
    final cardHeight = height ?? 
        (MediaQuery.of(context).size.width < 768 
            ? (MediaQuery.of(context).size.width - 32) * 1.5 
            : 600);
    
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header elegante
          Container(
            height: cardHeight * 0.25,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cardData.primaryColor,
                  cardData.primaryColor.withOpacity(0.8),
                  cardData.secondaryColor,
                  cardData.secondaryColor.withOpacity(0.9),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Patrón decorativo
                Positioned.fill(
                  child: CustomPaint(
                    painter: ElegantPatternPainter(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🌸',
                        style: TextStyle(fontSize: 50),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'FLORES',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (cardData.recipientName.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardData.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: cardData.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        cardData.recipientName,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: cardData.primaryColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      width: 100,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cardData.primaryColor,
                            cardData.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        cardData.message,
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (cardData.senderName.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: 60,
                      height: 2,
                      color: cardData.primaryColor,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      cardData.senderName,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElegantPatternPainter extends CustomPainter {
  final Color color;

  ElegantPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Dibujar líneas decorativas
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(i * size.width / 4, 0),
        Offset(i * size.width / 4, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

