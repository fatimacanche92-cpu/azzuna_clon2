import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/card_data.dart';
import '../services/message_generator.dart';
import '../widgets/background_selector.dart';
import 'package:intl/intl.dart';

class CustomizationScreen extends StatefulWidget {
  final CardData cardData;
  final Function(CardData) onCardDataChanged;

  const CustomizationScreen({
    super.key,
    required this.cardData,
    required this.onCardDataChanged,
  });

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  late CardData _currentCardData;
  late TextEditingController _recipientController;
  late TextEditingController _senderController;
  late TextEditingController _customMessageController;

  @override
  void initState() {
    super.initState();
    _currentCardData = widget.cardData;
    _recipientController = TextEditingController(text: widget.cardData.recipientName);
    _senderController = TextEditingController(text: widget.cardData.senderName);
    _customMessageController = TextEditingController(text: widget.cardData.customMessage);
  }

  @override
  void didUpdateWidget(CustomizationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo actualizar campos de texto si cambiaron
    // NUNCA sobrescribir los colores - siempre preservar los que el usuario eligió
    if (widget.cardData.recipientName != _currentCardData.recipientName) {
      _recipientController.text = widget.cardData.recipientName;
      _currentCardData = _currentCardData.copyWith(recipientName: widget.cardData.recipientName);
    }
    if (widget.cardData.senderName != _currentCardData.senderName) {
      _senderController.text = widget.cardData.senderName;
      _currentCardData = _currentCardData.copyWith(senderName: widget.cardData.senderName);
    }
    if (widget.cardData.customMessage != _currentCardData.customMessage) {
      _customMessageController.text = widget.cardData.customMessage;
      _currentCardData = _currentCardData.copyWith(customMessage: widget.cardData.customMessage);
    }
    if (widget.cardData.template != _currentCardData.template) {
      _currentCardData = _currentCardData.copyWith(template: widget.cardData.template);
    }
    if (widget.cardData.occasion != _currentCardData.occasion) {
      _currentCardData = _currentCardData.copyWith(occasion: widget.cardData.occasion);
    }
    // Actualizar mensaje si cambió, pero preservar colores
    if (widget.cardData.message != _currentCardData.message) {
      _currentCardData = _currentCardData.copyWith(message: widget.cardData.message);
    }
    // NUNCA actualizar primaryColor o secondaryColor desde el widget padre
    // Los colores solo se actualizan cuando el usuario los cambia directamente
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _senderController.dispose();
    _customMessageController.dispose();
    super.dispose();
  }

