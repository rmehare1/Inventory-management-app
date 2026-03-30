import 'package:hive/hive.dart';

class AIContext {
  final String? businessName;
  final int totalProducts;
  final int lowStockCount;
  final int expiringCount;
  final int todayMovements;
  final double totalInventoryValue;
  final String currency;
  final List<Map<String, dynamic>>? relevantProducts;

  const AIContext({
    this.businessName,
    this.totalProducts = 0,
    this.lowStockCount = 0,
    this.expiringCount = 0,
    this.todayMovements = 0,
    this.totalInventoryValue = 0.0,
    this.currency = 'INR',
    this.relevantProducts,
  });

  /// Reads Hive boxes to compile the current business context.
  /// Falls back to sensible defaults if boxes are not available.
  static Future<AIContext> buildFromHive() async {
    try {
      // --- Business settings ---
      String? businessName;
      String currency = 'INR';

      if (Hive.isBoxOpen('settings')) {
        final settingsBox = Hive.box('settings');
        businessName = settingsBox.get('businessName') as String?;
        currency = settingsBox.get('currency', defaultValue: 'INR') as String;
      }

      // --- Products ---
      int totalProducts = 0;
      int lowStockCount = 0;
      int expiringCount = 0;
      double totalValue = 0.0;

      if (Hive.isBoxOpen('products')) {
        final productsBox = Hive.box('products');
        final now = DateTime.now();
        final warningDate = now.add(const Duration(days: 30));

        for (int i = 0; i < productsBox.length; i++) {
          final product = productsBox.getAt(i);
          if (product == null) continue;

          totalProducts++;

          // Attempt to read fields. Products may be Maps or typed objects.
          final Map<String, dynamic> p = product is Map
              ? Map<String, dynamic>.from(product)
              : <String, dynamic>{};

          final int qty = (p['quantity'] ?? p['stock'] ?? 0) as int;
          final int minQty = (p['minQuantity'] ?? p['minStock'] ?? 0) as int;
          final double price = (p['price'] ?? p['costPrice'] ?? 0).toDouble();

          if (qty <= minQty) lowStockCount++;

          final expiryRaw = p['expiryDate'] ?? p['expiry'];
          if (expiryRaw != null) {
            DateTime? expiry;
            if (expiryRaw is DateTime) {
              expiry = expiryRaw;
            } else if (expiryRaw is String) {
              expiry = DateTime.tryParse(expiryRaw);
            }
            if (expiry != null && expiry.isBefore(warningDate)) {
              expiringCount++;
            }
          }

          totalValue += qty * price;
        }
      }

      // --- Today's movements ---
      int todayMovements = 0;

      if (Hive.isBoxOpen('transactions')) {
        final txBox = Hive.box('transactions');
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);

        for (int i = 0; i < txBox.length; i++) {
          final tx = txBox.getAt(i);
          if (tx == null) continue;
          final Map<String, dynamic> t =
              tx is Map ? Map<String, dynamic>.from(tx) : <String, dynamic>{};
          final dateRaw = t['date'] ?? t['createdAt'] ?? '';
          if (dateRaw.toString().startsWith(todayStr)) {
            todayMovements++;
          }
        }
      }

      return AIContext(
        businessName: businessName,
        totalProducts: totalProducts,
        lowStockCount: lowStockCount,
        expiringCount: expiringCount,
        todayMovements: todayMovements,
        totalInventoryValue: totalValue,
        currency: currency,
      );
    } catch (e) {
      // If anything goes wrong reading Hive, return empty context.
      return const AIContext();
    }
  }

  String toPromptString() {
    final buf = StringBuffer();
    if (businessName != null && businessName!.isNotEmpty) {
      buf.writeln('Business: $businessName');
    }
    buf.writeln('Total products: $totalProducts');
    buf.writeln('Low-stock items: $lowStockCount');
    buf.writeln('Expiring soon (30 days): $expiringCount');
    buf.writeln("Today's stock movements: $todayMovements");
    buf.writeln('Total inventory value: $currency ${totalInventoryValue.toStringAsFixed(2)}');

    if (relevantProducts != null && relevantProducts!.isNotEmpty) {
      buf.writeln('\nRelevant products:');
      for (final p in relevantProducts!) {
        buf.writeln('  - ${p['name'] ?? 'Unknown'}: '
            'qty=${p['quantity'] ?? '?'}, '
            'price=${p['price'] ?? '?'}, '
            'category=${p['category'] ?? 'N/A'}');
      }
    }
    return buf.toString();
  }
}
