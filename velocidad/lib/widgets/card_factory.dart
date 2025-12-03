import 'package:flutter/material.dart';
import '../models/card_data.dart';
import 'card_templates/template_base.dart';
import 'card_templates/romantic_template.dart';
import 'card_templates/elegant_template.dart';
import 'card_templates/modern_template.dart';
import 'card_templates/classic_template.dart';
import 'card_templates/spring_template.dart';
import 'card_templates/wedding_template.dart';

class CardFactory {
  static CardTemplateBase createCard({
    required CardData cardData,
    double? width,
    double? height,
  }) {
    switch (cardData.template) {
      case CardTemplate.romantic:
        return RomanticTemplate(
          cardData: cardData,
          width: width,
          height: height,
        );
      case CardTemplate.elegant:
        return ElegantTemplate(
          cardData: cardData,
          width: width,
          height: height,
        );
      case CardTemplate.modern:
        return ModernTemplate(
          cardData: cardData,
          width: width,
          height: height,
        );
      case CardTemplate.classic:
        return ClassicTemplate(
          cardData: cardData,
          width: width,
          height: height,
        );
      case CardTemplate.spring:
        return SpringTemplate(
          cardData: cardData,
          width: width,
          height: height,
        );
      case CardTemplate.wedding:
        return WeddingTemplate(
          cardData: cardData,
          width: width,
          height: height,
        );
    }
  }

  static String getTemplateName(CardTemplate template) {
    switch (template) {
      case CardTemplate.romantic:
        return 'Romántica';
      case CardTemplate.elegant:
        return 'Elegante';
      case CardTemplate.modern:
        return 'Moderna';
      case CardTemplate.classic:
        return 'Clásica';
      case CardTemplate.spring:
        return 'Primaveral';
      case CardTemplate.wedding:
        return 'Boda';
    }
  }
}

