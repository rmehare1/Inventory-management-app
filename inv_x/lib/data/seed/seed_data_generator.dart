import 'dart:math';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/hive_boxes.dart';
import '../../features/inventory/data/models/category_model.dart';
import '../../features/inventory/data/models/product_model.dart';
import '../../features/inventory/data/models/stock_movement_model.dart';
import '../../features/suppliers/data/models/supplier_model.dart';

/// Generates comprehensive demo / seed data for INV-X.
///
/// Call [generateAll] on first launch or when the user toggles demo mode on.
/// Call [clearAll] to wipe every Hive box.
class SeedDataGenerator {
  SeedDataGenerator._();

  static const _uuid = Uuid();
  static final _rng = Random(42); // seeded for reproducible demo data

  // ── Public API ──────────────────────────────────────────────────────────

  static Future<void> generateAll() async {
    await _generateCategories();
    await _generateProducts();
    await _generateSuppliers();
    await _generateStockMovements();
    await _generateAnomalies();
    await _generateForecasts();
    await _generateChatHistory();
    await _generateSettings();
  }

  static Future<void> clearAll() async {
    for (final name in HiveBoxes.allBoxes) {
      if (Hive.isBoxOpen(name)) {
        final box = Hive.box(name);
        await box.clear();
      } else {
        try {
          final box = await Hive.openBox(name);
          await box.clear();
        } catch (_) {
          // Box may use a typed adapter – try the generic fallback.
          try {
            final box = await Hive.openBox<dynamic>(name);
            await box.clear();
          } catch (_) {}
        }
      }
    }
  }

  // =====================================================================
  //  CATEGORIES
  // =====================================================================

  /// Stable category IDs so products can reference them.
  static final _categoryIds = List.generate(8, (_) => _uuid.v4());

  static const _categoryData = <Map<String, String>>[
    {'name': 'Electronics', 'emoji': '\u{1F4F1}', 'color': '#3B82F6'},
    {'name': 'Groceries', 'emoji': '\u{1F96B}', 'color': '#10B981'},
    {'name': 'Clothing', 'emoji': '\u{1F455}', 'color': '#8B5CF6'},
    {'name': 'Stationery', 'emoji': '\u{270F}\u{FE0F}', 'color': '#F59E0B'},
    {'name': 'Home & Kitchen', 'emoji': '\u{1F3E0}', 'color': '#EC4899'},
    {'name': 'Health & Beauty', 'emoji': '\u{1F48A}', 'color': '#06B6D4'},
    {'name': 'Tools & Hardware', 'emoji': '\u{1F527}', 'color': '#EF4444'},
    {'name': 'Gaming & Toys', 'emoji': '\u{1F3AE}', 'color': '#F97316'},
  ];

  static Future<void> _generateCategories() async {
    final box = await Hive.openBox<CategoryModel>(HiveBoxes.categories);
    await box.clear();

    for (var i = 0; i < _categoryData.length; i++) {
      final c = _categoryData[i];
      final model = CategoryModel(
        id: _categoryIds[i],
        name: c['name']!,
        emoji: c['emoji']!,
        colorHex: c['color']!,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      );
      await box.put(model.id, model);
    }
  }

  // =====================================================================
  //  PRODUCTS
  // =====================================================================

  /// Holds generated product IDs keyed by product name for cross-referencing.
  static final Map<String, String> _productIdsByName = {};

