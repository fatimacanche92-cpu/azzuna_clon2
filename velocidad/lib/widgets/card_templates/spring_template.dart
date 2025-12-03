import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'template_base.dart';

class SpringTemplate extends CardTemplateBase {
  const SpringTemplate({
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
            cardData.primaryColor.withOpacity(0.15),
            Colors.white,
            cardData.secondaryColor.withOpacity(0.15),
            const Color(0xFFE8F5E9),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decoraciones de flores de fondo
          Positioned(
            top: 20,
            left: 20,
            child: Opacity(
              opacity: 0.3,
              child: const Text(
                '🌼',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 30,
            child: Opacity(
              opacity: 0.3,
              child: const Text(
                '🌷',
                style: TextStyle(fontSize: 35),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 30,
            child: Opacity(
              opacity: 0.3,
              child: const Text(
                '🌸',
                style: TextStyle(fontSize: 45),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 20,
            child: Opacity(
              opacity: 0.3,
              child: const Text(
                '🌻',
                style: TextStyle(fontSize: 38),
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flor principal
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        cardData.primaryColor.withOpacity(0.3),
                        cardData.secondaryColor.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cardData.primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Text(
                    '🌺',
                    style: TextStyle(fontSize: 70),
                  ),
                ),
                const SizedBox(height: 30),
                // Nombre
                if (cardData.recipientName.isNotEmpty)
                  Text(
                    cardData.recipientName,
                    style: GoogleFonts.comfortaa(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cardData.primaryColor,
                    ),
                  ),
                const SizedBox(height: 25),
                // Mensaje
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    cardData.message,
                    style: GoogleFonts.comfortaa(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 25),
                // Remitente
                if (cardData.senderName.isNotEmpty)
                  Text(
                    'Con cariño, ${cardData.senderName}',
                    style: GoogleFonts.comfortaa(
                      fontSize: 15,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
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

