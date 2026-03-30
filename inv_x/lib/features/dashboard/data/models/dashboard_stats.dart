class DashboardStats {
  final int totalProducts;
  final double totalValue;
  final int lowStockCount;
  final int expiringCount;
  final int todayMovements;
  final int deadStockCount;

  const DashboardStats({
    this.totalProducts = 0,
    this.totalValue = 0.0,
    this.lowStockCount = 0,
    this.expiringCount = 0,
    this.todayMovements = 0,
    this.deadStockCount = 0,
  });

  /// Percentage of products that are low on stock.
  double get lowStockPercentage =>
      totalProducts > 0 ? (lowStockCount / totalProducts * 100) : 0;

  /// Percentage of products that are expiring soon.
  double get expiringPercentage =>
      totalProducts > 0 ? (expiringCount / totalProducts * 100) : 0;

  /// Average value per product.
  double get avgValuePerProduct =>
      totalProducts > 0 ? (totalValue / totalProducts) : 0;

  /// Whether the inventory health is considered good (low stock < 10%).
  bool get isHealthy => lowStockPercentage < 10;

  /// Percentage of dead stock items.
  double get deadStockPercentage =>
      totalProducts > 0 ? (deadStockCount / totalProducts * 100) : 0;

  DashboardStats copyWith({
    int? totalProducts,
    double? totalValue,
    int? lowStockCount,
    int? expiringCount,
    int? todayMovements,
    int? deadStockCount,
  }) {
    return DashboardStats(
      totalProducts: totalProducts ?? this.totalProducts,
      totalValue: totalValue ?? this.totalValue,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      expiringCount: expiringCount ?? this.expiringCount,
      todayMovements: todayMovements ?? this.todayMovements,
      deadStockCount: deadStockCount ?? this.deadStockCount,
    );
  }

  @override
  String toString() =>
      'DashboardStats(products: $totalProducts, value: $totalValue, lowStock: $lowStockCount)';
}
