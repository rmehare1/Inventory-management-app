import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/widgets/gradient_button.dart';
import '../../../../data/hive/hive_initializer.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _sellCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _minStockCtrl = TextEditingController(text: '10');
  final _maxStockCtrl = TextEditingController(text: '100');

  String _unit = 'pcs';
  String? _categoryId;
  DateTime? _expiryDate;

  final _units = ['pcs', 'kg', 'liters', 'boxes', 'meters', 'dozen', 'sets', 'bags', 'bottles', 'strips'];

  @override
  void initState() {
    super.initState();
    // Auto-generate SKU
    _skuCtrl.text = 'PRD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _skuCtrl.dispose();
    _costCtrl.dispose();
    _sellCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    _maxStockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = Hive.box<CategoryModel>(HiveBoxes.categories).values.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info
            _SectionTitle('Basic Info'),
            const SizedBox(height: 12),
            _buildField('Product Name *', _nameCtrl, validator: _required),
            _buildField('Description', _descCtrl, maxLines: 3),
            _buildField('SKU *', _skuCtrl, validator: _required),

            // Category dropdown
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'Category *'),
              dropdownColor: AppColors.surface,
              items: categories.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text('${c.emoji} ${c.name}'),
              )).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
              validator: (v) => v == null ? 'Select a category' : null,
            ),

            const SizedBox(height: 24),
            _SectionTitle('Pricing'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildField('Cost Price *', _costCtrl,
                    keyboardType: TextInputType.number, validator: _required)),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Selling Price *', _sellCtrl,
                    keyboardType: TextInputType.number, validator: _required)),
              ],
            ),

            const SizedBox(height: 24),
            _SectionTitle('Stock'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildField('Current Stock *', _stockCtrl,
                    keyboardType: TextInputType.number, validator: _required)),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Min Stock', _minStockCtrl,
                    keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Max Stock', _maxStockCtrl,
                    keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _unit,
              decoration: const InputDecoration(labelText: 'Unit'),
              dropdownColor: AppColors.surface,
              items: _units.map((u) => DropdownMenuItem(
                value: u,
                child: Text(u),
              )).toList(),
              onChanged: (v) => setState(() => _unit = v ?? 'pcs'),
            ),

            const SizedBox(height: 24),
            _SectionTitle('Details'),
            const SizedBox(height: 12),
            // Expiry date picker
            GestureDetector(
              onTap: _pickExpiryDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Expiry Date (optional)'),
                child: Text(
                  _expiryDate != null
                      ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                      : 'Tap to select',
                  style: TextStyle(
                    color: _expiryDate != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            GradientButton(
              onPressed: _saveProduct,
              label: '💾 Save Product',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) return;

    final product = ProductModel(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      sku: _skuCtrl.text.trim(),
      categoryId: _categoryId!,
      costPrice: double.tryParse(_costCtrl.text) ?? 0,
      sellingPrice: double.tryParse(_sellCtrl.text) ?? 0,
      currentStock: int.tryParse(_stockCtrl.text) ?? 0,
      minimumStock: int.tryParse(_minStockCtrl.text) ?? 10,
      maximumStock: int.tryParse(_maxStockCtrl.text) ?? 100,
      unit: _unit,
      expiryDate: _expiryDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: [],
    );

    final box = Hive.box<ProductModel>(HiveBoxes.products);
    await box.put(product.id, product);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${product.name} added successfully!')),
      );
      context.pop();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryGradientStart,
      ),
    );
  }
}
