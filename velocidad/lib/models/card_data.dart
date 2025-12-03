import 'package:flutter/material.dart';

enum CardTemplate {
  romantic,
  elegant,
  modern,
  classic,
  spring,
  wedding,
}

enum SpecialOccasion {
  none,
  valentines,
  mothersDay,
  birthday,
  wedding,
  anniversary,
  graduation,
  sympathy,
  congratulations,
  thankYou,
  christmas,
  newYear,
  easter,
  halloween,
}

class CardData {
  String recipientName;
  String message;
  String senderName;
  CardTemplate template;
  SpecialOccasion occasion;
  Color primaryColor;
  Color secondaryColor;
  DateTime? occasionDate;
  String customMessage;
  String? backgroundImageUrl;
  bool useAIGeneratedBackground;
  String customBackgroundPrompt; // Prompt personalizado para el fondo

  CardData({
    this.recipientName = '',
    this.message = '',
    this.senderName = '',
    this.template = CardTemplate.romantic,
    this.occasion = SpecialOccasion.none,
    Color? primaryColor,
    Color? secondaryColor,
    this.occasionDate,
    this.customMessage = '',
    this.backgroundImageUrl,
    this.useAIGeneratedBackground = false,
    this.customBackgroundPrompt = '',
  })  : primaryColor = primaryColor ?? const Color(0xFF8B5CF6),
        secondaryColor = secondaryColor ?? const Color(0xFFEC4899);

  CardData copyWith({
    String? recipientName,
    String? message,
    String? senderName,
    CardTemplate? template,
    SpecialOccasion? occasion,
    Color? primaryColor,
    Color? secondaryColor,
    DateTime? occasionDate,
    String? customMessage,
    String? backgroundImageUrl,
    bool? useAIGeneratedBackground,
    String? customBackgroundPrompt,
  }) {
    return CardData(
      recipientName: recipientName ?? this.recipientName,
      message: message ?? this.message,
      senderName: senderName ?? this.senderName,
      template: template ?? this.template,
      occasion: occasion ?? this.occasion,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      occasionDate: occasionDate ?? this.occasionDate,
      customMessage: customMessage ?? this.customMessage,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      useAIGeneratedBackground: useAIGeneratedBackground ?? this.useAIGeneratedBackground,
      customBackgroundPrompt: customBackgroundPrompt ?? this.customBackgroundPrompt,
    );
  }
}

