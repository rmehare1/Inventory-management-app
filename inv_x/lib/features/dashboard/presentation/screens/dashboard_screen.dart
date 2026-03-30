import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../../../../data/hive/hive_initializer.dart';
import '../../../../features/inventory/data/models/product_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsBox = Hive.box<ProductModel>(HiveBoxes.products);

    final products = productsBox.values.toList();
    final totalProducts = products.length;
    final totalValue = products.fold<double>(
      0,
      (sum, p) => sum + (p.currentStock * p.costPrice),
    );
    final lowStock = products.where((p) => p.isLowStock).length;
    final expiring = products.where((p) => p.isExpiringSoon).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Text('🏪 ', style: TextStyle(fontSize: 24)),
                    const GradientText(
                      'INV-X',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      color: AppColors.textSecondary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Stat Cards Row
            SliverToBoxAdapter(
              child: SizedBox(
                height: 125,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _StatCard(
                      emoji: '📦',
                      label: 'Total Products',
                      value: '$totalProducts',
                      color: AppColors.info,
                    ),
                    _StatCard(
                      emoji: '💰',
                      label: 'Stock Value',
                      value: '₹${_formatValue(totalValue)}',
                      color: AppColors.success,
                    ),
                    _StatCard(
                      emoji: '⚠️',
                      label: 'Low Stock',
                      value: '$lowStock',
                      color: AppColors.warning,
                    ),
                    _StatCard(
                      emoji: '⏰',
                      label: 'Expiring',
                      value: '$expiring',
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // AI Insight Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCardGradientBorder(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🤖', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          const GradientText(
                            'AI Insight',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Demo Mode',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        lowStock > 0
                            ? '📊 You have $lowStock products below minimum '
                                  'stock levels and $expiring products expiring '
                                  'soon. Consider placing restock orders for '
                                  'critical items.'
                            : '✅ Your inventory is in great shape! All '
                                  'products are above minimum stock levels.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _ActionChip(label: '🔄 Refresh', onTap: () {}),
                          const SizedBox(width: 8),
                          _ActionChip(
                            label: '💬 Ask More',
                            onTap: () => context.go('/ai-chat'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Low Stock Alerts
            if (lowStock > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🚨', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'Needs Attention',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$lowStock',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...products
                            .where((p) => p.isLowStock)
                            .take(5)
                            .map((p) => _LowStockTile(product: p)),
                      ],
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Quick Actions Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _QuickAction(
                          emoji: '📦',
                          label: 'Add Product',
                          onTap: () => context.go('/inventory/add'),
                        ),
                        _QuickAction(
                          emoji: '🤖',
                          label: 'AI Chat',
                          onTap: () => context.go('/ai-chat'),
                        ),
                        _QuickAction(
                          emoji: '🔮',
                          label: 'Forecast',
                          onTap: () => context.push('/forecast'),
                        ),
                        _QuickAction(
                          emoji: '🚨',
                          label: 'Anomalies',
                          onTap: () => context.push('/anomalies'),
                        ),
                        _QuickAction(
                          emoji: '📊',
                          label: 'Reports',
                          onTap: () => context.go('/reports'),
                        ),
                        _QuickAction(
                          emoji: '🤝',
                          label: 'Suppliers',
                          onTap: () => context.push('/suppliers'),
                        ),
                        _QuickAction(
                          emoji: '🛒',
                          label: 'Orders',
                          onTap: () => context.push('/orders'),
                        ),
                        _QuickAction(
                          emoji: '⚙️',
                          label: 'Settings',
                          onTap: () => context.go('/more'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GlassCard(
        width: 150,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _LowStockTile extends StatelessWidget {
  final ProductModel product;
  const _LowStockTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final percentage = product.stockPercentage / 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                      percentage < 0.25 ? AppColors.error : AppColors.warning,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${product.currentStock}/${product.minimumStock}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
