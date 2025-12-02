import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/core/models/entrega_model.dart';
import 'package:flutter_app/core/services/encargo_service.dart';
import 'package:http/http.dart' as http;

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
  bool _wantsNote = false;
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

      // If a note exists, the section should be open
      if (existing.note != null && existing.note!.isNotEmpty) {
        _wantsNote = true;
      }
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

      final note = _wantsNote ? _noteController.text : null;

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
        SwitchListTile(
          title: const Text('¿Lleva nota / dedicatoria?'),
          value: _wantsNote,
          onChanged: (bool value) {
            setState(() {
              _wantsNote = value;
            });
          },
        ),
        if (_wantsNote)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Escribe tu nota aquí...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _AiCardGenerator(
                  noteController: _noteController,
                  initialCardData: _generatedCardData,
                  onCardUpdated: (data) {
                    ref
                        .read(encargoServiceProvider.notifier)
                        .updateCardData(data);
                  },
                ),
              ],
            ),
          ),
        const Divider(),
      ],
    );
  }
}

// --- AI CARD GENERATOR WIDGET ---

class _AiCardGenerator extends ConsumerStatefulWidget {
  final TextEditingController noteController;
  final Uint8List? initialCardData;
  final Function(Uint8List? data) onCardUpdated;

  const _AiCardGenerator({
    required this.noteController,
    this.initialCardData,
    required this.onCardUpdated,
  });

  @override
  ConsumerState<_AiCardGenerator> createState() => _AiCardGeneratorState();
}

class _AiCardGeneratorState extends ConsumerState<_AiCardGenerator> {
  Uint8List? _cardData;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _cardData = widget.initialCardData;
  }

  Future<void> _generateCard({bool isRegenerating = false}) async {
    if (widget.noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escribe una nota para usarla como prompt.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // Simulate AI generation by fetching a random image from an API
      final seed = isRegenerating
          ? DateTime.now().millisecondsSinceEpoch
          : 'fixed_seed';
      final response = await http.get(
        Uri.parse('https://picsum.photos/seed/$seed/500/300'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _cardData = response.bodyBytes;
        });
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar la tarjeta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _saveCard() {
    widget.onCardUpdated(_cardData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tarjeta guardada en el pedido.'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _shareCard() {
    if (_cardData == null) return;
    // TODO: Implement sharing logic (e.g., using 'share_plus' package)
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generar Tarjeta con IA',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isGenerating
                ? const Center(child: CircularProgressIndicator())
                : (_cardData != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_cardData!, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )),
          ),
          const SizedBox(height: 12),

          if (_cardData == null)
            Center(
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateCard,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generar tarjeta con IA'),
              ),
            ),

          if (_cardData != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => _generateCard(isRegenerating: true),
                  child: const Text('Regenerar'),
                ),
                TextButton(
                  onPressed: _shareCard,
                  child: const Text('Compartir'),
                ),
                ElevatedButton(
                  onPressed: _saveCard,
                  child: const Text('Guardar'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
