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
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: _OrderSummary(order: order),
        children: [_OrderDetails(order: order)],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _getStatusStyle(order);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
      return {'color': Colors.purple, 'text': 'Por Recoger'};
    }
  }
}

class _OrderDetails extends StatelessWidget {
  final OrderModel order;

  const _OrderDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    String paymentStatusText;
    Color paymentStatusColor;

    switch (order.paymentStatus) {
      case OrderPaymentStatus.pagado:
        paymentStatusText = 'Pagado';
        paymentStatusColor = Colors.green;
        break;
      case OrderPaymentStatus.conAnticipo:
        paymentStatusText = 'Con anticipo';
        paymentStatusColor = Colors.orange;
        break;
      case OrderPaymentStatus.pendiente:
        paymentStatusText = 'Pendiente';
        paymentStatusColor = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('CLIENTE'),
          _buildDetailRow('Nombre:', order.clientName),
          if (order.clientPhone != null)
            _buildDetailRow('Teléfono:', order.clientPhone!),
          _buildDetailRow(
            'Entrega:',
            order.deliveryType == OrderDeliveryType.envio ? 'Envío' : 'Por recoger',
          ),
          _buildDetailRow(
            'Fecha:',
            DateFormat.yMMMd().format(order.scheduledDate),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('ARREGLO'),
          _buildDetailRow('Tipo:', order.arrangementType),
          if (order.arrangementSize != null)
            _buildDetailRow('Tamaño:', order.arrangementSize!),
          if (order.arrangementColor != null)
            _buildDetailRow('Color:', order.arrangementColor!),
          if (order.arrangementFlowerType != null)
            _buildDetailRow('Tipo de flor:', order.arrangementFlowerType!),
          _buildDetailRow('Precio:', '\$${order.price.toStringAsFixed(2)}'),
          const SizedBox(height: 24),
          _buildSectionTitle('PAGO'),
          _buildDetailRow(
            'Estado:',
            paymentStatusText,
            valueColor: paymentStatusColor,
          ),
          if (order.paymentStatus == OrderPaymentStatus.conAnticipo) ...[
            _buildDetailRow(
              'Anticipo:',
              '\$${order.downPayment!.toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              'Restante:',
              '\$${order.remainingAmount!.toStringAsFixed(2)}',
            ),
          ],
          const SizedBox(height: 24),
          if (order.publicNote != null && order.publicNote!.isNotEmpty) ...[
            _buildSectionTitle('NOTA'),
            Text(order.publicNote!, style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 24),
          ],
          if (order.deliveryType != OrderDeliveryType.envio)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle "Marcar como Recogido" action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Marcar como Recogido',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.grey[700],
      ),
    ),
  );
}

Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}
