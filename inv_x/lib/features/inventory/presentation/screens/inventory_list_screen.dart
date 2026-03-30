import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../data/hive/hive_initializer.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  bool _gridView = false;

  @override
  Widget build(BuildContext context) {
    final productsBox = Hive.box<ProductModel>(HiveBoxes.products);
    final categoriesBox = Hive.box<CategoryModel>(HiveBoxes.categories);

    var products = productsBox.values.toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.sku.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query))
          .toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      products =
          products.where((p) => p.categoryId == _selectedCategory).toList();
    }

    final categories = categoriesBox.values.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text('📦', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    'Inventory',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGradientStart
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${products.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGradientStart,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _gridView ? Icons.list_rounded : Icons.grid_view_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _gridView = !_gridView),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchField(
                hintText: 'Search products...',
                onChanged: (q) => setState(() => _searchQuery = q),
              ),
            ),

            const SizedBox(height: 8),

            // Category filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedCategory == null,
                    onTap: () =>
                        setState(() => _selectedCategory = null),
                  ),
                  ...categories.map((c) => _FilterChip(
                        label: '${c.emoji} ${c.name}',
                        isSelected: _selectedCategory == c.id,
                        onTap: () =>
                            setState(() => _selectedCategory = c.id),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Product list / grid
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📦', style: TextStyle(fontSize: 56)),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No products match your search'
                                : 'No products yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first product!',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _gridView
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: products.length,
                          itemBuilder: (_, i) =>
                              _ProductGridCard(product: products[i]),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: products.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ProductListTile(product: products[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/inventory/add'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final ProductModel product;
  const _ProductListTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final stockPercent = product.stockPercentage / 100;

    return GlassCard(
      onTap: () => context.go('/inventory/${product.id}'),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryGradientStart.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                product.name.isNotEmpty
                    ? product.name[0].toUpperCase()
                    : 'P',
                style: TextStyle(
                  fontSize: 20,
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
                  product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'SKU: ${product.sku}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                // Stock bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
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
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${product.currentStock}/${product.maximumStock}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${product.sellingPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (product.isLowStock)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Low',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final ProductModel product;
  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final stockPercent = product.stockPercentage / 100;

    return GlassCard(
      onTap: () => context.go('/inventory/${product.id}'),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.surfaceGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                product.name.isNotEmpty
                    ? product.name[0].toUpperCase()
                    : 'P',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGradientStart,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
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
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${product.currentStock} ${product.unit}',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          const Spacer(),
          Text(
            '₹${product.sellingPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (product.isLowStock)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '⚠️ Low Stock',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
