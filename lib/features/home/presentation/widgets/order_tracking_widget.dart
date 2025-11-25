import 'package:flutter/material.dart';
import 'dart:math' as math;

// Enum to represent the different stages of the order
enum OrderStatus {
  recibido,    // Received (Semilla)
  preparando,  // Preparing (Brote)
  enCamino,    // On the way (Tallo)
  entregado,   // Delivered (Tulipán)
}

class OrderTrackingWidget extends StatefulWidget {
  const OrderTrackingWidget({super.key});

  @override
  State<OrderTrackingWidget> createState() => _OrderTrackingWidgetState();
}

class _OrderTrackingWidgetState extends State<OrderTrackingWidget> {
  OrderStatus _currentStatus = OrderStatus.recibido;

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.recibido: return 'Pedido Recibido';
      case OrderStatus.preparando: return 'Preparando';
      case OrderStatus.enCamino: return 'En camino';
      case OrderStatus.entregado: return 'Entregado';
    }
  }
  
  // Maps OrderStatus to a double value for the animation tween
  double _getAnimationTarget(OrderStatus status) {
    switch (status) {
      case OrderStatus.recibido: return 0.0;
      case OrderStatus.preparando: return 1.0;
      case OrderStatus.enCamino: return 2.0;
      case OrderStatus.entregado: return 3.0;
    }
  }

  void _progressStatus() {
    setState(() {
      final nextIndex = (_currentStatus.index + 1) % OrderStatus.values.length;
      _currentStatus = OrderStatus.values[nextIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
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
          children: [
            Text(
              'Pedido #00025 – ${_getStatusText(_currentStatus)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            
            // Animated Tulip using TweenAnimationBuilder and CustomPainter
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: _getAnimationTarget(_currentStatus)),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOutCubic,
              builder: (context, value, child) {
                return CustomPaint(
                  size: const Size(100, 150),
                  painter: TulipPainter(progress: value),
                );
              },
            ),

            const SizedBox(height: 30),
            const Text(
              'Entrega estimada: 3:45 PM',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            // Button to simulate order progress
            ElevatedButton(
              onPressed: _progressStatus,
              child: const Text('Simular Avance del Pedido'),
            ),
          ],
        ),
      ),
    );
  }
}

class TulipPainter extends CustomPainter {
  final double progress; // Overall progress from 0.0 (seed) to 3.0 (full flower)

  TulipPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final paint = Paint()..style = PaintingStyle.fill;

    // Stage 0: Seed (progress 0.0)
    final seedPaint = paint..color = const Color(0xFF8B4513); // Brown
    final seedRadius = 5.0 * (1.0 - math.min(1.0, progress)); // Shrinks as it grows
    if (seedRadius > 0) {
      canvas.drawCircle(Offset(center.dx, center.dy - 5), seedRadius, seedPaint);
    }

    // Stage 1: Sprout (progress 0.0 -> 1.0)
    if (progress > 0.0) {
      final sproutProgress = math.min(1.0, progress);
      final sproutPaint = paint..color = const Color(0xFF90EE90); // Light Green
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(
        center.dx + 10 * sproutProgress, center.dy - 20 * sproutProgress,
        center.dx, center.dy - 30 * sproutProgress
      );
      path.quadraticBezierTo(
        center.dx - 10 * sproutProgress, center.dy - 20 * sproutProgress,
        center.dx, center.dy
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
          Rect.fromCenter(center: Offset(center.dx, center.dy - stemHeight/2), width: 6, height: stemHeight),
          const Radius.circular(3)
        ), 
        stemPaint
      );
      
      // Leaf
      final leafPath = Path();
      leafPath.moveTo(center.dx + 3, center.dy - 30);
      leafPath.quadraticBezierTo(
        center.dx + 25 * stemProgress, center.dy - 50,
        center.dx + 3, center.dy - 70 - 10 * stemProgress
      );
      canvas.drawPath(leafPath, stemPaint);
    }

    // Stage 3: Tulip bloom (progress 2.0 -> 3.0)
    if (progress > 2.0) {
      final bloomProgress = math.min(1.0, progress - 2.0);
      final flowerColor = Color.lerp(const Color(0xFF90EE90), const Color(0xFFFF69B4), bloomProgress)!; // Light Green to Hot Pink
      final topOfStem = Offset(center.dx, center.dy - 100);

      canvas.save();
      canvas.translate(topOfStem.dx, topOfStem.dy);
      canvas.scale(bloomProgress); // Petals grow in size
      canvas.translate(-topOfStem.dx, -topOfStem.dy);
      
      final petalPaint = Paint()
        ..color = flowerColor
        ..style = PaintingStyle.fill;
      
      // Draw 3 main petals
      for (int i=0; i<3; i++) {
        canvas.save();
        canvas.translate(topOfStem.dx, topOfStem.dy);
        canvas.rotate(i * 2 * math.pi / 3);
        canvas.translate(-topOfStem.dx, -topOfStem.dy);

        final p = Path();
        p.moveTo(topOfStem.dx, topOfStem.dy - 5);
        p.cubicTo(
          topOfStem.dx - 30, topOfStem.dy - 20,
          topOfStem.dx - 10, topOfStem.dy - 60,
          topOfStem.dx, topOfStem.dy - 45
        );
        p.cubicTo(
          topOfStem.dx + 10, topOfStem.dy - 60,
          topOfStem.dx + 30, topOfStem.dy - 20,
          topOfStem.dx, topOfStem.dy - 5
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
