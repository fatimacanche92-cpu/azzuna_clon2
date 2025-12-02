import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../orders/presentation/providers/order_provider.dart';

/// Vista principal de inicio
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipping = ref.watch(shippingOrdersProvider);
    final pickup = ref.watch(pickupOrdersProvider);

    final shippingCount = shipping.length;
    final pickupCount = pickup.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y subtítulo
          const Text(
            'Inicio',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Descubre tus arreglos florales',
            style: TextStyle(fontSize: 16, color: AppColors.textLight),
          ),
          const SizedBox(height: 24),

          // Sección destacados
          const Text(
            'Destacados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Cards de destacados
          _buildFeaturedCard(
            title: 'Rosas Románticas',
            badge: 'Nuevo',
            isNew: true,
          ),
          const SizedBox(height: 12),
          _buildFeaturedCard(
            title: 'Flores para Bodas',
            badge: 'Tendencia',
            isNew: false,
          ),
          const SizedBox(height: 12),
          _buildFeaturedCard(
            title: 'Girasoles Alegres',
            badge: 'Nuevo',
            isNew: true,
          ),
          const SizedBox(height: 24),

          // Sección Pedidos rápida (conteos por tipo)
          const Text(
            'Pedidos rápidos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOrderCard(
                  context: context,
                  title: 'Por envío',
                  count: shippingCount,
                  onTap: () => GoRouter.of(context).go('/shipping-orders'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOrderCard(
                  context: context,
                  title: 'Por recoger',
                  count: pickupCount,
                  onTap: () => GoRouter.of(context).go('/pickup-orders'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Estadísticas rápidas (mantener otras métricas si se desea)
          Row(
            children: [
              Expanded(
                child: _buildStatCard(value: '24', label: 'Arreglos'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(value: '8', label: 'Eventos'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(value: '12', label: 'Regalos'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard({
    required String title,
    required String badge,
    required bool isNew,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen placeholder
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.purpleLight.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.local_florist,
                    size: 64,
                    color: AppColors.accentPurple.withValues(alpha: 0.3),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isNew
                          ? AppColors.primaryMagenta
                          : AppColors.secondaryCoral,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isNew ? Icons.auto_awesome : Icons.trending_up,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMagenta,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ver pedidos',
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textLight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.accentPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
