import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/customer_tracking/domain/customer_event.dart';
import 'package:flutter_app/features/customer_tracking/presentation/providers/customer_tracking_providers.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  final CustomerEvent? event;

  const EventFormScreen({super.key, this.event});

  @override
  _EventFormScreenState createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  DateTime? _selectedDate;
  String? _selectedEventType;

  final List<String> _eventTypes = [
    'cumpleaños',
    'aniversario',
    'navidad',
    'san valentín',
    'día de las madres',
    'fecha especial',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event?.clientName);
    _phoneController = TextEditingController(text: widget.event?.clientPhone);
    _notesController = TextEditingController(text: widget.event?.notes);
    _selectedDate = widget.event?.eventDate;
    _selectedEventType = widget.event?.eventType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedEventType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona fecha y tipo de evento.')),
        );
        return;
      }

      final notifier = ref.read(customerTrackingNotifierProvider.notifier);
      final isEditing = widget.event != null;

      final event = CustomerEvent(
        id: isEditing ? widget.event!.id : const Uuid().v4(),
        userId: '', // This will be set by the repository
        clientName: _nameController.text,
        clientPhone: _phoneController.text,
        eventType: _selectedEventType!,
        eventDate: _selectedDate!,
        notes: _notesController.text,
        createdAt: isEditing ? widget.event!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (isEditing) {
        success = await notifier.updateEvent(event);
      } else {
        success = await notifier.addEvent(event);
      }
      
      if (success && mounted) {
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el evento.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Evento' : 'Añadir Evento'),
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Cliente'),
                validator: (value) =>
                    value!.isEmpty ? 'El nombre no puede estar vacío' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono del Cliente (Opcional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEventType,
                hint: const Text('Tipo de Evento'),
                items: _eventTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type[0].toUpperCase() + type.substring(1)),
                )).toList(),
                onChanged: (value) => setState(() => _selectedEventType = value),
                validator: (value) => value == null ? 'Selecciona un tipo' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No se ha seleccionado fecha'
                          : 'Fecha: ${DateFormat.yMMMd('es_ES').format(_selectedDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Seleccionar Fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas (Opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'Guardar Cambios' : 'Crear Evento', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
