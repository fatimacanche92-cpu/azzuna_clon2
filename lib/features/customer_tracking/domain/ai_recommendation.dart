// lib/features/customer_tracking/domain/ai_recommendation.dart

// 1. Recommendation data model
class AIRecommendation {
  final String suggestedMessage;
  final String suggestedBouquet;
  final String suggestedColor;

  AIRecommendation({
    required this.suggestedMessage,
    required this.suggestedBouquet,
    required this.suggestedColor,
  });
}

// 2. Simulated AI Service
class AIRecommendationService {
  static AIRecommendation? generateRecommendation(String eventType, String clientName) {
    switch (eventType) {
      case 'aniversario':
        return AIRecommendation(
          suggestedMessage: 'Tu cliente $clientName celebrará su aniversario. ¡Sorpréndelo!',
          suggestedBouquet: 'Rosas rojas o arreglos románticos',
          suggestedColor: 'Rojo',
        );
      case 'cumpleaños':
        return AIRecommendation(
          suggestedMessage: 'El cumpleaños de $clientName se acerca. ¡Es hora de celebrar!',
          suggestedBouquet: 'Arreglos coloridos y vibrantes',
          suggestedColor: 'Variado',
        );
      case 'navidad':
        return AIRecommendation(
          suggestedMessage: '$clientName suele comprar en Navidad. Envíale tus promociones de temporada.',
          suggestedBouquet: 'Arreglos con pinos y nochebuenas',
          suggestedColor: 'Rojo, verde y dorado',
        );
      case 'san valentín':
         return AIRecommendation(
          suggestedMessage: 'El día de San Valentín es ideal para recordar a $clientName sobre tus arreglos.',
          suggestedBouquet: 'Rosas y tulipanes',
          suggestedColor: 'Rojo y rosa',
        );
       case 'día de las madres':
         return AIRecommendation(
          suggestedMessage: 'Recuérdale a $clientName que tienes el regalo perfecto para el Día de las Madres.',
          suggestedBouquet: 'Lirios, orquídeas o su flor favorita',
          suggestedColor: 'Tonos pastel',
        );
      default:
        return null; // No specific recommendation for other event types
    }
  }
}
