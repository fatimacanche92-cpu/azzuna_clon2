import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';

class CalendarPage extends StatefulWidget {
  final String? initialFilter; // New field for filtering

  const CalendarPage({super.key, this.initialFilter});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final ReminderService _reminderService = ReminderService();
  List<Reminder> _allReminders = [];
  late final ValueNotifier<List<Reminder>> _selectedEvents;
  bool _isLoading = true;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Define the primary color from the user request
  static const Color primaryColor = Color(0xFF340A6B);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadReminders();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final reminders = await _reminderService.getReminders();
      setState(() {
        _allReminders = reminders;
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
      // Apply initial filter if provided
      if (widget.initialFilter != null && widget.initialFilter!.isNotEmpty) {
        _selectedEvents.value = _selectedEvents.value
            .where(
              (reminder) => reminder.classification == widget.initialFilter,
            )
            .toList();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar recordatorios: ${e.toString()}'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Reminder> _getEventsForDay(DateTime day) {
    List<Reminder> events = _allReminders
        .where((reminder) => isSameDay(reminder.date, day))
        .toList();
    // Apply filter if provided
    if (widget.initialFilter != null && widget.initialFilter!.isNotEmpty) {
      events = events
          .where((reminder) => reminder.classification == widget.initialFilter)
          .toList();
    }
    return events;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _showReminderForm([Reminder? reminder]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _ReminderForm(
          reminder: reminder,
          selectedDate: _selectedDay ?? DateTime.now(),
          onSave: () {
            _loadReminders();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendario',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF3E5F5),
      floatingActionButton: FloatingActionButton(
        heroTag: 'calendarFAB',
        onPressed: () => _showReminderForm(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTableCalendar(),
          const SizedBox(height: 8.0),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ValueListenableBuilder<List<Reminder>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      if (value.isEmpty) {
                        return const Center(
                          child: Text('No hay recordatorios para este día.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return _buildEventCard(value[index]);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar<Reminder>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      eventLoader: _getEventsForDay,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: primaryColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: primaryColor.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEventCard(Reminder event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: event.completed ? Colors.white.withOpacity(0.5) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: Checkbox(
          value: event.completed,
          onChanged: (bool? value) async {
            if (value == null) return;
            final updatedReminder = event.copyWith(completed: value);
            try {
              await _reminderService.updateReminder(updatedReminder);
              _loadReminders();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recordatorio actualizado.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          activeColor: primaryColor,
        ),
        title: Text(
          event.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            decoration: event.completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description != null && event.description!.isNotEmpty)
              Text(
                event.description!,
                style: TextStyle(
                  decoration: event.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            if (event.classification != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Clasificación: ${event.classification}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _showReminderForm(event),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar eliminación'),
                    content: const Text(
                      '¿Estás seguro de que quieres eliminar este recordatorio?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await _reminderService.deleteReminder(event.id);
                    _loadReminders();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Recordatorio eliminado.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.clientName != null && event.clientName!.isNotEmpty)
                  _buildDetailRow('Cliente:', event.clientName!),
                if (event.clientPhoneNumber != null &&
                    event.clientPhoneNumber!.isNotEmpty)
                  _buildDetailRow('Teléfono:', event.clientPhoneNumber!),
                if (event.clientAddress != null &&
                    event.clientAddress!.isNotEmpty)
                  _buildDetailRow('Dirección:', event.clientAddress!),
                if (event.paymentStatus != null)
                  _buildDetailRow('Estado de Pago:', event.paymentStatus!),
                if (event.amountPaid != null)
                  _buildDetailRow(
                    'Anticipo:',
                    '\$${event.amountPaid!.toStringAsFixed(2)}',
                  ),
                if (event.amountDue != null)
                  _buildDetailRow(
                    'Monto Restante:',
                    '\$${event.amountDue!.toStringAsFixed(2)}',
                  ),
                if (event.orderSpecification != null &&
                    event.orderSpecification!.isNotEmpty)
                  _buildDetailRow('Especificación:', event.orderSpecification!),
                _buildDetailRow('Lleva Nota:', event.hasNote ? 'Sí' : 'No'),
                if (event.hasNote)
                  _buildDetailRow(
                    'Nota Anónima:',
                    event.isAnonymous ? 'Sí' : 'No',
                  ),
                if (event.flowerArrangementSize != null)
                  _buildDetailRow(
                    'Tamaño Arreglo:',
                    event.flowerArrangementSize!,
                  ),
                if (event.flowerArrangementPrice != null)
                  _buildDetailRow(
                    'Precio Arreglo:',
                    '\$${event.flowerArrangementPrice!.toStringAsFixed(2)}',
                  ),
                if (event.flowerArrangementColor != null)
                  _buildDetailRow(
                    'Color Arreglo:',
                    event.flowerArrangementColor!,
                  ),
                if (event.flowerTypes != null && event.flowerTypes!.isNotEmpty)
                  _buildDetailRow(
                    'Tipos de Flores:',
                    event.flowerTypes!.join(', '),
                  ),
                if (event.specialFlowerInstructions != null &&
                    event.specialFlowerInstructions!.isNotEmpty)
                  _buildDetailRow(
                    'Instrucciones Especiales:',
                    event.specialFlowerInstructions!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ReminderForm extends StatefulWidget {
  final Reminder? reminder;
  final DateTime selectedDate;
  final VoidCallback onSave;

  const _ReminderForm({
    this.reminder,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  __ReminderFormState createState() => __ReminderFormState();
}

class __ReminderFormState extends State<_ReminderForm> {
  final _formKey = GlobalKey<FormState>();
  final _reminderService = ReminderService();
  late String _title;
  late String _description;
  late DateTime _date;
  bool _isSaving = false;

  // New fields
  late TextEditingController _clientNameController;
  late TextEditingController _clientPhoneNumberController;
  late TextEditingController _clientAddressController;
  String? _paymentStatus;
  late TextEditingController _amountPaidController;
  late TextEditingController _amountDueController;
  late TextEditingController _orderSpecificationController;
  late bool _hasNote;
  late bool _isAnonymous;
  String? _flowerArrangementSize;
  late TextEditingController _flowerArrangementPriceController;
  String? _flowerArrangementColor;
  late TextEditingController
  _flowerTypesController; // For simplicity, comma-separated string
  late TextEditingController _specialFlowerInstructionsController;
  String? _classification;

  final List<String> _paymentStatusOptions = [
    'Pagado',
    'Anticipo',
    'Pendiente',
  ];
  final List<String> _classificationOptions = [
    'Pedido',
    'Entrega',
    'Publicación Pendiente',
  ];
  final List<String> _flowerSizes = [
    'Pequeño',
    'Mediano',
    'Grande',
    'Extra Grande',
  ];
  final List<String> _flowerColors = [
    'Rojo',
    'Blanco',
    'Rosa',
    'Amarillo',
    'Azul',
    'Mixto',
  ];

  @override
  void initState() {
    super.initState();
    _title = widget.reminder?.title ?? '';
    _description = widget.reminder?.description ?? '';
    _date = widget.reminder?.date ?? widget.selectedDate;

    _clientNameController = TextEditingController(
      text: widget.reminder?.clientName ?? '',
    );
    _clientPhoneNumberController = TextEditingController(
      text: widget.reminder?.clientPhoneNumber ?? '',
    );
    _clientAddressController = TextEditingController(
      text: widget.reminder?.clientAddress ?? '',
    );
    _paymentStatus = widget.reminder?.paymentStatus;
    _amountPaidController = TextEditingController(
      text: widget.reminder?.amountPaid?.toString() ?? '',
    );
    _amountDueController = TextEditingController(
      text: widget.reminder?.amountDue?.toString() ?? '',
    );
    _orderSpecificationController = TextEditingController(
      text: widget.reminder?.orderSpecification ?? '',
    );
    _hasNote = widget.reminder?.hasNote ?? false;
    _isAnonymous = widget.reminder?.isAnonymous ?? false;
    _flowerArrangementSize = widget.reminder?.flowerArrangementSize;
    _flowerArrangementPriceController = TextEditingController(
      text: widget.reminder?.flowerArrangementPrice?.toString() ?? '',
    );
    _flowerArrangementColor = widget.reminder?.flowerArrangementColor;
    _flowerTypesController = TextEditingController(
      text: widget.reminder?.flowerTypes?.join(', ') ?? '',
    );
    _specialFlowerInstructionsController = TextEditingController(
      text: widget.reminder?.specialFlowerInstructions ?? '',
    );
    _classification = widget.reminder?.classification;
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneNumberController.dispose();
    _clientAddressController.dispose();
    _amountPaidController.dispose();
    _amountDueController.dispose();
    _orderSpecificationController.dispose();
    _flowerArrangementPriceController.dispose();
    _flowerTypesController.dispose();
    _specialFlowerInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSaving = true);

      try {
        final flowerTypesList = _flowerTypesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        if (widget.reminder == null) {
          await _reminderService.addReminder(
            title: _title,
            description: _description,
            date: _date,
            clientName: _clientNameController.text.isEmpty
                ? null
                : _clientNameController.text,
            clientPhoneNumber: _clientPhoneNumberController.text.isEmpty
                ? null
                : _clientPhoneNumberController.text,
            clientAddress: _clientAddressController.text.isEmpty
                ? null
                : _clientAddressController.text,
            paymentStatus: _paymentStatus,
            amountPaid: double.tryParse(_amountPaidController.text),
            amountDue: double.tryParse(_amountDueController.text),
            orderSpecification: _orderSpecificationController.text.isEmpty
                ? null
                : _orderSpecificationController.text,
            hasNote: _hasNote,
            isAnonymous: _isAnonymous,
            flowerArrangementSize: _flowerArrangementSize,
            flowerArrangementPrice: double.tryParse(
              _flowerArrangementPriceController.text,
            ),
            flowerArrangementColor: _flowerArrangementColor,
            flowerTypes: flowerTypesList.isEmpty ? null : flowerTypesList,
            specialFlowerInstructions:
                _specialFlowerInstructionsController.text.isEmpty
                ? null
                : _specialFlowerInstructionsController.text,
            classification: _classification,
          );
        } else {
          final updatedReminder = widget.reminder!.copyWith(
            title: _title,
            description: _description,
            date: _date,
            clientName: _clientNameController.text.isEmpty
                ? null
                : _clientNameController.text,
            clientPhoneNumber: _clientPhoneNumberController.text.isEmpty
                ? null
                : _clientPhoneNumberController.text,
            clientAddress: _clientAddressController.text.isEmpty
                ? null
                : _clientAddressController.text,
            paymentStatus: _paymentStatus,
            amountPaid: double.tryParse(_amountPaidController.text),
            amountDue: double.tryParse(_amountDueController.text),
            orderSpecification: _orderSpecificationController.text.isEmpty
                ? null
                : _orderSpecificationController.text,
            hasNote: _hasNote,
            isAnonymous: _isAnonymous,
            flowerArrangementSize: _flowerArrangementSize,
            flowerArrangementPrice: double.tryParse(
              _flowerArrangementPriceController.text,
            ),
            flowerArrangementColor: _flowerArrangementColor,
            flowerTypes: flowerTypesList.isEmpty ? null : flowerTypesList,
            specialFlowerInstructions:
                _specialFlowerInstructionsController.text.isEmpty
                ? null
                : _specialFlowerInstructionsController.text,
            classification: _classification,
          );
          await _reminderService.updateReminder(updatedReminder);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recordatorio guardado.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        widget.onSave();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.reminder == null
                    ? 'Añadir Recordatorio'
                    : 'Editar Recordatorio',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    value!.isEmpty ? 'El título no puede estar vacío' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                ),
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text('Fecha: ${DateFormat.yMMMd().format(_date)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_date),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _date = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    child: const Text(
                      'Cambiar',
                      style: TextStyle(color: _CalendarPageState.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Client Information
              _buildSectionTitle('Información del Cliente'),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _clientPhoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de Teléfono',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _clientAddressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              const SizedBox(height: 20),

              // Payment Status
              _buildSectionTitle('Estado de Pago'),
              DropdownButtonFormField<String>(
                value: _paymentStatus,
                decoration: const InputDecoration(labelText: 'Estado de Pago'),
                items: _paymentStatusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _paymentStatus = newValue;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountPaidController,
                decoration: const InputDecoration(
                  labelText: 'Monto Pagado (Anticipo)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountDueController,
                decoration: const InputDecoration(
                  labelText: 'Monto Restante por Pagar',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Order Specification
              _buildSectionTitle('Especificación del Pedido'),
              TextFormField(
                controller: _orderSpecificationController,
                decoration: const InputDecoration(
                  labelText: 'Detalles del Pedido',
                ),
                maxLines: 3,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _hasNote,
                    onChanged: (bool? value) {
                      setState(() {
                        _hasNote = value ?? false;
                      });
                    },
                  ),
                  const Text('Lleva Nota'),
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAnonymous = value ?? false;
                      });
                    },
                  ),
                  const Text('Nota Anónima'),
                ],
              ),
              const SizedBox(height: 20),

              // Product (Flowers) Details
              _buildSectionTitle('Detalles del Arreglo Floral'),
              DropdownButtonFormField<String>(
                value: _flowerArrangementSize,
                decoration: const InputDecoration(
                  labelText: 'Tamaño del Arreglo',
                ),
                items: _flowerSizes.map((String size) {
                  return DropdownMenuItem<String>(
                    value: size,
                    child: Text(size),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _flowerArrangementSize = newValue;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _flowerArrangementPriceController,
                decoration: const InputDecoration(
                  labelText: 'Precio del Arreglo',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _flowerArrangementColor,
                decoration: const InputDecoration(labelText: 'Color Principal'),
                items: _flowerColors.map((String color) {
                  return DropdownMenuItem<String>(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _flowerArrangementColor = newValue;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _flowerTypesController,
                decoration: const InputDecoration(
                  labelText: 'Tipos de Flores (separar por comas)',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _specialFlowerInstructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instrucciones de Flores Especiales',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Classification
              _buildSectionTitle('Clasificación'),
              DropdownButtonFormField<String>(
                value: _classification,
                decoration: const InputDecoration(labelText: 'Clasificación'),
                items: _classificationOptions.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _classification = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _CalendarPageState.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : const Text(
                        'Guardar',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
