import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/features/home/presentation/widgets/order_status_animator.dart';
import 'package:flutter_app/features/orders/domain/models/order_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Dummy data copied from OrdersListPage to simulate a data source.
  // In a real app, this would come from a Riverpod provider.
  static final List<OrderModel> _allOrders = [
    OrderModel(
      id: '001',
      clientName: 'Cliente Ejemplo 1',
      arrangementType: 'Arreglo Floral',
      scheduledDate: DateTime.now(),
      deliveryType: OrderDeliveryType.envio,
      shippingStatus: OrderShippingStatus.enEspera,
      paymentStatus: OrderPaymentStatus.pagado,
      price: 50.0,
    ),
    OrderModel(
      id: '004',
      clientName: 'Ana López',
      arrangementType: 'Floral Grande',
      scheduledDate: DateTime.now(),
      deliveryType: OrderDeliveryType.recoger,
      paymentStatus: OrderPaymentStatus.conAnticipo,
      price: 650.0,
      downPayment: 300.0,
      remainingAmount: 350.0,
    ),
    OrderModel(
      id: '002',
      clientName: 'Cliente Ejemplo 2',
      arrangementType: 'Ramo de Rosas',
      scheduledDate: DateTime.now(),
      deliveryType: OrderDeliveryType.envio,
      shippingStatus: OrderShippingStatus.enCamino,
      paymentStatus: OrderPaymentStatus.pagado,
      price: 75.0,
    ),
    OrderModel(
      id: '005',
      clientName: 'Carlos Pérez',
      arrangementType: 'Rosa Premium',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      deliveryType: OrderDeliveryType.recoger,
      paymentStatus: OrderPaymentStatus.pagado,
      price: 420.0,
    ),
    OrderModel(
      id: '003',
      clientName: 'Cliente Ejemplo 3',
      arrangementType: 'Caja de Girasoles',
      scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
      deliveryType: OrderDeliveryType.envio,
      shippingStatus: OrderShippingStatus.entregado,
      paymentStatus: OrderPaymentStatus.pagado,
      price: 60.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the counts from the dummy data
    final shippingOrdersCount = _allOrders
        .where((order) => order.deliveryType == OrderDeliveryType.envio)
        .length;
    final pickupOrdersCount = _allOrders
        .where((order) => order.deliveryType == OrderDeliveryType.recoger)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Azzuna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Calendar
            _buildCalendar(context),
            const SizedBox(height: 24),

            // 2. New Order Button
            _buildNewOrderButton(context),
            const SizedBox(height: 24),

            // 3. Metric Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    count: shippingOrdersCount, // Use calculated count
                    title: 'Pedidos en envío',
                    onTap: () {
                      context.push('/shipping-orders');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    count: pickupOrdersCount, // Use calculated count
                    title: 'Pedidos por recoger',
                    onTap: () {
                      context.push('/pickup-orders');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Today's Schedules
            _buildTodaySchedules(context),
            const SizedBox(height: 24),

            // New section for Opening Hours
            _buildOpeningHours(context),
            const SizedBox(height: 24),

            // 5. Order Tracking
            const OrderStatusAnimator(),
          ],
        ),
      ),
    );
  }

  // New method for the "+ Nuevo Pedido" button
  Widget _buildNewOrderButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: () {
          context.push('/encargo');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // As per user request for a red button
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text(
          '+ Nuevo Pedido',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // New placeholder method for "Horarios de Hoy"
  Widget _buildTodaySchedules(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horarios de Hoy',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Example schedule card
        Card(
          elevation: 2, // Use elevation for shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: theme.cardColor,
          child: const ListTile(
            title: Text(
              'Entrega a cliente',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('10:30 AM', style: TextStyle(color: Colors.grey)),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // Method to build the new Opening Hours section
  Widget _buildOpeningHours(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horario de la Florería',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lunes a Viernes',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    Text('9:00 AM - 6:00 PM', style: GoogleFonts.poppins()),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sábados',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    Text('10:00 AM - 2:00 PM', style: GoogleFonts.poppins()),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Domingos',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Cerrado',
                      style: GoogleFonts.poppins(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context) {
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
          headerPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
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
      ),
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
}
