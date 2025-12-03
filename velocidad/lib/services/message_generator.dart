import 'package:flutter/material.dart';
import '../models/card_data.dart';

class MessageGenerator {
  static final Map<SpecialOccasion, List<String>> _occasionMessages = {
    SpecialOccasion.valentines: [
      'Con estas flores quiero decirte que eres el amor de mi vida. Cada pétalo representa un momento especial que hemos compartido juntos.',
      'En este día del amor, estas flores llevan todo mi cariño y admiración hacia ti. Eres especial en mi vida.',
      'Las flores más hermosas para la persona más hermosa. Feliz San Valentín, mi amor.',
      'Que estas flores expresen lo que a veces las palabras no pueden decir. Te amo más de lo que puedo expresar.',
    ],
    SpecialOccasion.mothersDay: [
      'Mamá, estas flores son un pequeño reflejo de la belleza y el amor que siempre has sembrado en mi vida. Gracias por ser mi guía y mi inspiración.',
      'En este día especial, quiero que sepas que eres la mejor mamá del mundo. Estas flores representan todo mi amor y gratitud hacia ti.',
      'Mamá, no hay palabras suficientes para agradecerte todo lo que has hecho por mí. Estas flores son solo un símbolo de mi amor infinito.',
      'Gracias por ser mi ejemplo, mi apoyo y mi amor incondicional. Feliz Día de la Madre, mamá querida.',
    ],
    SpecialOccasion.birthday: [
      'En tu día especial, estas flores son un deseo de que tu vida esté siempre llena de alegría, amor y momentos inolvidables. ¡Feliz cumpleaños!',
      'Que este nuevo año de vida esté lleno de flores, sonrisas y momentos hermosos. ¡Feliz cumpleaños!',
      'Las flores más hermosas para celebrar a una persona tan especial. Que todos tus deseos se cumplan. ¡Feliz cumpleaños!',
      'En tu día, estas flores representan todos los buenos deseos que tengo para ti. ¡Que tengas un cumpleaños maravilloso!',
    ],
    SpecialOccasion.wedding: [
      'En este día tan especial, estas flores representan los mejores deseos para vuestra unión. Que vuestro amor florezca como estas hermosas flores.',
      'Que vuestra vida juntos esté llena de momentos tan hermosos como estas flores. Felicidades en vuestro matrimonio.',
      'En vuestro día especial, estas flores son un símbolo de amor, felicidad y prosperidad para vuestra nueva vida juntos.',
      'Que estas flores sean el inicio de un jardín lleno de amor, comprensión y felicidad. ¡Felicidades!',
    ],
    SpecialOccasion.anniversary: [
      'Que estas flores celebren otro año de amor, complicidad y felicidad juntos. Feliz aniversario.',
      'Cada año juntos es una nueva flor en el jardín de vuestro amor. Felicidades en vuestro aniversario.',
      'Estas flores representan todos los momentos hermosos que han compartido. ¡Feliz aniversario!',
      'Que vuestro amor siga floreciendo año tras año. Felicidades en este día tan especial.',
    ],
    SpecialOccasion.graduation: [
      'En este día tan importante, estas flores celebran tu esfuerzo, dedicación y éxito. ¡Felicidades por tu graduación!',
      'Que estas flores representen el inicio de una nueva etapa llena de oportunidades y éxitos. ¡Feliz graduación!',
      'Has florecido y alcanzado grandes logros. Estas flores son un reconocimiento a tu dedicación. ¡Felicidades!',
      'En tu graduación, estas flores son un símbolo de orgullo y admiración por todo lo que has logrado.',
    ],
    SpecialOccasion.sympathy: [
      'En estos momentos difíciles, estas flores son un pequeño consuelo y una muestra de nuestro apoyo y cariño.',
      'Que estas flores traigan un poco de paz y serenidad en este momento. Estamos contigo.',
      'Con estas flores queremos expresar nuestro más sentido pésame y nuestro apoyo en estos momentos.',
      'Que estas flores sean un símbolo de esperanza y consuelo. Nuestros pensamientos están contigo.',
    ],
    SpecialOccasion.congratulations: [
      'Estas flores celebran tu logro y éxito. ¡Felicidades por este momento tan especial!',
      'Que estas flores representen la alegría y orgullo que sentimos por tu logro. ¡Felicidades!',
      'En este momento especial, estas flores son un reconocimiento a tu esfuerzo y dedicación.',
      '¡Felicidades! Estas flores celebran tu éxito y todos los buenos momentos que están por venir.',
    ],
    SpecialOccasion.thankYou: [
      'Estas flores son una pequeña muestra de mi agradecimiento por tu generosidad y amabilidad.',
      'Gracias por todo. Estas flores expresan mi gratitud y cariño hacia ti.',
      'Con estas flores quiero agradecerte por ser tan especial en mi vida. Gracias por todo.',
      'Estas flores son un símbolo de mi agradecimiento sincero. Gracias por todo lo que haces.',
    ],
    SpecialOccasion.christmas: [
      'En esta Navidad, estas flores son un deseo de paz, amor y felicidad para ti y los tuyos. ¡Feliz Navidad!',
      'Que estas flores navideñas traigan alegría y esperanza a tu hogar. ¡Feliz Navidad!',
      'En esta época especial, estas flores representan los mejores deseos para ti. ¡Feliz Navidad y próspero Año Nuevo!',
      'Que el espíritu navideño llene tu corazón de alegría. Estas flores son un símbolo de amor y paz. ¡Feliz Navidad!',
    ],
    SpecialOccasion.newYear: [
      'Que este nuevo año esté lleno de flores, alegrías y momentos inolvidables. ¡Feliz Año Nuevo!',
      'Con estas flores te deseamos un año nuevo lleno de éxito, amor y felicidad. ¡Próspero Año Nuevo!',
      'Que el nuevo año traiga nuevas oportunidades y momentos hermosos. ¡Feliz Año Nuevo!',
      'Estas flores representan nuestros mejores deseos para este nuevo año. ¡Que sea maravilloso!',
    ],
    SpecialOccasion.easter: [
      'En esta Pascua, estas flores representan renacimiento, esperanza y nuevos comienzos. ¡Feliz Pascua!',
      'Que estas flores de Pascua traigan alegría y renovación a tu vida. ¡Feliz Pascua!',
      'En esta época de renacimiento, estas flores son un símbolo de esperanza y nuevos comienzos.',
      '¡Feliz Pascua! Que estas flores llenen tu hogar de alegría y renovación.',
    ],
    SpecialOccasion.halloween: [
      'En esta noche mágica, estas flores oscuras y misteriosas son perfectas para celebrar Halloween.',
      'Que estas flores de Halloween traigan diversión y misterio a tu celebración. ¡Feliz Halloween!',
      'En esta noche especial, estas flores representan la magia y el misterio de Halloween.',
      '¡Feliz Halloween! Que estas flores oscuras y elegantes acompañen tu celebración.',
    ],
    SpecialOccasion.none: [
      'Esperamos que estas flores traigan alegría y belleza a tu día.',
      'Que estas hermosas flores llenen tu espacio de color y felicidad.',
      'Con estas flores queremos hacerte saber que pensamos en ti.',
      'Que estas flores sean un recordatorio de lo especial que eres.',
    ],
  };

