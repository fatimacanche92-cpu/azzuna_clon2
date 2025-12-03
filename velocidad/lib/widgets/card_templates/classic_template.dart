import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'template_base.dart';

class ClassicTemplate extends CardTemplateBase {
  const ClassicTemplate({
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
            const Color(0xFFF5F5F0),
            Colors.white,
            cardData.primaryColor.withOpacity(0.05),
            const Color(0xFFF5F5F0),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        border: Border.all(
          color: cardData.primaryColor.withOpacity(0.4),
          width: 3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            // Borde decorativo superior
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cardData.primaryColor,
                    cardData.secondaryColor,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Contenido central
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decoración floral
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          cardData.primaryColor.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: cardData.primaryColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cardData.primaryColor.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Text(
                      '🌺',
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Nombre
                  if (cardData.recipientName.isNotEmpty)
                    Text(
                      cardData.recipientName,
                      style: GoogleFonts.merriweather(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: cardData.primaryColor,
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Línea decorativa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 1,
                        color: cardData.primaryColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '✿',
                          style: TextStyle(
                            color: cardData.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 1,
                        color: cardData.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Mensaje
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        cardData.message,
                        style: GoogleFonts.merriweather(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.8,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Remitente
                  if (cardData.senderName.isNotEmpty)
                    Text(
                      'Con amor,\n${cardData.senderName}',
                      style: GoogleFonts.merriweather(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Borde decorativo inferior
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cardData.primaryColor,
                    cardData.secondaryColor,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