  void _updateCardData() {
    widget.onCardDataChanged(_currentCardData);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalizar Tarjeta',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          // Selector de ocasión
          _buildSectionTitle('Ocasión Especial'),
          const SizedBox(height: 10),
          _buildOccasionSelector(),
          const SizedBox(height: 30),
          // Selector de plantilla
          _buildSectionTitle('Diseño de Tarjeta'),
          const SizedBox(height: 10),
          _buildTemplateSelector(isMobile: MediaQuery.of(context).size.width < 768),
          const SizedBox(height: 30),
          // Nombre del destinatario
          _buildSectionTitle('Destinatario'),
          const SizedBox(height: 10),
          TextField(
            controller: _recipientController,
            decoration: InputDecoration(
              hintText: 'Nombre del destinatario',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            onChanged: (value) {
              setState(() {
                _currentCardData = _currentCardData.copyWith(recipientName: value);
              });
              _updateCardData();
            },
          ),
          const SizedBox(height: 20),
          // Nombre del remitente
          _buildSectionTitle('Remitente'),
          const SizedBox(height: 10),
          TextField(
            controller: _senderController,
            decoration: InputDecoration(
              hintText: 'Tu nombre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.edit),
            ),
            onChanged: (value) {
              setState(() {
                _currentCardData = _currentCardData.copyWith(senderName: value);
              });
              _updateCardData();
            },
          ),
          const SizedBox(height: 30),
          // Mensaje personalizado
          _buildSectionTitle('Mensaje Personalizado'),
          const SizedBox(height: 10),
          Text(
            'Deja vacío para usar mensaje automático según la ocasión',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _customMessageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Escribe tu mensaje personalizado...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _currentCardData = _currentCardData.copyWith(
                  customMessage: value,
                  message: value.isNotEmpty ? value : MessageGenerator.generateMessage(_currentCardData.occasion),
                );
                _updateCardData();
              });
            },
          ),
          const SizedBox(height: 30),
          // Colores
          _buildSectionTitle('Colores'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Color Principal'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final color = await showDialog<Color>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Seleccionar Color Principal'),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: _currentCardData.primaryColor,
                                onColorChanged: (color) {
                                  Navigator.pop(context, color);
                                },
                                availableColors: const [
                                  Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFFEF4444),
                                  Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFF3B82F6),
                                  Color(0xFF6366F1), Color(0xFF8B5A2B), Color(0xFF6B7280),
                                  Color(0xFF000000), Color(0xFFFF69B4), Color(0xFFFFD700),
                                  Color(0xFF4ECDC4), Color(0xFF8B4513), Color(0xFF2C3E50),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                            ],
                          ),
                        );
                        if (color != null) {
                          setState(() {
                            _currentCardData = _currentCardData.copyWith(primaryColor: color);
                          });
                          // Llamar fuera de setState para asegurar que se propaga
                          _updateCardData();
                        }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: _currentCardData.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Color Secundario'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final color = await showDialog<Color>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Seleccionar Color Secundario'),
                            content: SingleChildScrollView(
                              child: BlockPicker(
                                pickerColor: _currentCardData.secondaryColor,
                                onColorChanged: (color) {
                                  Navigator.pop(context, color);
                                },
                                availableColors: const [
                                  Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFFEF4444),
                                  Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFF3B82F6),
                                  Color(0xFF6366F1), Color(0xFF8B5A2B), Color(0xFF6B7280),
                                  Color(0xFF000000), Color(0xFFFF69B4), Color(0xFFFFD700),
                                  Color(0xFF4ECDC4), Color(0xFF8B4513), Color(0xFF2C3E50),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                            ],
                          ),
                        );
                        if (color != null) {
                          setState(() {
                            _currentCardData = _currentCardData.copyWith(secondaryColor: color);
                          });
                          // Llamar fuera de setState para asegurar que se propaga
                          _updateCardData();
                        }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: _currentCardData.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Selector de fondo con IA
          BackgroundSelector(
              cardData: _currentCardData,
              onBackgroundChanged: (newData) {
                setState(() {
                  _currentCardData = newData;
                  _updateCardData();
                });
              },
            ),
          const SizedBox(height: 30),
          // Botón para generar automáticamente
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  // NO sobrescribir primaryColor - mantener el que el usuario eligió
                  _currentCardData = _currentCardData.copyWith(
                    message: MessageGenerator.generateMessage(
                      _currentCardData.occasion,
                      customMessage: _currentCardData.customMessage.isEmpty
                          ? null
                          : _currentCardData.customMessage,
                    ),
                    // Mantener los colores que el usuario ya eligió
                  );
                  _updateCardData();
                });
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generar Mensaje Automático'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildOccasionSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SpecialOccasion>(
          value: _currentCardData.occasion,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          items: SpecialOccasion.values.map((occasion) {
            return DropdownMenuItem(
              value: occasion,
              child: Row(
                children: [
                  Icon(
                    _getOccasionIcon(occasion),
                    color: MessageGenerator.getOccasionColor(occasion),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(MessageGenerator.getOccasionName(occasion)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                // Preservar los colores personalizados - NO sobrescribir
                _currentCardData = _currentCardData.copyWith(
                  occasion: value,
                  // NO cambiar primaryColor - mantener el que el usuario eligió
                  message: MessageGenerator.generateMessage(value),
                );
                _updateCardData();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTemplateSelector({bool isMobile = false}) {
    return SizedBox(
      height: isMobile ? 100 : 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 0),
        children: CardTemplate.values.map((template) {
          final isSelected = _currentCardData.template == template;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentCardData = _currentCardData.copyWith(template: template);
                _updateCardData();
              });
            },
            child: Container(
              width: isMobile ? 80 : 100,
              margin: EdgeInsets.only(right: isMobile ? 10 : 15),
              decoration: BoxDecoration(
                color: isSelected ? _currentCardData.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? _currentCardData.primaryColor
                      : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getTemplateEmoji(template),
                    style: TextStyle(fontSize: isMobile ? 32 : 40),
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
                    child: Text(
                      _getTemplateName(template),
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getOccasionIcon(SpecialOccasion occasion) {
    switch (occasion) {
      case SpecialOccasion.valentines:
        return Icons.favorite;
      case SpecialOccasion.mothersDay:
        return Icons.family_restroom;
      case SpecialOccasion.birthday:
        return Icons.cake;
      case SpecialOccasion.wedding:
        return Icons.diamond;
      case SpecialOccasion.anniversary:
        return Icons.favorite_border;
      case SpecialOccasion.graduation:
        return Icons.school;
      case SpecialOccasion.sympathy:
        return Icons.volunteer_activism;
      case SpecialOccasion.congratulations:
        return Icons.celebration;
      case SpecialOccasion.thankYou:
        return Icons.thumb_up;
      case SpecialOccasion.christmas:
        return Icons.ac_unit; // Copo de nieve
      case SpecialOccasion.newYear:
        return Icons.celebration; // Celebración
      case SpecialOccasion.easter:
        return Icons.egg; // Huevo de Pascua
      case SpecialOccasion.halloween:
        return Icons.local_fire_department; // Calabaza/fuego
      case SpecialOccasion.none:
        return Icons.card_giftcard;
    }
  }

  String _getTemplateEmoji(CardTemplate template) {
    switch (template) {
      case CardTemplate.romantic:
        return '🌹';
      case CardTemplate.elegant:
        return '🌸';
      case CardTemplate.modern:
        return '💐';
      case CardTemplate.classic:
        return '🌺';
      case CardTemplate.spring:
        return '🌼';
      case CardTemplate.wedding:
        return '💍';
    }
  }

  String _getTemplateName(CardTemplate template) {
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

