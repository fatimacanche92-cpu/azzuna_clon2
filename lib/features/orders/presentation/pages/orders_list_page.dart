import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/order_model.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  // Dummy data combining different order types
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Encargos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _allOrders.length,
        itemBuilder: (context, index) {
          final order = _allOrders[index];
          return _OrderItem(order: order);
        },
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final OrderModel order;

  const _OrderItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusStyle = _getStatusStyle(order);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/order-details', extra: order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pedido #${order.id}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Icon(
                    order.deliveryType == OrderDeliveryType.envio
                        ? Icons.local_shipping_outlined
                        : Icons.store_outlined,
                    color: Colors.grey[700],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Cliente: ${order.clientName}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              Text(
                'Arreglo: ${order.arrangementType}',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha: ${DateFormat.yMMMd().format(order.scheduledDate)}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusStyle['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusStyle['text']!,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: statusStyle['color'],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusStyle(OrderModel order) {
    if (order.deliveryType == OrderDeliveryType.envio) {
      switch (order.shippingStatus) {
        case OrderShippingStatus.enEspera:
          return {'color': Colors.orange, 'text': 'En espera'};
        case OrderShippingStatus.enCamino:
          return {'color': Colors.blue, 'text': 'En camino'};
        case OrderShippingStatus.entregado:
          return {'color': Colors.green, 'text': 'Entregado'};
        default:
          return {'color': Colors.grey, 'text': 'Desconocido'};
      }
    } else {
      // Assuming 'recoger' status is based on payment or another field
      return {'color': Colors.purple, 'text': 'Por Recoger'};
    }
  }
}