  static Future<void> _generateProducts() async {
    final box = await Hive.openBox<ProductModel>(HiveBoxes.products);
    await box.clear();
    _productIdsByName.clear();

    final now = DateTime.now();

    // Each tuple: [name, description, sku, cost, sell, stock, min, max, unit,
    //              expiryDaysFromNow (null = none), tags, catIndex, suppIndex,
    //              warehouseLocation]
    final products = <_ProductSpec>[
      // ── Electronics (catIndex 0, suppIndex 0) ──────────────────────────
      _ProductSpec('iPhone 15 Case', 'Premium silicone case for iPhone 15', 'ELEC-0001', 250, 599, 85, 20, 200, 'pcs', null, ['phone', 'case', 'apple'], 0, 0, 'A1-01'),
      _ProductSpec('Samsung 65W Charger', 'Fast charger for Samsung devices', 'ELEC-0002', 800, 1499, 42, 15, 100, 'pcs', null, ['charger', 'samsung'], 0, 0, 'A1-02'),
      _ProductSpec('USB-C Cable', '1m braided USB-C to USB-C cable', 'ELEC-0003', 120, 299, 150, 30, 300, 'pcs', null, ['cable', 'usb-c'], 0, 0, 'A1-03'),
      _ProductSpec('Wireless Earbuds', 'TWS earbuds with ANC', 'ELEC-0004', 1200, 2499, 8, 10, 80, 'pcs', null, ['audio', 'wireless', 'low-stock'], 0, 0, 'A1-04'),
      _ProductSpec('Laptop Stand', 'Aluminium adjustable laptop stand', 'ELEC-0005', 650, 1299, 35, 10, 60, 'pcs', null, ['laptop', 'stand'], 0, 0, 'A1-05'),
      _ProductSpec('Screen Protector', 'Tempered glass screen protector', 'ELEC-0006', 80, 199, 200, 50, 500, 'pcs', null, ['screen', 'protector'], 0, 0, 'A1-06'),
      _ProductSpec('Bluetooth Speaker', 'Portable 10W Bluetooth speaker', 'ELEC-0007', 900, 1899, 5, 10, 50, 'pcs', null, ['audio', 'bluetooth', 'low-stock'], 0, 0, 'A1-07'),
      _ProductSpec('Power Bank', '10000mAh power bank', 'ELEC-0008', 500, 999, 60, 15, 100, 'pcs', null, ['power', 'battery'], 0, 0, 'A1-08'),
      _ProductSpec('HDMI Cable', '2m HDMI 2.1 cable', 'ELEC-0009', 150, 349, 90, 20, 200, 'pcs', null, ['cable', 'hdmi'], 0, 0, 'A1-09'),
      _ProductSpec('Webcam', '1080p HD webcam with mic', 'ELEC-0010', 1100, 2199, 25, 10, 50, 'pcs', null, ['camera', 'webcam'], 0, 0, 'A1-10'),

      // ── Groceries (catIndex 1, suppIndex 1) ────────────────────────────
      _ProductSpec('Basmati Rice', 'Premium aged Basmati rice 5kg', 'GROC-0001', 320, 499, 75, 20, 150, 'bags', 180, ['rice', 'staples'], 1, 1, 'B1-01'),
      _ProductSpec('Sunflower Oil', 'Refined sunflower oil 1L', 'GROC-0002', 110, 179, 12, 15, 100, 'bottles', 365, ['oil', 'cooking', 'low-stock'], 1, 1, 'B1-02'),
      _ProductSpec('Tata Salt', 'Iodised salt 1kg', 'GROC-0003', 18, 28, 200, 50, 300, 'pcs', 730, ['salt', 'staples'], 1, 1, 'B1-03'),
      _ProductSpec('Red Label Tea', 'Brooke Bond Red Label 500g', 'GROC-0004', 180, 275, 55, 20, 100, 'pcs', 365, ['tea', 'beverages'], 1, 1, 'B1-04'),
      _ProductSpec('Maggi Noodles', 'Maggi 2-Minute Noodles pack of 12', 'GROC-0005', 120, 168, 90, 25, 200, 'pcs', 240, ['noodles', 'instant'], 1, 1, 'B1-05'),
      _ProductSpec('Amul Butter', 'Amul Butter 500g', 'GROC-0006', 220, 290, 30, 10, 80, 'pcs', 5, ['dairy', 'butter', 'expiring-soon'], 1, 1, 'B1-06'),
      _ProductSpec('Atta', 'Aashirvaad whole wheat atta 10kg', 'GROC-0007', 350, 480, 40, 15, 80, 'bags', 180, ['flour', 'staples'], 1, 1, 'B1-07'),
      _ProductSpec('Kissan Jam', 'Kissan mixed fruit jam 500g', 'GROC-0008', 110, 165, 7, 10, 60, 'pcs', 3, ['jam', 'spread', 'low-stock', 'expiring-soon'], 1, 1, 'B1-08'),
      _ProductSpec('Parle-G', 'Parle-G glucose biscuits 800g', 'GROC-0009', 55, 80, 150, 30, 250, 'pcs', 180, ['biscuits', 'snacks'], 1, 1, 'B1-09'),
      _ProductSpec('Nescafe', 'Nescafe Classic 200g', 'GROC-0010', 350, 480, 35, 10, 60, 'pcs', 540, ['coffee', 'beverages'], 1, 1, 'B1-10'),

      // ── Clothing (catIndex 2, suppIndex 2) ─────────────────────────────
      _ProductSpec('T-Shirt', 'Cotton round-neck T-shirt', 'CLTH-0001', 200, 499, 120, 25, 200, 'pcs', null, ['cotton', 'casual'], 2, 2, 'C1-01'),
      _ProductSpec('Kurti', 'Printed cotton kurti', 'CLTH-0002', 350, 799, 65, 15, 100, 'pcs', null, ['ethnic', 'women'], 2, 2, 'C1-02'),
      _ProductSpec('Jeans', 'Slim-fit denim jeans', 'CLTH-0003', 600, 1299, 50, 15, 80, 'pcs', null, ['denim', 'casual'], 2, 2, 'C1-03'),
      _ProductSpec('Sports Shoes', 'Lightweight running shoes', 'CLTH-0004', 800, 1799, 30, 10, 60, 'pcs', null, ['shoes', 'sports'], 2, 2, 'C1-04'),
      _ProductSpec('Socks', 'Ankle socks pack of 3', 'CLTH-0005', 80, 199, 200, 40, 300, 'pcs', null, ['socks', 'essentials'], 2, 2, 'C1-05'),
      _ProductSpec('Winter Jacket', 'Padded winter jacket', 'CLTH-0006', 1200, 2499, 6, 10, 40, 'pcs', null, ['jacket', 'winter', 'low-stock'], 2, 2, 'C1-06'),
      _ProductSpec('Formal Shirt', 'Cotton formal shirt', 'CLTH-0007', 450, 999, 45, 15, 80, 'pcs', null, ['formal', 'shirt'], 2, 2, 'C1-07'),
      _ProductSpec('Scarf', 'Woolen winter scarf', 'CLTH-0008', 150, 399, 55, 15, 80, 'pcs', null, ['scarf', 'winter'], 2, 2, 'C1-08'),

      // ── Stationery (catIndex 3, suppIndex 3) ───────────────────────────
      _ProductSpec('Ball Pen', 'Cello Gripper ball pen (blue)', 'STAT-0001', 5, 10, 500, 100, 1000, 'pcs', null, ['pen', 'writing'], 3, 3, 'D1-01'),
      _ProductSpec('Notebook', 'Single-line ruled notebook 200pg', 'STAT-0002', 30, 60, 150, 30, 300, 'pcs', null, ['notebook', 'writing'], 3, 3, 'D1-02'),
      _ProductSpec('Whiteboard Markers', 'Set of 4 whiteboard markers', 'STAT-0003', 80, 150, 60, 15, 100, 'sets', null, ['marker', 'whiteboard'], 3, 3, 'D1-03'),
      _ProductSpec('Sticky Notes', '3x3 inch sticky notes 100 sheets', 'STAT-0004', 25, 50, 120, 25, 200, 'pcs', null, ['sticky', 'notes'], 3, 3, 'D1-04'),
      _ProductSpec('Stapler', 'Full-strip desktop stapler', 'STAT-0005', 60, 120, 40, 10, 60, 'pcs', null, ['stapler', 'office'], 3, 3, 'D1-05'),
      _ProductSpec('Color Pencils', 'Set of 12 colour pencils', 'STAT-0006', 50, 99, 80, 20, 150, 'sets', null, ['pencils', 'art'], 3, 3, 'D1-06'),

      // ── Home & Kitchen (catIndex 4, suppIndex 4) ───────────────────────
      _ProductSpec('Water Bottle', '1L stainless steel bottle', 'HOME-0001', 250, 499, 45, 10, 80, 'pcs', null, ['bottle', 'kitchen'], 4, 4, 'E1-01'),
      _ProductSpec('Frying Pan', 'Non-stick 24cm frying pan', 'HOME-0002', 400, 799, 25, 8, 40, 'pcs', null, ['pan', 'cookware'], 4, 4, 'E1-02'),
      _ProductSpec('Glass Containers', 'Set of 3 borosilicate containers', 'HOME-0003', 350, 699, 30, 10, 50, 'sets', null, ['containers', 'storage'], 4, 4, 'E1-03'),
      _ProductSpec('LED Lamp', 'Rechargeable LED desk lamp', 'HOME-0004', 450, 899, 7, 10, 40, 'pcs', null, ['lamp', 'lighting', 'low-stock'], 4, 4, 'E1-04'),
      _ProductSpec('Bath Towels', '100% cotton bath towel', 'HOME-0005', 200, 449, 60, 15, 80, 'pcs', null, ['towel', 'bath'], 4, 4, 'E1-05'),
      _ProductSpec('Pressure Cooker', '5L aluminium pressure cooker', 'HOME-0006', 900, 1699, 18, 5, 30, 'pcs', null, ['cooker', 'cookware'], 4, 4, 'E1-06'),

      // ── Health & Beauty (catIndex 5, suppIndex 5) ──────────────────────
      _ProductSpec('Dove Shampoo', 'Dove Intense Repair shampoo 650ml', 'HLTH-0001', 280, 450, 40, 10, 80, 'bottles', 365, ['shampoo', 'haircare'], 5, 5, 'F1-01'),
      _ProductSpec('Nivea Lotion', 'Nivea body lotion 400ml', 'HLTH-0002', 200, 350, 35, 10, 60, 'bottles', 365, ['lotion', 'skincare'], 5, 5, 'F1-02'),
      _ProductSpec('Colgate', 'Colgate MaxFresh toothpaste 150g', 'HLTH-0003', 70, 120, 100, 25, 200, 'pcs', 540, ['toothpaste', 'oral'], 5, 5, 'F1-03'),
      _ProductSpec('Dettol', 'Dettol antiseptic liquid 500ml', 'HLTH-0004', 150, 260, 50, 15, 80, 'bottles', 730, ['antiseptic', 'hygiene'], 5, 5, 'F1-04'),
      _ProductSpec('Paracetamol', 'Crocin 500mg strip of 15', 'HLTH-0005', 15, 30, 80, 20, 200, 'strips', 2, ['medicine', 'fever', 'expiring-soon'], 5, 5, 'F1-05'),

      // ── Tools & Hardware (catIndex 6, suppIndex 6) ─────────────────────
      _ProductSpec('Screwdriver Set', '8-in-1 screwdriver set', 'TOOL-0001', 150, 299, 25, 8, 50, 'sets', null, ['screwdriver', 'hand-tools'], 6, 6, 'G1-01'),
      _ProductSpec('Measuring Tape', '5m measuring tape', 'TOOL-0002', 60, 120, 40, 10, 60, 'pcs', null, ['tape', 'measurement'], 6, 6, 'G1-02'),
      _ProductSpec('Electrical Tape', 'PVC insulation tape 10m', 'TOOL-0003', 20, 45, 100, 25, 200, 'pcs', null, ['tape', 'electrical'], 6, 6, 'G1-03'),

      // ── Gaming & Toys (catIndex 7, suppIndex 7) ────────────────────────
      _ProductSpec('Gaming Mouse', 'RGB wired gaming mouse 12000 DPI', 'GAME-0001', 600, 1299, 20, 8, 40, 'pcs', null, ['mouse', 'gaming'], 7, 7, 'H1-01'),
      _ProductSpec('PS5 Controller', 'DualSense wireless controller', 'GAME-0002', 3500, 5999, 4, 5, 20, 'pcs', null, ['controller', 'ps5', 'low-stock'], 7, 7, 'H1-02'),
    ];

    for (final p in products) {
      final id = _uuid.v4();
      _productIdsByName[p.name] = id;

      DateTime? expiry;
      if (p.expiryDaysFromNow != null) {
        expiry = now.add(Duration(days: p.expiryDaysFromNow!));
      }

      final model = ProductModel(
        id: id,
        name: p.name,
        description: p.description,
        sku: p.sku,
        barcode: _generateBarcode(p.sku),
        categoryId: _categoryIds[p.catIndex],
        costPrice: p.cost,
        sellingPrice: p.sell,
        currentStock: p.stock,
        minimumStock: p.min,
        maximumStock: p.max,
        unit: p.unit,
        supplierId: _supplierIds.length > p.suppIndex
            ? _supplierIds[p.suppIndex]
            : null,
        expiryDate: expiry,
        createdAt: now.subtract(Duration(days: 60 + _rng.nextInt(30))),
        updatedAt: now.subtract(Duration(days: _rng.nextInt(7))),
        warehouseLocation: p.warehouse,
        tags: p.tags,
        isActive: true,
        weight: null,
      );
      await box.put(model.id, model);
    }
  }

