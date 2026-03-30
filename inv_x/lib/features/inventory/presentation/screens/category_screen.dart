import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

import '../../../../data/hive/hive_initializer.dart';
import '../../data/models/category_model.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📂 Categories'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable:
            Hive.box<CategoryModel>(HiveBoxes.categories).listenable(),
        builder: (context, Box<CategoryModel> box, _) {
          final categories = box.values.toList();
          if (categories.isEmpty) {
            return const Center(child: Text('No categories yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                            cat.colorHex.replaceFirst('#', '0xFF'),
                          )).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child:
                              Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (cat.parentId != null)
                              Text(
                                'Sub-category',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        color: AppColors.error,
                        onPressed: () => _deleteCategory(context, cat),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String emoji = '📦';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name *'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final cat = CategoryModel(
                id: const Uuid().v4(),
                name: nameCtrl.text.trim(),
                emoji: emoji,
                colorHex: '#6C63FF',
                createdAt: DateTime.now(),
              );
              await Hive.box<CategoryModel>(HiveBoxes.categories)
                  .put(cat.id, cat);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(
      BuildContext context, CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await category.delete();
    }
  }
}
