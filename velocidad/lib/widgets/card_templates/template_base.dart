import 'package:flutter/material.dart';
import '../../models/card_data.dart';

abstract class CardTemplateBase extends StatelessWidget {
  final CardData cardData;
  final double? width;
  final double? height;

  const CardTemplateBase({
    super.key,
    required this.cardData,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular dimensiones responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;
    
    // En móvil: usar ancho completo menos padding, mantener proporción
    // En desktop: usar dimensiones proporcionadas o las especificadas
    final cardWidth = width ?? (isMobile 
        ? screenWidth - 32  // Ancho completo menos padding
        : 400);
    final cardHeight = height ?? (isMobile
        ? cardWidth * 1.5  // Proporción 2:3 para tarjeta vertical
        : 600);
    
    return Container(
      width: cardWidth,
      height: cardHeight,
      constraints: BoxConstraints(
        maxWidth: isMobile ? double.infinity : 500,
        maxHeight: isMobile ? screenHeight * 0.7 : 700,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: isMobile ? 15 : 20,
            offset: Offset(0, isMobile ? 5 : 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: buildCard(context),
      ),
    );
  }

  Widget buildCard(BuildContext context);
}