  // =====================================================================
  //  SUPPLIERS
  // =====================================================================

  static final _supplierIds = List.generate(8, (_) => _uuid.v4());

  static Future<void> _generateSuppliers() async {
    final box = await Hive.openBox<SupplierModel>(HiveBoxes.suppliers);
    await box.clear();

    final now = DateTime.now();

    final specs = <_SupplierSpec>[
      _SupplierSpec('TechParts India', 'procurement@techparts.in', '+91 98100 10001', 'Plot 45, Electronic City, Bangalore 560100', 4.5, 3),
      _SupplierSpec('FreshMart Wholesale', 'orders@freshmart.co.in', '+91 98100 10002', '12/A APMC Market, Navi Mumbai 400703', 4.2, 2),
      _SupplierSpec('FashionHub Distributors', 'supply@fashionhub.in', '+91 98100 10003', 'Gandhi Nagar, Delhi 110031', 3.8, 5),
      _SupplierSpec('OfficePro Supplies', 'bulk@officepro.in', '+91 98100 10004', 'Nehru Place, New Delhi 110019', 4.0, 4),
      _SupplierSpec('HomeNeeds Trading', 'info@homeneeds.co.in', '+91 98100 10005', 'Sadar Bazaar, Delhi 110006', 4.3, 3),
      _SupplierSpec('MedPlus Distributors', 'orders@medplus-dist.in', '+91 98100 10006', 'Ameerpet, Hyderabad 500016', 4.7, 2),
      _SupplierSpec('BuildRight Hardware', 'sales@buildright.in', '+91 98100 10007', 'Loha Mandi, Agra 282002', 3.9, 6),
      _SupplierSpec('GameZone Wholesale', 'wholesale@gamezone.in', '+91 98100 10008', 'Lamington Road, Mumbai 400004', 4.1, 4),
    ];

    for (var i = 0; i < specs.length; i++) {
      final s = specs[i];
      // Collect product IDs that belong to this supplier's category index.
      final catId = _categoryIds[i];
      final prodIds = <String>[];
      // We'll match by iterating the product box (already written).
      final productBox =
          Hive.isBoxOpen(HiveBoxes.products)
              ? Hive.box<ProductModel>(HiveBoxes.products)
              : await Hive.openBox<ProductModel>(HiveBoxes.products);
      for (final p in productBox.values) {
        if (p.categoryId == catId) prodIds.add(p.id);
      }

      final model = SupplierModel(
        id: _supplierIds[i],
        name: s.name,
        email: s.email,
        phone: s.phone,
        address: s.address,
        reliabilityScore: s.score,
        avgDeliveryDays: s.deliveryDays,
        productIds: prodIds,
        createdAt: now.subtract(Duration(days: 80 + _rng.nextInt(20))),
        notes: 'Seed data supplier.',
      );
      await box.put(model.id, model);
    }

    // Back-fill supplierId on products now that supplier IDs are final.
    final productBox =
        Hive.isBoxOpen(HiveBoxes.products)
            ? Hive.box<ProductModel>(HiveBoxes.products)
            : await Hive.openBox<ProductModel>(HiveBoxes.products);
    for (final p in productBox.values) {
      final catIdx = _categoryIds.indexOf(p.categoryId);
      if (catIdx >= 0 && catIdx < _supplierIds.length) {
        p.supplierId = _supplierIds[catIdx];
        await p.save();
      }
    }
  }

