import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/core/models/entrega_model.dart';
import 'package:flutter_app/core/services/encargo_service.dart';
import 'dart:io';
import 'package:tarjetas_flores/services/stable_diffusion_service.dart';
import 'package:tarjetas_flores/services/message_generator.dart';
import 'package:tarjetas_flores/models/card_data.dart';
import 'package:tarjetas_flores/widgets/card_factory.dart';
import 'package:screenshot/screenshot.dart';

class EntregaScreen extends ConsumerStatefulWidget {
  const EntregaScreen({super.key});

  @override
  ConsumerState<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends ConsumerState<EntregaScreen> {
  final _formKey = GlobalKey<FormState>();
  DeliveryType _deliveryType = DeliveryType.pasaPorEl;

  // Existing controllers
  final _pickupNameController = TextEditingController();
  final _pickupPhoneController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _noteController = TextEditingController();
  final _remitenteController = TextEditingController();
  final _emailController = TextEditingController();

  // New state for AI Card feature
  
  Uint8List? _generatedCardData;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(encargoServiceProvider).entrega;
    if (existing != null) {
      _deliveryType = existing.deliveryType ?? DeliveryType.pasaPorEl;
      _emailController.text = existing.email ?? '';
      _pickupNameController.text = existing.pickupName ?? '';
      _pickupPhoneController.text = existing.pickupPhone ?? '';
      _deliveryAddressController.text = existing.deliveryAddress ?? '';
      _recipientNameController.text = existing.recipientName ?? '';
      _noteController.text = existing.note ?? '';
      _remitenteController.text = existing.remitente ?? '';
    }
    // Also check for existing card data in the main encargo model
    _generatedCardData = ref.read(encargoServiceProvider).cardData;
  }

  @override
  void dispose() {
    _pickupNameController.dispose();
    _pickupPhoneController.dispose();
    _deliveryAddressController.dispose();
    _recipientNameController.dispose();
    _noteController.dispose();
    _remitenteController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final remitente = _remitenteController.text.isEmpty
          ? 'Anónimo'
          : _remitenteController.text;

      final note = null;

      final newEntrega = Entrega(
        deliveryType: _deliveryType,
        email: _emailController.text,
        pickupName: _deliveryType == DeliveryType.pasaPorEl
            ? _pickupNameController.text
            : null,
        pickupPhone: _deliveryType == DeliveryType.pasaPorEl
            ? _pickupPhoneController.text
            : null,
        deliveryAddress: _deliveryType == DeliveryType.porEntrega
            ? _deliveryAddressController.text
            : null,
        recipientName: _deliveryType == DeliveryType.porEntrega
            ? _recipientNameController.text
            : null,
        note: _deliveryType == DeliveryType.porEntrega ? note : null,
        remitente: _deliveryType == DeliveryType.porEntrega ? remitente : null,
      );

      // Update entrega details
      ref.read(encargoServiceProvider.notifier).updateEntrega(newEntrega);

      // The card data is already updated in the service via the _AiCardGenerator's callback

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 2: Entrega')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<DeliveryType>(
              segments: const [
                ButtonSegment(
                  value: DeliveryType.pasaPorEl,
                  label: Text('Pasa por él'),
                ),
                ButtonSegment(
                  value: DeliveryType.porEntrega,
                  label: Text('Por entrega'),
                ),
              ],
              selected: {_deliveryType},
              onSelectionChanged: (newSelection) {
                setState(() => _deliveryType = newSelection.first);
              },
            ),
            const SizedBox(height: 24),
            if (_deliveryType == DeliveryType.pasaPorEl)
              _buildPickupForm()
            else
              _buildDeliveryForm(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Correo Electrónico de Contacto',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'El correo es obligatorio';
        }
        if (!v.contains('@') || !v.contains('.')) {
          return 'Ingresa un correo válido';
        }
        return null;
      },
    );
  }

  Widget _buildPickupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _pickupNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre de quien recoge',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'El nombre es obligatorio' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pickupPhoneController,
          decoration: const InputDecoration(
            labelText: 'Teléfono del cliente (10 dígitos)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (v) {
            if (v == null || v.isEmpty) return null;
            if (v.length != 10) {
              return 'El teléfono debe tener exactamente 10 dígitos';
            }
            if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
              return 'Solo se permiten números';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildEmailField(),
      ],
    );
  }

  Widget _buildDeliveryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _deliveryAddressController,
          decoration: const InputDecoration(
            labelText: 'Dirección de entrega',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'La dirección es obligatoria' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _recipientNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del destinatario',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'El nombre es obligatorio' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _remitenteController,
          decoration: const InputDecoration(
            labelText: 'Remitente (Opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        _buildEmailField(),
        const SizedBox(height: 24),
        const Divider(),
        // Tarjeta AI: genera solo plantilla y permite seleccionar flor
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: _AiCardGenerator(
            recipientController: _recipientNameController,
            senderController: _remitenteController,
            initialCardData: _generatedCardData,
            onCardUpdated: (data) {
              ref.read(encargoServiceProvider.notifier).updateCardData(data);
            },
          ),
        ),
        const Divider(),
      ],
    );
  }
}

// --- AI CARD GENERATOR WIDGET ---

