import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../data/hive/hive_initializer.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ProductModel>(HiveBoxes.products);
    final product = box.get(productId);

    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Product')),
        body: const Center(child: Text('Product not found')),
      );
    }

    final catBox = Hive.box<CategoryModel>(HiveBoxes.categories);
    final category = catBox.get(product.categoryId);
    final stockPercent = product.stockPercentage / 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(product.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.error,
            onPressed: () => _deleteProduct(context, product),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          product.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _Badge(product.sku, AppColors.info),
                              const SizedBox(width: 8),
                              if (category != null)
                                _Badge(
                                  '${category.emoji} ${category.name}',
                                  Color(int.parse(
                                    category.colorHex.replaceFirst('#', '0xFF'),
                                  )),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pricing card
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PriceColumn('Cost', '₹${product.costPrice.toStringAsFixed(0)}'),
                Container(width: 1, height: 40, color: AppColors.border),
                _PriceColumn('Sell', '₹${product.sellingPrice.toStringAsFixed(0)}'),
                Container(width: 1, height: 40, color: AppColors.border),
                _PriceColumn(
                  'Margin',
                  '${product.profitMargin.toStringAsFixed(1)}%',
                  color: product.profitMargin >= 20
                      ? AppColors.success
                      : product.profitMargin >= 10
                          ? AppColors.warning
                          : AppColors.error,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stock card
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock Level',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${product.currentStock}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      ' / ${product.maximumStock} ${product.unit}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stockPercent,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                      stockPercent < 0.25
                          ? AppColors.error
                          : stockPercent < 0.5
                              ? AppColors.warning
                              : AppColors.success,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Min: ${product.minimumStock} | Max: ${product.maximumStock}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                if (product.isLowStock)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '⚠️ Below minimum stock level',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Details card
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                if (product.description.isNotEmpty)
                  _DetailRow('Description', product.description),
                if (product.barcode != null)
                  _DetailRow('Barcode', product.barcode!),
                if (product.warehouseLocation != null)
                  _DetailRow('Location', product.warehouseLocation!),
                if (product.batchNumber != null)
                  _DetailRow('Batch', product.batchNumber!),
                if (product.expiryDate != null)
                  _DetailRow(
                    'Expires',
                    '${product.expiryDate!.day}/${product.expiryDate!.month}/${product.expiryDate!.year}',
                  ),
                if (product.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: product.tags
                          .map((t) => Chip(
                                label: Text(t, style: const TextStyle(fontSize: 11)),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await product.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🗑️ ${product.name} deleted')),
      );
      context.pop();
    }
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PriceColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _PriceColumn(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