  // =====================================================================
  //  STOCK MOVEMENTS  (200+)
  // =====================================================================

  static Future<void> _generateStockMovements() async {
    final box =
        await Hive.openBox<StockMovementModel>(HiveBoxes.stockMovements);
    await box.clear();

    final now = DateTime.now();
    final productBox =
        Hive.isBoxOpen(HiveBoxes.products)
            ? Hive.box<ProductModel>(HiveBoxes.products)
            : await Hive.openBox<ProductModel>(HiveBoxes.products);

    final allProducts = productBox.values.toList();
    if (allProducts.isEmpty) return;

    final movements = <StockMovementModel>[];

    // Generate movements for last 30 days.
    for (var dayOffset = 30; dayOffset >= 0; dayOffset--) {
      final day = now.subtract(Duration(days: dayOffset));
      final isWeekend =
          day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

      // More movements on weekends (8-12 vs 5-8 on weekdays).
      final count = isWeekend ? 8 + _rng.nextInt(5) : 5 + _rng.nextInt(4);

      for (var m = 0; m < count; m++) {
        final product = allProducts[_rng.nextInt(allProducts.length)];

        // Decide type: 60% OUT (sale), 25% IN (restock), 10% RETURN, 5% ADJUST
        final roll = _rng.nextDouble();
        String type;
        if (roll < 0.60) {
          type = 'OUT';
        } else if (roll < 0.85) {
          type = 'IN';
        } else if (roll < 0.95) {
          type = 'RETURN';
        } else {
          type = 'ADJUST';
        }

        int qty;
        switch (type) {
          case 'OUT':
            qty = 1 + _rng.nextInt(5);
            break;
          case 'IN':
            qty = 10 + _rng.nextInt(30);
            break;
          case 'RETURN':
            qty = 1 + _rng.nextInt(3);
            break;
          default: // ADJUST
            qty = _rng.nextBool() ? (1 + _rng.nextInt(5)) : -(1 + _rng.nextInt(5));
            break;
        }

        // Simulate stock levels (approximate).
        final prevStock = product.currentStock + _rng.nextInt(20);
        final newStock = type == 'OUT'
            ? max(0, prevStock - qty)
            : type == 'ADJUST' && qty < 0
                ? max(0, prevStock + qty)
                : prevStock + qty.abs();

        final timestamp = day.add(Duration(
          hours: 8 + _rng.nextInt(12),
          minutes: _rng.nextInt(60),
        ));

        final reason = _movementReason(type);

        movements.add(StockMovementModel(
          id: _uuid.v4(),
          productId: product.id,
          type: type,
          quantity: qty.abs(),
          previousStock: prevStock,
          newStock: newStock,
          reason: reason,
          timestamp: timestamp,
          isAnomalous: false,
        ));
      }
    }

    // ── Inject anomalous movements ───────────────────────────────────────

    // 1. Big drop: 50 Wireless Earbuds vanish overnight (no sale record).
    final earbudsId = _productIdsByName['Wireless Earbuds'];
    if (earbudsId != null) {
      movements.add(StockMovementModel(
        id: _uuid.v4(),
        productId: earbudsId,
        type: 'ADJUST',
        quantity: 50,
        previousStock: 58,
        newStock: 8,
        reason: 'Inventory audit adjustment',
        timestamp: now.subtract(const Duration(days: 2, hours: 3)),
        isAnomalous: true,
        anomalyReason: 'Large stock decrease without corresponding sales record',
      ));
    }

    // 2. 15 phone case returns in one day.
    final caseId = _productIdsByName['iPhone 15 Case'];
    if (caseId != null) {
      for (var i = 0; i < 15; i++) {
        movements.add(StockMovementModel(
          id: _uuid.v4(),
          productId: caseId,
          type: 'RETURN',
          quantity: 1,
          previousStock: 70 + i,
          newStock: 71 + i,
          reason: 'Customer return – defective',
          timestamp: now.subtract(Duration(days: 1, hours: 9 + (i ~/ 3), minutes: i * 4)),
          isAnomalous: true,
          anomalyReason: '15 returns of same product in single day',
        ));
      }
    }

    // 3. Stock mismatch for Basmati Rice.
    final riceId = _productIdsByName['Basmati Rice'];
    if (riceId != null) {
      movements.add(StockMovementModel(
        id: _uuid.v4(),
        productId: riceId,
        type: 'ADJUST',
        quantity: 12,
        previousStock: 87,
        newStock: 75,
        reason: 'Physical count mismatch',
        timestamp: now.subtract(const Duration(days: 4, hours: 14)),
        isAnomalous: true,
        anomalyReason: 'System stock does not match physical count',
      ));
    }

    // 4. USB-C Cable selling at 3x normal rate.
    final usbId = _productIdsByName['USB-C Cable'];
    if (usbId != null) {
      for (var i = 0; i < 20; i++) {
        movements.add(StockMovementModel(
          id: _uuid.v4(),
          productId: usbId,
          type: 'OUT',
          quantity: 3 + _rng.nextInt(4),
          previousStock: 150 - i * 5,
          newStock: max(0, 150 - (i + 1) * 5),
          reason: 'Sale',
          timestamp: now.subtract(Duration(days: _rng.nextInt(3), hours: 10 + _rng.nextInt(8))),
          isAnomalous: i == 0, // flag only the first one
          anomalyReason: i == 0 ? 'Selling at 3x normal rate' : null,
        ));
      }
    }

    // Write all movements.
    for (final mv in movements) {
      await box.put(mv.id, mv);
    }
  }

