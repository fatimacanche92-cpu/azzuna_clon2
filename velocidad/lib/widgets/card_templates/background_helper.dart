import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/card_data.dart';

class BackgroundHelper {
  /// Crea un widget de fondo que puede ser gradiente o imagen generada
  /// Mejorado para ser más flexible y compatible con todos los templates
  static Widget buildBackground({
    required CardData cardData,
    required Widget Function() gradientBuilder,
    double? imageOpacity, // Opacidad personalizada de la imagen (0.0 - 1.0)
    double? overlayOpacity, // Opacidad del overlay de colores (0.0 - 1.0)
    BlendMode? blendMode, // Modo de mezcla personalizado
  }) {
    if (cardData.useAIGeneratedBackground && cardData.backgroundImageUrl != null) {
      try {
        // Valores por defecto flexibles que funcionan bien con todos los templates
        final effectiveImageOpacity = imageOpacity ?? 0.75; // Menos opaco para mejor legibilidad
        final effectiveOverlayOpacity = overlayOpacity ?? 0.25; // Overlay más sutil
        final effectiveBlendMode = blendMode ?? BlendMode.softLight; // Mejor para fondos
        
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(cardData.backgroundImageUrl!)),
              fit: BoxFit.cover,
              // Aplicar opacidad a la imagen base
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(effectiveImageOpacity),
                effectiveBlendMode,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              // Overlay de gradiente más sutil para mantener los colores del template
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cardData.primaryColor.withOpacity(effectiveOverlayOpacity),
                  cardData.secondaryColor.withOpacity(effectiveOverlayOpacity * 0.7),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        // Si hay error cargando la imagen, usar gradiente
        print('Error cargando imagen de fondo: $e');
        return gradientBuilder();
      }
    }
    return gradientBuilder();
  }
  
  /// Versión simplificada con valores por defecto optimizados
  static Widget buildBackgroundSimple({
    required CardData cardData,
    required Widget Function() gradientBuilder,
  }) {
    return buildBackground(
      cardData: cardData,
      gradientBuilder: gradientBuilder,
    );
  }
}

