import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../data/hive/hive_initializer.dart';
import '../../data/models/supplier_model.dart';

class SupplierListScreen extends StatelessWidget {
  const SupplierListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<SupplierModel>(HiveBoxes.suppliers);
    final suppliers = box.values.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🤝 Suppliers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: suppliers.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🤝', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(
                    'No suppliers yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suppliers.length,
              itemBuilder: (_, i) {
                final s = suppliers[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGradientStart
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryGradientStart,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.star_rounded,
                                        size: 16, color: AppColors.warning),
                                    const SizedBox(width: 4),
                                    Text(
                                      s.reliabilityScore.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${s.avgDeliveryDays}d delivery',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (s.productIds.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${s.productIds.length} products supplied',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
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