  // =====================================================================
  //  ANOMALIES
  // =====================================================================

  static Future<void> _generateAnomalies() async {
    final box = await Hive.openBox(HiveBoxes.anomalies);
    await box.clear();

    final now = DateTime.now();

    final anomalies = <Map<String, dynamic>>[
      {
        'id': _uuid.v4(),
        'title': '50 Wireless Earbuds missing',
        'description':
            'Stock dropped from 58 to 8 units without any corresponding sales or transfer records. Possible theft or system error.',
        'severity': 'CRITICAL',
        'productId': _productIdsByName['Wireless Earbuds'] ?? '',
        'productName': 'Wireless Earbuds',
        'detectedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'type': 'STOCK_DISCREPANCY',
        'status': 'OPEN',
        'suggestedAction': 'Conduct physical audit of warehouse section A1-04. Review CCTV footage for the past 48 hours.',
        'impact': 'Potential loss of \u20B91,24,950 (50 units x \u20B92,499)',
      },
      {
        'id': _uuid.v4(),
        'title': '15 returns of iPhone 15 Case in 1 day',
        'description':
            '15 units of iPhone 15 Case were returned in a single day citing defective quality. Normal return rate is 1-2/week.',
        'severity': 'HIGH',
        'productId': _productIdsByName['iPhone 15 Case'] ?? '',
        'productName': 'iPhone 15 Case',
        'detectedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'type': 'UNUSUAL_RETURNS',
        'status': 'OPEN',
        'suggestedAction': 'Quarantine remaining stock from the same batch. Contact supplier TechParts India for quality investigation.',
        'impact': 'Revenue impact \u20B98,985 in returns. Risk of customer dissatisfaction.',
      },
      {
        'id': _uuid.v4(),
        'title': 'Stock mismatch — Basmati Rice',
        'description':
            'Physical count shows 75 bags but system records 87. Difference of 12 bags (\u20B95,988 value).',
        'severity': 'MEDIUM',
        'productId': _productIdsByName['Basmati Rice'] ?? '',
        'productName': 'Basmati Rice',
        'detectedAt': now.subtract(const Duration(days: 4)).toIso8601String(),
        'type': 'STOCK_DISCREPANCY',
        'status': 'INVESTIGATING',
        'suggestedAction': 'Review incoming shipment logs for last 2 weeks. Check if bags were moved to a different location.',
        'impact': 'Inventory accuracy below threshold. Value discrepancy \u20B95,988.',
      },
      {
        'id': _uuid.v4(),
        'title': 'USB-C Cable selling at 3x normal rate',
        'description':
            'USB-C Cable sales have surged to 3x the 30-day average. Current velocity will deplete stock in ~5 days.',
        'severity': 'MEDIUM',
        'productId': _productIdsByName['USB-C Cable'] ?? '',
        'productName': 'USB-C Cable',
        'detectedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'type': 'DEMAND_SPIKE',
        'status': 'OPEN',
        'suggestedAction': 'Place urgent restock order with TechParts India. Consider raising price by 10-15% to manage demand.',
        'impact': 'Stockout risk within 5 days. Opportunity to increase margin.',
      },
      {
        'id': _uuid.v4(),
        'title': 'FashionHub delivery consistently late',
        'description':
            'Last 3 deliveries from FashionHub Distributors arrived 2-4 days past promised date. Avg delivery now 7 days vs stated 5.',
        'severity': 'LOW',
        'productId': null,
        'productName': null,
        'detectedAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'type': 'SUPPLIER_ISSUE',
        'status': 'MONITORING',
        'suggestedAction': 'Discuss SLA terms with FashionHub. Consider secondary supplier for Clothing category.',
        'impact': 'Increased lead time affects restock planning for 8 clothing SKUs.',
      },
    ];

    for (final a in anomalies) {
      await box.put(a['id'], a);
    }
  }

