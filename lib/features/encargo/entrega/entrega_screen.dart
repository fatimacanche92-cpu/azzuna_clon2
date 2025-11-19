import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/models/entrega_model.dart';
import 'package:flutter_app/core/services/encargo_service.dart';

class EntregaScreen extends ConsumerStatefulWidget {
  const EntregaScreen({super.key});

  @override
  ConsumerState<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends ConsumerState<EntregaScreen> {
  final _formKey = GlobalKey<FormState>();
  DeliveryType _deliveryType = DeliveryType.pasaPorEl;
  PaymentStatus? _paymentStatus;

  final _pickupNameController = TextEditingController();
  final _pickupPhoneController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _noteController = TextEditingController();
  final _remitenteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = ref.read(encargoServiceProvider).entrega;
    if (existing != null) {
      _deliveryType = existing.deliveryType ?? DeliveryType.pasaPorEl;
      _paymentStatus = existing.paymentStatus;
      _pickupNameController.text = existing.pickupName ?? '';
      _pickupPhoneController.text = existing.pickupPhone ?? '';
      _deliveryAddressController.text = existing.deliveryAddress ?? '';
      _recipientNameController.text = existing.recipientName ?? '';
      _noteController.text = existing.note ?? '';
      _remitenteController.text = existing.remitente ?? '';
    }
  }

  @override
  void dispose() {
    _pickupNameController.dispose();
    _pickupPhoneController.dispose();
    _deliveryAddressController.dispose();
    _recipientNameController.dispose();
    _noteController.dispose();
    _remitenteController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final remitente = _remitenteController.text.isEmpty ? 'Anónimo' : _remitenteController.text;
      final newEntrega = Entrega(
        deliveryType: _deliveryType,
        paymentStatus: _paymentStatus,
        pickupName: _deliveryType == DeliveryType.pasaPorEl ? _pickupNameController.text : null,
        pickupPhone: _deliveryType == DeliveryType.pasaPorEl ? _pickupPhoneController.text : null,
        deliveryAddress: _deliveryType == DeliveryType.porEntrega ? _deliveryAddressController.text : null,
        recipientName: _deliveryType == DeliveryType.porEntrega ? _recipientNameController.text : null,
        note: _deliveryType == DeliveryType.porEntrega ? _noteController.text : null,
        remitente: _deliveryType == DeliveryType.porEntrega ? remitente : null,
      );
      ref.read(encargoServiceProvider.notifier).updateEntrega(newEntrega);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paso 2: Entrega'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<DeliveryType>(
              segments: const [
                ButtonSegment(value: DeliveryType.pasaPorEl, label: Text('Pasa por él')),
                ButtonSegment(value: DeliveryType.porEntrega, label: Text('Por entrega')),
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
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _pickupNameController,
          decoration: const InputDecoration(labelText: 'Nombre de quien recoge', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'El nombre es obligatorio' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pickupPhoneController,
          decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (v) => v!.length != 10 ? 'El teléfono debe tener 10 dígitos' : null,
        ),
        const SizedBox(height: 16),
        _buildPaymentStatusDropdown(),
      ],
    );
  }

  Widget _buildDeliveryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _deliveryAddressController,
          decoration: const InputDecoration(labelText: 'Dirección de entrega', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'La dirección es obligatoria' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _recipientNameController,
          decoration: const InputDecoration(labelText: 'Nombre del destinatario', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'El nombre es obligatorio' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _remitenteController,
          decoration: const InputDecoration(labelText: 'Remitente (Opcional)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        _buildPaymentStatusDropdown(),
        const SizedBox(height: 24),
        Text('Nota', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteController,
          decoration: const InputDecoration(labelText: 'Escribir nota...', border: OutlineInputBorder()),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPaymentStatusDropdown() {
    return DropdownButtonFormField<PaymentStatus>(
      value: _paymentStatus,
      decoration: const InputDecoration(labelText: 'Estado de pago', border: OutlineInputBorder()),
      items: const [
        DropdownMenuItem(value: PaymentStatus.pagado, child: Text('Pagado')),
      ],
      onChanged: (value) => setState(() => _paymentStatus = value),
      validator: (v) => v == null ? 'Selecciona un estado de pago' : null,
    );
  }
}