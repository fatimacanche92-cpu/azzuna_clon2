import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/order_model.dart';

class ShippingOrdersPage extends StatelessWidget {
  const ShippingOrdersPage({super.key});

  // Dummy data for demonstration
  static final List<OrderModel> _shippingOrders = [
    OrderModel(
      id: '001',
      clientName: 'Cliente Ejemplo 1',
      arrangementType: 'Arreglo Floral',
      scheduledDate: DateTime.now(),
      deliveryType: OrderDeliveryType.envio,
      shippingStatus: OrderShippingStatus.enEspera,
      paymentStatus: OrderPaymentStatus.pagado,
      price: 50.0,
      clientPhone: '555-123-4567',
      arrangementFlowerType: 'Rosas',
      arrangementSize: 'Mediano',
      publicNote: 'Entregar en recepción.',
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
      clientPhone: '555-987-6543',
      arrangementFlowerType: 'Rosas',
      arrangementSize: 'Grande',
      publicNote: 'Llamar al llegar.',
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
      clientPhone: '555-555-5555',
      arrangementFlowerType: 'Girasoles',
      arrangementSize: 'Chico',
      publicNote: 'Dejar en la puerta.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '📦 Pedidos en Envío',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _shippingOrders.length,
        itemBuilder: (context, index) {
          final order = _shippingOrders[index];
          return _ShippingOrderItem(order: order);
        },
      ),
    );
  }
}

class _ShippingOrderItem extends StatefulWidget {
  final OrderModel order;

  const _ShippingOrderItem({required this.order});

  @override
  State<_ShippingOrderItem> createState() => _ShippingOrderItemState();
}

class _ShippingOrderItemState extends State<_ShippingOrderItem> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = _getStatusStyle(widget.order.shippingStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _toggleExpanded,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(statusStyle),
              _buildAnimatedDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(Map<String, dynamic> statusStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pedido #${widget.order.id}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cliente: ${widget.order.clientName}',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        Text(
          'Arreglo: ${widget.order.arrangementType}',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fecha: ${DateFormat.yMMMd().format(widget.order.scheduledDate)}',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusStyle['color'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusStyle['text']!,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: statusStyle['color'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedDetails() {
    return AnimatedCrossFade(
      firstChild: const SizedBox(height: 16),
      secondChild: _buildDetailsView(),
      crossFadeState:
          _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildDetailsView() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          _buildDetailRow('Dirección', 'Calle Falsa 123, Colonia Inventada'), // Dummy data
          _buildDetailRow('Teléfono', widget.order.clientPhone ?? 'No disponible'),
          _buildDetailRow('Tipo de Flor', widget.order.arrangementFlowerType ?? 'No especificado'),
          _buildDetailRow('Tamaño', widget.order.arrangementSize ?? 'No especificado'),
          _buildDetailRow('Nota', widget.order.publicNote ?? 'Sin notas'),
          _buildDetailRow('Precio', '\$${widget.order.price.toStringAsFixed(2)}'),
          _buildDetailRow('Estado del Pago', widget.order.paymentStatus.toString().split('.').last),
          _buildDetailRow('Info. Arreglo', widget.order.arrangementType),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusStyle(OrderShippingStatus? status) {
    switch (status) {
      case OrderShippingStatus.enEspera:
        return {'color': Colors.orange, 'text': 'En espera'};
      case OrderShippingStatus.enCamino:
        return {'color': Colors.blue, 'text': 'En camino'};
      case OrderShippingStatus.entregado:
        return {'color': Colors.green, 'text': 'Entregado'};
      default:
        return {'color': Colors.grey, 'text': 'Desconocido'};
    }
  }
}