  // =====================================================================
  //  FORECASTS
  // =====================================================================

  static Future<void> _generateForecasts() async {
    final box = await Hive.openBox(HiveBoxes.forecasts);
    await box.clear();

    final forecastProducts = [
      'USB-C Cable',
      'Wireless Earbuds',
      'Basmati Rice',
      'T-Shirt',
      'Colgate',
    ];

    for (final name in forecastProducts) {
      final productId = _productIdsByName[name];
      if (productId == null) continue;

      // Generate 30-day daily forecast with realistic variance.
      final dailyForecast = <Map<String, dynamic>>[];
      final baseDemand = _baseDemandForProduct(name);
      double confidence = 0.92;

      for (var day = 1; day <= 30; day++) {
        final date = DateTime.now().add(Duration(days: day));
        final isWeekend =
            date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
        final demand = (baseDemand *
                (isWeekend ? 1.3 : 1.0) *
                (0.85 + _rng.nextDouble() * 0.3))
            .round();
        // Confidence decays over time.
        confidence = max(0.55, confidence - 0.008 - _rng.nextDouble() * 0.005);

        dailyForecast.add({
          'date': date.toIso8601String(),
          'predictedDemand': demand,
          'lowerBound': max(0, (demand * 0.75).round()),
          'upperBound': (demand * 1.30).round(),
          'confidence': double.parse(confidence.toStringAsFixed(2)),
        });
      }

      final totalPredicted =
          dailyForecast.fold<int>(0, (s, e) => s + (e['predictedDemand'] as int));
      final avgConfidence = dailyForecast.fold<double>(
              0, (s, e) => s + (e['confidence'] as double)) /
          dailyForecast.length;

      final forecast = <String, dynamic>{
        'id': _uuid.v4(),
        'productId': productId,
        'productName': name,
        'generatedAt': DateTime.now().toIso8601String(),
        'periodDays': 30,
        'totalPredictedDemand': totalPredicted,
        'averageConfidence':
            double.parse(avgConfidence.toStringAsFixed(2)),
        'recommendedReorderQty': (totalPredicted * 1.2).round(),
        'recommendedReorderDate': DateTime.now()
            .add(const Duration(days: 3))
            .toIso8601String(),
        'dailyForecast': dailyForecast,
        'trend': _trendForProduct(name),
        'seasonalityFactor': isWeekend(DateTime.now()) ? 1.3 : 1.0,
      };

      await box.put(forecast['id'], forecast);
    }
  }

  // =====================================================================
  //  CHAT HISTORY
  // =====================================================================

