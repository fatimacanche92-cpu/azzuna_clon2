import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../domain/models/order_model.dart';
import '../providers/order_provider.dart';

class PickupOrdersPage extends ConsumerWidget {
  const PickupOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '🛍️ Pedidos por Recoger',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ordersAsync.when(
        data: (orders) {
          final pickupOrders = orders
              .where(
                (order) => order.deliveryType == OrderDeliveryType.recoger,
              )
              .toList();

          if (pickupOrders.isEmpty) {
            return const Center(
              child: Text('No hay pedidos para recoger.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: pickupOrders.length,
            itemBuilder: (context, index) {
              final order = pickupOrders[index];
              return _PickupOrderItem(order: order);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _PickupOrderItem extends StatefulWidget {
  final OrderModel order;

  const _PickupOrderItem({required this.order});

  @override
  State<_PickupOrderItem> createState() => _PickupOrderItemState();
}

class _PickupOrderItemState extends State<_PickupOrderItem> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    String paymentStatusText;
    Color paymentStatusColor;

    switch (widget.order.paymentStatus) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Card Header ---
            Text(
              'Cliente: ${widget.order.clientName}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Arreglo: ${widget.order.arrangementType}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            Text(
              'Precio: \$${widget.order.price.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Estado de pago: ',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                Text(
                  paymentStatusText,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: paymentStatusColor,
                  ),
                ),
              ],
            ),
            if (widget.order.paymentStatus == OrderPaymentStatus.conAnticipo)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '(Anticipo: \$${widget.order.downPayment!.toStringAsFixed(2)}, Restante: \$${widget.order.remainingAmount!.toStringAsFixed(2)})',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _toggleExpanded,
                child: Text(_isExpanded ? 'Ocultar detalles' : 'Ver detalles'),
              ),
            ),
            // --- Animated Details ---
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: _buildDetailsView(context),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
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
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView(BuildContext context) {
    final order = widget.order;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(thickness: 1, height: 24),
          _buildDetailRow('Teléfono', order.clientPhone ?? 'No proporcionado'),
          _buildDetailRow('Dirección', 'Por recoger en tienda'),
          if (order.deliveryAddress != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(child: Text(order.deliveryAddress!)),
                  IconButton(
                    onPressed: () {
                      final encoded = Uri.encodeComponent(order.deliveryAddress!);
                      final url = 'https://www.google.com/maps/search/?api=1&query=$encoded';
                      launchUrlString(url);
                    },
                    icon: const Icon(Icons.map, color: Colors.blue),
                  ),
                ],
              ),
            ),
          _buildDetailRow('Tipo de Entrega', 'Recoger en Tienda'),
          _buildDetailRow(
            'Tamaño Arreglo',
            order.arrangementSize ?? 'No especificado',
          ),
          _buildDetailRow('Color', order.arrangementColor ?? 'No especificado'),
          _buildDetailRow(
            'Tipo de Flor',
            order.arrangementFlowerType ?? 'No especificado',
          ),
          _buildDetailRow(
            'Nota',
            (order.publicNote?.isNotEmpty ?? false)
                ? order.publicNote!
                : 'Sin nota',
          ),
          const SizedBox.shrink(), // Removed GiftCardGenerator from here
        ],
      ),
    );
  }
}
