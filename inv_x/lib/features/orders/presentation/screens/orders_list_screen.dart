import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../data/hive/hive_initializer.dart';
import '../../data/models/purchase_order_model.dart';
import '../../../suppliers/data/models/supplier_model.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersBox = Hive.box<PurchaseOrderModel>(HiveBoxes.purchaseOrders);
    final suppliersBox = Hive.box<SupplierModel>(HiveBoxes.suppliers);
    final orders = ordersBox.values.toList()
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🛒 Purchase Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final order = orders[i];
                final supplier = suppliersBox.get(order.supplierId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _StatusBadge(order.status),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Order #${order.id.substring(0, 8)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (order.isAiGenerated)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '🤖 AI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (supplier != null)
                          Text(
                            'From: ${supplier.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${order.items.length} items',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ordered: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  Color get _color {
    switch (status.toUpperCase()) {
      case 'RECEIVED':
        return AppColors.success;
      case 'SHIPPED':
        return AppColors.info;
      case 'CONFIRMED':
        return AppColors.primaryGradientStart;
      case 'PENDING':
        return AppColors.warning;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}