  static Future<void> _generateChatHistory() async {
    final box = await Hive.openBox(HiveBoxes.chatHistory);
    await box.clear();

    final now = DateTime.now();

    final conversations = <Map<String, dynamic>>[
      // Conversation 1 — Inventory health overview
      {
        'id': _uuid.v4(),
        'title': 'Inventory Health Check',
        'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'messages': [
          {
            'role': 'user',
            'content': 'How is my inventory health today?',
            'timestamp':
                now.subtract(const Duration(hours: 2)).toIso8601String(),
          },
          {
            'role': 'assistant',
            'content':
                'Here\'s your inventory health summary:\n\n'
                '**Overall Score: 72/100** (Needs Attention)\n\n'
                '**Critical Issues:**\n'
                '- 6 products are low on stock (Wireless Earbuds, Bluetooth Speaker, Winter Jacket, LED Lamp, PS5 Controller, Kissan Jam)\n'
                '- 3 products expiring within 7 days (Amul Butter in 5d, Kissan Jam in 3d, Paracetamol in 2d)\n'
                '- 1 anomaly detected: 50 Wireless Earbuds missing without sales records\n\n'
                '**Positive Indicators:**\n'
                '- 85% of SKUs are well-stocked\n'
                '- Revenue trend is up 12% week-over-week\n'
                '- USB-C Cable is your top seller this week\n\n'
                'Would you like me to generate restock orders for the low-stock items?',
            'timestamp': now
                .subtract(const Duration(hours: 1, minutes: 59))
                .toIso8601String(),
          },
        ],
      },
      // Conversation 2 — Restocking advice
      {
        'id': _uuid.v4(),
        'title': 'Restock Recommendations',
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'messages': [
          {
            'role': 'user',
            'content': 'Which products should I restock this week?',
            'timestamp':
                now.subtract(const Duration(days: 1)).toIso8601String(),
          },
          {
            'role': 'assistant',
            'content':
                'Based on current stock levels and sales velocity, I recommend restocking these items urgently:\n\n'
                '| Product | Current | Min | Suggested Order |\n'
                '|---------|---------|-----|----------------|\n'
                '| Wireless Earbuds | 8 | 10 | 40 units |\n'
                '| Bluetooth Speaker | 5 | 10 | 30 units |\n'
                '| PS5 Controller | 4 | 5 | 15 units |\n'
                '| Kissan Jam | 7 | 10 | 30 units |\n'
                '| Winter Jacket | 6 | 10 | 20 units |\n'
                '| LED Lamp | 7 | 10 | 20 units |\n\n'
                'Total estimated cost: \u20B92,34,500\n'
                'Suppliers: TechParts India, FreshMart Wholesale, FashionHub, HomeNeeds, GameZone\n\n'
                'Shall I draft purchase orders for these?',
            'timestamp': now
                .subtract(const Duration(hours: 23, minutes: 58))
                .toIso8601String(),
          },
          {
            'role': 'user',
            'content': 'Yes, draft POs for the top 3 urgent ones.',
            'timestamp': now
                .subtract(const Duration(hours: 23, minutes: 55))
                .toIso8601String(),
          },
          {
            'role': 'assistant',
            'content':
                'I\'ve drafted 3 purchase orders:\n\n'
                '1. **PO-2026-0042** — TechParts India\n'
                '   - 40x Wireless Earbuds @ \u20B91,200 = \u20B948,000\n'
                '   - 30x Bluetooth Speaker @ \u20B9900 = \u20B927,000\n'
                '   - Expected delivery: 3 days\n\n'
                '2. **PO-2026-0043** — GameZone Wholesale\n'
                '   - 15x PS5 Controller @ \u20B93,500 = \u20B952,500\n'
                '   - Expected delivery: 4 days\n\n'
                '3. **PO-2026-0044** — FreshMart Wholesale\n'
                '   - 30x Kissan Jam @ \u20B9110 = \u20B93,300\n'
                '   - Expected delivery: 2 days\n\n'
                'Total: \u20B91,30,800. Ready for your approval in the Orders tab.',
            'timestamp': now
                .subtract(const Duration(hours: 23, minutes: 54))
                .toIso8601String(),
          },
        ],
      },
      // Conversation 3 — Anomaly discussion
      {
        'id': _uuid.v4(),
        'title': 'Missing Earbuds Investigation',
        'createdAt':
            now.subtract(const Duration(days: 2, hours: 4)).toIso8601String(),
        'messages': [
          {
            'role': 'user',
            'content':
                'I see an alert about 50 missing earbuds. What happened?',
            'timestamp': now
                .subtract(const Duration(days: 2, hours: 4))
                .toIso8601String(),
          },
          {
            'role': 'assistant',
            'content':
                'I detected a critical stock anomaly for **Wireless Earbuds**:\n\n'
                '- **Previous stock:** 58 units\n'
                '- **Current stock:** 8 units\n'
                '- **Missing:** 50 units (value: \u20B91,24,950)\n'
                '- **Time of change:** ~3:00 AM, 2 days ago\n\n'
                'There are **no corresponding sales, transfers, or damage records** for this drop. This is unusual because:\n'
                '1. The adjustment happened outside business hours\n'
                '2. No staff was logged in at that time\n'
                '3. The quantity is far above normal daily movement\n\n'
                '**Recommended actions:**\n'
                '- Physical audit of location A1-04\n'
                '- Review CCTV footage for the warehouse\n'
                '- Check if any system integration pushed a bad update\n\n'
                'I\'ve flagged this as CRITICAL priority.',
            'timestamp': now
                .subtract(const Duration(days: 2, hours: 3, minutes: 58))
                .toIso8601String(),
          },
        ],
      },
      // Conversation 4 — Sales trend
      {
        'id': _uuid.v4(),
        'title': 'Weekly Sales Trends',
        'createdAt':
            now.subtract(const Duration(days: 3, hours: 6)).toIso8601String(),
        'messages': [
          {
            'role': 'user',
            'content': 'Show me the sales trends for this week.',
            'timestamp': now
                .subtract(const Duration(days: 3, hours: 6))
                .toIso8601String(),
          },
          {
            'role': 'assistant',
            'content':
                'Here are your sales trends for the past 7 days:\n\n'
                '**Top Sellers:**\n'
                '1. USB-C Cable — 87 units (\u20B926,013) \u2191 200%\n'
                '2. Screen Protector — 45 units (\u20B98,955) \u2191 15%\n'
                '3. T-Shirt — 38 units (\u20B918,962) \u2193 5%\n'
                '4. Ball Pen — 120 units (\u20B91,200) \u2191 8%\n'
                '5. Parle-G — 42 units (\u20B93,360) = flat\n\n'
                '**Revenue:** \u20B92,15,430 (up 18% from last week)\n'
                '**Avg. basket size:** \u20B9847\n'
                '**Weekend boost:** Sales were 35% higher on Sat-Sun\n\n'
                'Note: USB-C Cable demand spike is unusual — I\'ve flagged it for review. Consider reordering soon.',
            'timestamp': now
                .subtract(const Duration(days: 3, hours: 5, minutes: 58))
                .toIso8601String(),
          },
        ],
      },
      // Conversation 5 — Supplier evaluation
      {
        'id': _uuid.v4(),
        'title': 'Supplier Performance Review',
        'createdAt':
            now.subtract(const Duration(days: 5, hours: 2)).toIso8601String(),
        'messages': [
          {
            'role': 'user',
            'content': 'How are my suppliers performing?',
            'timestamp': now
                .subtract(const Duration(days: 5, hours: 2))
                .toIso8601String(),
          },
          {
            'role': 'assistant',
            'content':
                'Here\'s your supplier scorecard:\n\n'
                '| Supplier | Score | Avg Delivery | Status |\n'
                '|----------|-------|-------------|--------|\n'
                '| MedPlus Distributors | 4.7/5 | 2 days | Excellent |\n'
                '| TechParts India | 4.5/5 | 3 days | Good |\n'
                '| HomeNeeds Trading | 4.3/5 | 3 days | Good |\n'
                '| FreshMart Wholesale | 4.2/5 | 2 days | Good |\n'
                '| GameZone Wholesale | 4.1/5 | 4 days | Average |\n'
                '| OfficePro Supplies | 4.0/5 | 4 days | Average |\n'
                '| BuildRight Hardware | 3.9/5 | 6 days | Below Avg |\n'
                '| FashionHub Distributors | 3.8/5 | 5 days | Below Avg |\n\n'
                '**Concerns:**\n'
                '- FashionHub has been consistently 2-4 days late on recent deliveries\n'
                '- BuildRight has the longest lead time at 6 days\n\n'
                'I recommend discussing delivery SLAs with FashionHub or scouting an alternative clothing supplier.',
            'timestamp': now
                .subtract(const Duration(days: 5, hours: 1, minutes: 58))
                .toIso8601String(),
          },
        ],
      },
    ];

