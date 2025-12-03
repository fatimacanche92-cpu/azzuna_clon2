import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../domain/models/order_model.dart';
import '../providers/order_provider.dart';

class ShippingOrdersPage extends ConsumerWidget {
  const ShippingOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider);

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
      body: ordersAsync.when(
        data: (orders) {
          final shippingOrders = orders
              .where(
                (order) => order.deliveryType == OrderDeliveryType.envio,
              )
              .toList();

          if (shippingOrders.isEmpty) {
            return const Center(child: Text('No hay pedidos para enviar.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: shippingOrders.length,
            itemBuilder: (context, index) {
              final order = shippingOrders[index];
              return _ShippingOrderItem(order: order);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(statusStyle),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _toggleExpanded,
                child: Text(_isExpanded ? 'Ocultar detalles' : 'Ver detalles'),
              ),
            ),
            _buildAnimatedDetails(),
          ],
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
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
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
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
      crossFadeState: _isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
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
          // Dirección real (si está disponible)
          if (widget.order.deliveryAddress != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(child: Text(widget.order.deliveryAddress!)),
                  IconButton(
                    onPressed: () {
                      final encoded = Uri.encodeComponent(widget.order.deliveryAddress!);
                      final url = 'https://www.google.com/maps/search/?api=1&query=$encoded';
                      launchUrlString(url);
                    },
                    icon: const Icon(Icons.map, color: Colors.blue),
                  ),
                ],
              ),
            )
          else
            _buildDetailRow('Dirección', 'No especificada'),
          _buildDetailRow(
            'Teléfono',
            widget.order.clientPhone ?? 'No disponible',
          ),
          _buildDetailRow(
            'Tipo de Flor',
            widget.order.arrangementFlowerType ?? 'No especificado',
          ),
          _buildDetailRow(
            'Tamaño',
            widget.order.arrangementSize ?? 'No especificado',
          ),
          _buildDetailRow('Nota', widget.order.publicNote ?? 'Sin notas'),
          _buildDetailRow(
            'Precio',
            '\$${widget.order.price.toStringAsFixed(2)}',
          ),
          _buildDetailRow(
            'Estado del Pago',
            widget.order.paymentStatus.toString().split('.').last,
          ),
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
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
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
