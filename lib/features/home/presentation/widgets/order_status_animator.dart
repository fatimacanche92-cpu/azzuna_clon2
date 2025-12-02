import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:google_fonts/google_fonts.dart';

// Enum to represent the different stages of the order, moved from old widget
enum OrderStatus {
  recibido, // Received (Semilla) -> 0.0
  preparando, // Preparing (Brote) -> 1.0
  enRuta, // On the way (Tallo) -> 2.0
  entregado, // Delivered (Tulipán) -> 3.0
}

// Simple data class for dummy data
class OrderInfo {
  final String id;
  final String clientName;
  final double cost;
  final String estimatedTime;
  final OrderStatus status;

  OrderInfo({
    required this.id,
    required this.clientName,
    required this.cost,
    required this.estimatedTime,
    required this.status,
  });
}

class OrderStatusAnimator extends StatefulWidget {
  const OrderStatusAnimator({super.key});

  @override
  State<OrderStatusAnimator> createState() => _OrderStatusAnimatorState();
}

class _OrderStatusAnimatorState extends State<OrderStatusAnimator> {
  OrderInfo? _selectedOrder;

  // Dummy data for demonstration
  final List<OrderInfo> _orders = [
    OrderInfo(
      id: '0001',
      clientName: 'Ana López',
      cost: 650.0,
      estimatedTime: '11:00 AM',
      status: OrderStatus.recibido,
    ),
    OrderInfo(
      id: '0002',
      clientName: 'Carlos Pérez',
      cost: 420.0,
      estimatedTime: '1:30 PM',
      status: OrderStatus.preparando,
    ),
    OrderInfo(
      id: '0003',
      clientName: 'Mariana Flores',
      cost: 890.0,
      estimatedTime: '4:00 PM',
      status: OrderStatus.enRuta,
    ),
    OrderInfo(
      id: '0004',
      clientName: 'Jorge Campos',
      cost: 300.0,
      estimatedTime: 'Entregado',
      status: OrderStatus.entregado,
    ),
  ];

  void _selectOrder(OrderInfo order) {
    setState(() {
      _selectedOrder = order;
    });
  }

  void _unselectOrder() {
    setState(() {
      _selectedOrder = null;
    });
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.recibido:
        return 'Pedido Recibido';
      case OrderStatus.preparando:
        return 'Preparando';
      case OrderStatus.enRuta:
        return 'En Ruta';
      case OrderStatus.entregado:
        return 'Entregado';
    }
  }

  // Maps OrderStatus to a double value for the animation tween
  double _getAnimationTarget(OrderStatus status) {
    return status.index.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _selectedOrder == null
          ? _buildOrderListView()
          : _buildAnimationView(_selectedOrder!),
    );
  }

  Widget _buildOrderListView() {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('order-list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seguimiento de Pedidos',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  'Pedido #${order.id}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Cliente: ${order.clientName} - \$${order.cost.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => _selectOrder(order),
                tileColor: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimationView(OrderInfo order) {
    final theme = Theme.of(context);
    return Container(
      key: ValueKey('animation-view-${order.id}'),
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _unselectOrder,
              ),
              Flexible(
                child: Text(
                  'Pedido #${order.id} – ${_getStatusText(order.status)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 40), // To balance the back button
            ],
          ),
          const SizedBox(height: 30),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0.0,
              end: _getAnimationTarget(order.status),
            ),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOutCubic,
            builder: (context, value, child) {
              return CustomPaint(
                size: const Size(100, 150),
                painter: TulipPainter(progress: value),
              );
            },
          ),

          const SizedBox(height: 30),
          Text(
            'Cliente: ${order.clientName}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Costo Total: \$${order.cost.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            'Hora Estimada: ${order.estimatedTime}',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class TulipPainter extends CustomPainter {
  final double
  progress; // Overall progress from 0.0 (seed) to 3.0 (full flower)

  TulipPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final paint = Paint()..style = PaintingStyle.fill;

    // Stage 0: Seed (progress 0.0)
    final seedPaint = paint..color = const Color(0xFF8B4513); // Brown
    final seedRadius =
        5.0 * (1.0 - math.min(1.0, progress)); // Shrinks as it grows
    if (seedRadius > 0) {
      canvas.drawCircle(
        Offset(center.dx, center.dy - 5),
        seedRadius,
        seedPaint,
      );
    }

    // Stage 1: Sprout (progress 0.0 -> 1.0)
    if (progress > 0.0) {
      final sproutProgress = math.min(1.0, progress);
      final sproutPaint = paint..color = const Color(0xFF90EE90); // Light Green
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(
        center.dx + 10 * sproutProgress,
        center.dy - 20 * sproutProgress,
        center.dx,
        center.dy - 30 * sproutProgress,
      );
      path.quadraticBezierTo(
        center.dx - 10 * sproutProgress,
        center.dy - 20 * sproutProgress,
        center.dx,
        center.dy,
      );
      canvas.drawPath(path, sproutPaint);
    }

    // Stage 2: Stem growth (progress 1.0 -> 2.0)
    if (progress > 1.0) {
      final stemProgress = math.min(1.0, progress - 1.0);
      final stemPaint = paint..color = const Color(0xFF228B22); // Forest Green
      final stemHeight = 30 + 70 * stemProgress; // Grows from sprout height

      // Stem
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy - stemHeight / 2),
            width: 6,
            height: stemHeight,
          ),
          const Radius.circular(3),
        ),
        stemPaint,
      );

      // Leaf
      final leafPath = Path();
      leafPath.moveTo(center.dx + 3, center.dy - 30);
      leafPath.quadraticBezierTo(
        center.dx + 25 * stemProgress,
        center.dy - 50,
        center.dx + 3,
        center.dy - 70 - 10 * stemProgress,
      );
      canvas.drawPath(leafPath, stemPaint);
    }

    // Stage 3: Tulip bloom (progress 2.0 -> 3.0)
    if (progress > 2.0) {
      final bloomProgress = math.min(1.0, progress - 2.0);
      final flowerColor = Color.lerp(
        const Color(0xFF90EE90),
        const Color(0xFF8667f2),
        bloomProgress,
      )!; // Original Theme Purple
      final topOfStem = Offset(center.dx, center.dy - 100);

      canvas.save();
      canvas.translate(topOfStem.dx, topOfStem.dy);
      canvas.scale(bloomProgress); // Petals grow in size
      canvas.translate(-topOfStem.dx, -topOfStem.dy);

      final petalPaint = Paint()
        ..color = flowerColor
        ..style = PaintingStyle.fill;

      // Draw 3 main petals
      for (int i = 0; i < 3; i++) {
        canvas.save();
        canvas.translate(topOfStem.dx, topOfStem.dy);
        canvas.rotate(
          i * 2 * math.pi / 3 + (math.pi / 6),
        ); // Added rotation for aesthetics
        canvas.translate(-topOfStem.dx, -topOfStem.dy);

        final p = Path();
        p.moveTo(topOfStem.dx, topOfStem.dy - 5);
        p.cubicTo(
          topOfStem.dx - 30,
          topOfStem.dy - 20,
          topOfStem.dx - 10,
          topOfStem.dy - 60,
          topOfStem.dx,
          topOfStem.dy - 45,
        );
        p.cubicTo(
          topOfStem.dx + 10,
          topOfStem.dy - 60,
          topOfStem.dx + 30,
          topOfStem.dy - 20,
          topOfStem.dx,
          topOfStem.dy - 5,
        );
        canvas.drawPath(p, petalPaint);

        canvas.restore();
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant TulipPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