    for (final conv in conversations) {
      await box.put(conv['id'], conv);
    }
  }

  // =====================================================================
  //  SETTINGS
  // =====================================================================

  static Future<void> _generateSettings() async {
    final box = await Hive.openBox(HiveBoxes.settings);
    await box.clear();

    await box.putAll(<String, dynamic>{
      'isDemoMode': true,
      'seedDataGenerated': true,
      'seedDataVersion': 1,
      'seedGeneratedAt': DateTime.now().toIso8601String(),
      'currency': 'INR',
      'currencySymbol': '\u20B9',
      'currencyLocale': 'en_IN',
      'businessName': 'INV-X Demo Store',
      'businessAddress': '42 MG Road, Bangalore 560001',
      'businessPhone': '+91 80 4567 8900',
      'businessEmail': 'demo@inv-x.app',
      'lowStockAlerts': true,
      'expiryAlerts': true,
      'anomalyAlerts': true,
      'dailyReportTime': '09:00',
      'theme': 'system',
      'hapticFeedback': true,
      'aiTier': 'LOCAL',
    });
  }

  // =====================================================================
  //  PRIVATE HELPERS
  // =====================================================================

  static String _generateBarcode(String sku) {
    // Generate a 13-digit EAN-like barcode from SKU hash.
    final hash = sku.hashCode.abs();
    final base = '890${hash.toString().padLeft(9, '0').substring(0, 9)}';
    // Simple check digit (mod 10).
    int sum = 0;
    for (var i = 0; i < 12; i++) {
      final digit = int.parse(base[i]);
      sum += (i.isEven) ? digit : digit * 3;
    }
    final check = (10 - (sum % 10)) % 10;
    return '$base$check';
  }

  static String _movementReason(String type) {
    switch (type) {
      case 'OUT':
        final reasons = [
          'Sale',
          'Customer order',
          'Online order',
          'Walk-in sale',
          'Bulk order',
        ];
        return reasons[_rng.nextInt(reasons.length)];
      case 'IN':
        final reasons = [
          'Supplier delivery',
          'Restock',
          'Purchase order received',
          'Inter-warehouse transfer',
        ];
        return reasons[_rng.nextInt(reasons.length)];
      case 'RETURN':
        final reasons = [
          'Customer return – defective',
          'Customer return – wrong item',
          'Customer return – changed mind',
        ];
        return reasons[_rng.nextInt(reasons.length)];
      case 'ADJUST':
        final reasons = [
          'Inventory audit adjustment',
          'Damage write-off',
          'System correction',
        ];
        return reasons[_rng.nextInt(reasons.length)];
      default:
        return 'Other';
    }
  }

  static double _baseDemandForProduct(String name) {
    switch (name) {
      case 'USB-C Cable':
        return 12;
      case 'Wireless Earbuds':
        return 3;
      case 'Basmati Rice':
        return 5;
      case 'T-Shirt':
        return 6;
      case 'Colgate':
        return 8;
      default:
        return 4;
    }
  }

  static String _trendForProduct(String name) {
    switch (name) {
      case 'USB-C Cable':
        return 'RISING';
      case 'Wireless Earbuds':
        return 'DECLINING';
      case 'Basmati Rice':
        return 'STABLE';
      case 'T-Shirt':
        return 'STABLE';
      case 'Colgate':
        return 'RISING';
      default:
        return 'STABLE';
    }
  }

  /// Weekend check used by forecasts.
  static bool isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}

// ─── Internal data holder classes ─────────────────────────────────────────────

class _ProductSpec {
  final String name;
  final String description;
  final String sku;
  final double cost;
  final double sell;
  final int stock;
  final int min;
  final int max;
  final String unit;
  final int? expiryDaysFromNow;
  final List<String> tags;
  final int catIndex;
  final int suppIndex;
  final String warehouse;

  const _ProductSpec(
    this.name,
    this.description,
    this.sku,
    this.cost,
    this.sell,
    this.stock,
    this.min,
    this.max,
    this.unit,
    this.expiryDaysFromNow,
    this.tags,
    this.catIndex,
    this.suppIndex,
    this.warehouse,
  );
}

class _SupplierSpec {
  final String name;
  final String email;
  final String phone;
  final String address;
  final double score;
  final int deliveryDays;

  const _SupplierSpec(
    this.name,
    this.email,
    this.phone,
    this.address,
    this.score,
    this.deliveryDays,
  );
}