  static String generateMessage(SpecialOccasion occasion, {String? customMessage}) {
    if (customMessage != null && customMessage.isNotEmpty) {
      return customMessage;
    }

    final messages = _occasionMessages[occasion] ?? _occasionMessages[SpecialOccasion.none]!;
    return messages[DateTime.now().millisecond % messages.length];
  }

  static String getOccasionName(SpecialOccasion occasion) {
    switch (occasion) {
      case SpecialOccasion.valentines:
        return 'San Valentín';
      case SpecialOccasion.mothersDay:
        return 'Día de la Madre';
      case SpecialOccasion.birthday:
        return 'Cumpleaños';
      case SpecialOccasion.wedding:
        return 'Boda';
      case SpecialOccasion.anniversary:
        return 'Aniversario';
      case SpecialOccasion.graduation:
        return 'Graduación';
      case SpecialOccasion.sympathy:
        return 'Pésame';
      case SpecialOccasion.congratulations:
        return 'Felicidades';
      case SpecialOccasion.thankYou:
        return 'Agradecimiento';
      case SpecialOccasion.christmas:
        return 'Navidad';
      case SpecialOccasion.newYear:
        return 'Año Nuevo';
      case SpecialOccasion.easter:
        return 'Pascua';
      case SpecialOccasion.halloween:
        return 'Halloween';
      case SpecialOccasion.none:
        return 'General';
    }
  }

  static Color getOccasionColor(SpecialOccasion occasion) {
    switch (occasion) {
      case SpecialOccasion.valentines:
        return const Color(0xFFEC4899);
      case SpecialOccasion.mothersDay:
        return const Color(0xFFFF69B4);
      case SpecialOccasion.birthday:
        return const Color(0xFFFF6B6B);
      case SpecialOccasion.wedding:
        return const Color(0xFFFFD700);
      case SpecialOccasion.anniversary:
        return const Color(0xFF8B5CF6);
      case SpecialOccasion.graduation:
        return const Color(0xFF4ECDC4);
      case SpecialOccasion.sympathy:
        return const Color(0xFF6B7280);
      case SpecialOccasion.congratulations:
        return const Color(0xFF10B981);
      case SpecialOccasion.thankYou:
        return const Color(0xFFF59E0B);
      case SpecialOccasion.christmas:
        return const Color(0xFFDC2626); // Rojo navideño
      case SpecialOccasion.newYear:
        return const Color(0xFFFFD700); // Dorado
      case SpecialOccasion.easter:
        return const Color(0xFF10B981); // Verde pastel
      case SpecialOccasion.halloween:
        return const Color(0xFF7C3AED); // Púrpura oscuro
      case SpecialOccasion.none:
        return const Color(0xFF8B5CF6);
    }
  }
}