class _AiCardGenerator extends ConsumerStatefulWidget {
  final TextEditingController recipientController;
  final TextEditingController senderController;
  final Uint8List? initialCardData;
  final Function(Uint8List? data) onCardUpdated;

  const _AiCardGenerator({
    required this.recipientController,
    required this.senderController,
    this.initialCardData,
    required this.onCardUpdated,
  });

  @override
  ConsumerState<_AiCardGenerator> createState() => _AiCardGeneratorState();
}

class _AiCardGeneratorState extends ConsumerState<_AiCardGenerator> {
  Uint8List? _cardData;
  bool _isGenerating = false;
  CardTemplate _selectedTemplate = CardTemplate.spring;
  SpecialOccasion _selectedOccasion = SpecialOccasion.none;
  final ScreenshotController _screenshotController = ScreenshotController();
  String? _generatedBackgroundPath;

  @override
  void initState() {
    super.initState();
    _cardData = widget.initialCardData;
  }

  Future<void> _generateCard({bool isRegenerating = false}) async {
    setState(() => _isGenerating = true);

    try {
      // Build a prompt from selected flower, template and occasion
      final prompt = '${_getTemplateName(_selectedTemplate)} template, ${MessageGenerator.getOccasionName(_selectedOccasion)} themed floral background';

      final path = await StableDiffusionService.generateBackground(
        occasion: _selectedOccasion,
        template: _selectedTemplate,
        customPrompt: prompt,
      );

      if (path == null) throw Exception('La generación no devolvió ruta de imagen');

      // Precache the generated background to ensure it's loaded in the widget tree
      final file = File(path);
      if (!await file.exists()) throw Exception('El archivo de fondo generado no existe: $path');
      final imageProvider = FileImage(file);
      await precacheImage(imageProvider, context);

      // store generated background path so CardFactory can use it when rendering
      setState(() => _generatedBackgroundPath = path);

      // give framework a moment to rebuild with the new background
      await Future.delayed(const Duration(milliseconds: 400));

      final image = await _screenshotController.capture(delay: const Duration(milliseconds: 300), pixelRatio: 2.0);

      if (image != null) {
        setState(() {
          _cardData = image;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tarjeta generada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('No se pudo capturar la tarjeta');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _saveCard() {
    if (_cardData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, genera una tarjeta primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    widget.onCardUpdated(_cardData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tarjeta guardada en el pedido.'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generar Tarjeta con IA',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            // (La selección de flor se ha eliminado — la plantilla se adapta a la ocasión)
            // Selector de Ocasión
            Text(
              'Ocasión Especial',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SpecialOccasion>(
                  value: _selectedOccasion,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  items: SpecialOccasion.values.map((occasion) {
                    return DropdownMenuItem(
                      value: occasion,
                      child: Text(MessageGenerator.getOccasionName(occasion)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedOccasion = value;
                        // Auto-adapt template based on occasion
                        _selectedTemplate = _templateForOccasion(value);
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // El diseño se selecciona automáticamente según la ocasión especial
            Text(
              'Diseño automático según la ocasión',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            // Preview de la tarjeta
            Text(
              'Previsualización',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _isGenerating
                  ? const Center(child: CircularProgressIndicator())
                  : (_cardData != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_cardData!, fit: BoxFit.contain),
                        )
                      : Screenshot(
                          controller: _screenshotController,
                          child: Center(
                            child: SizedBox(
                              width: 300,
                              height: 420,
                              child: CardFactory.createCard(
                                cardData: CardData(
                                  recipientName: widget.recipientController.text.trim(),
                                  message: '',
                                  senderName: widget.senderController.text.trim(),
                                  template: _selectedTemplate,
                                  occasion: _selectedOccasion,
                                  backgroundImageUrl: _generatedBackgroundPath,
                                  useAIGeneratedBackground: _generatedBackgroundPath != null,
                                ),
                                width: 300,
                                height: 420,
                              ),
                            ),
                          ),
                        )),
            ),
            const SizedBox(height: 16),
            // Botones
            if (_cardData == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateCard,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generar Tarjeta con IA'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _cardData = null),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Regenerar'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveCard,
                    icon: const Icon(Icons.check),
                    label: const Text('Guardar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
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
  CardTemplate _templateForOccasion(SpecialOccasion occasion) {
    switch (occasion) {
      case SpecialOccasion.valentines:
        return CardTemplate.romantic;
      case SpecialOccasion.mothersDay:
        return CardTemplate.elegant;
      case SpecialOccasion.birthday:
        return CardTemplate.modern;
      case SpecialOccasion.wedding:
        return CardTemplate.wedding;
      case SpecialOccasion.anniversary:
        return CardTemplate.romantic;
      case SpecialOccasion.graduation:
        return CardTemplate.modern;
      case SpecialOccasion.sympathy:
        return CardTemplate.classic;
      case SpecialOccasion.congratulations:
        return CardTemplate.modern;
      case SpecialOccasion.thankYou:
        return CardTemplate.classic;
      case SpecialOccasion.christmas:
        return CardTemplate.classic;
      case SpecialOccasion.newYear:
        return CardTemplate.modern;
      case SpecialOccasion.easter:
        return CardTemplate.spring;
      case SpecialOccasion.halloween:
        return CardTemplate.modern;
      case SpecialOccasion.none:
        return CardTemplate.spring;
    }
  }
}
