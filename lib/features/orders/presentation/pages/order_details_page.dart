import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/order_model.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsPage({super.key, required this.order});

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'DETALLES DEL PEDIDO',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
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
              order.deliveryType == OrderDeliveryType.envio
                  ? 'Envío'
                  : 'Por recoger',
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
      ),
    );
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
}
