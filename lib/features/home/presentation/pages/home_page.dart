import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/features/reminders/domain/models/reminder_model.dart'; // Corrected import
import 'package:flutter_app/features/reminders/presentation/providers/reminder_provider.dart'; // Corrected import

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final reminderState = ref.watch(reminderNotifierProvider);
    final pendingReminders = ref.watch(reminderNotifierProvider.notifier).getPendingReminders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Azzuna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_fab',
        onPressed: () {
          context.push('/encargo');
        },
        label: const Text('Nuevo Pedido'),
        icon: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendar(context, reminderState),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 28),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => _showAddReminderSheet(context, _selectedDay ?? DateTime.now()),
              ),
            ),
            const SizedBox(height: 16), // Adjusted spacing
            // Status Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    count: 12, // Placeholder
                    title: 'Pedidos en envío',
                    onTap: () {
                      context.push('/shipping-orders');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    count: 8, // Placeholder
                    title: 'Pedidos por recoger',
                    onTap: () {
                      context.push('/pickup-orders');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Pending Reminders List
            _buildPendingRemindersList(context, pendingReminders),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, ReminderState reminderState) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    headerPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: (day) => ref.read(reminderNotifierProvider.notifier).getRemindersForDay(day),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(events),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  // Helper for month names
  static const List<String> _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  Widget _buildEventsMarker(List<dynamic> events) {
    // Show a single dot if there are any events
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
    );
  }

  Widget _buildStatusCard({
    required int count,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderSheet(BuildContext context, DateTime selectedDate) {
    final TextEditingController reminderController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nuevo Recordatorio para ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: reminderController,
                decoration: const InputDecoration(
                  labelText: 'Recordatorio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (reminderController.text.isNotEmpty) {
                    ref.read(reminderNotifierProvider.notifier).addReminder(
                          ReminderModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: reminderController.text,
                            date: selectedDate,
                            isCompleted: false,
                          ),
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingRemindersList(BuildContext context, List<ReminderModel> reminders) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Recordatorios Pendientes',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (reminders.isEmpty)
          Text(
            'No hay recordatorios pendientes.',
            style: GoogleFonts.poppins(color: Colors.grey),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: CheckboxListTile(
                  title: Text(
                    reminder.title,
                    style: GoogleFonts.poppins(
                      decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    '${reminder.date.day}/${reminder.date.month}/${reminder.date.year}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                  value: reminder.isCompleted,
                  onChanged: (bool? newValue) {
                    if (newValue != null) {
                      ref.read(reminderNotifierProvider.notifier).toggleReminderCompletion(
                            reminder.id,
                            newValue,
                          );
                    }
                  },
                  activeColor: theme.colorScheme.primary,
                ),
              );
            },
          ),
      ],
    );
  }
}

