import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String sku;

  @HiveField(4)
  String? barcode;

  @HiveField(5)
  late String categoryId;

  @HiveField(6)
  late double costPrice;

  @HiveField(7)
  late double sellingPrice;

  @HiveField(8)
  late int currentStock;

  @HiveField(9)
  late int minimumStock;

  @HiveField(10)
  late int maximumStock;

  @HiveField(11)
  late String unit; // 'pcs', 'kg', 'liters', 'boxes'

  @HiveField(12)
  String? imagePath;

  @HiveField(13)
  String? supplierId;

  @HiveField(14)
  DateTime? expiryDate;

  @HiveField(15)
  late DateTime createdAt;

  @HiveField(16)
  late DateTime updatedAt;

  @HiveField(17)
  String? batchNumber;

  @HiveField(18)
  String? warehouseLocation;

  @HiveField(19)
  late List<String> tags;

  @HiveField(20)
  late bool isActive;

  @HiveField(21)
  double? weight;

  @HiveField(22)
  Map<String, dynamic>? customFields;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.sku,
    this.barcode,
    required this.categoryId,
    required this.costPrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.unit,
    this.imagePath,
    this.supplierId,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
    this.batchNumber,
    this.warehouseLocation,
    List<String>? tags,
    this.isActive = true,
    this.weight,
    this.customFields,
  }) : tags = tags ?? [];

  // Computed getters
  double get profitMargin =>
      sellingPrice > 0 ? ((sellingPrice - costPrice) / sellingPrice * 100) : 0;

  bool get isLowStock => currentStock <= minimumStock;

  bool get isExpiringSoon =>
      expiryDate != null &&
      expiryDate!.difference(DateTime.now()).inDays <= 7 &&
      expiryDate!.isAfter(DateTime.now());

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  double get stockValue => currentStock * costPrice;

  double get stockPercentage =>
      maximumStock > 0 ? (currentStock / maximumStock * 100).clamp(0, 100) : 0;

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? sku,
    String? barcode,
    String? categoryId,
    double? costPrice,
    double? sellingPrice,
    int? currentStock,
    int? minimumStock,
    int? maximumStock,
    String? unit,
    String? imagePath,
    String? supplierId,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? batchNumber,
    String? warehouseLocation,
    List<String>? tags,
    bool? isActive,
    double? weight,
    Map<String, dynamic>? customFields,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      maximumStock: maximumStock ?? this.maximumStock,
      unit: unit ?? this.unit,
      imagePath: imagePath ?? this.imagePath,
      supplierId: supplierId ?? this.supplierId,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      batchNumber: batchNumber ?? this.batchNumber,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      weight: weight ?? this.weight,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  String toString() => 'ProductModel(id: $id, name: $name, sku: $sku)';
}

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 0;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return ProductModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      sku: fields[3] as String,
      barcode: fields[4] as String?,
      categoryId: fields[5] as String,
      costPrice: (fields[6] as num).toDouble(),
      sellingPrice: (fields[7] as num).toDouble(),
      currentStock: (fields[8] as num).toInt(),
      minimumStock: (fields[9] as num).toInt(),
      maximumStock: (fields[10] as num).toInt(),
      unit: fields[11] as String,
      imagePath: fields[12] as String?,
      supplierId: fields[13] as String?,
      expiryDate: fields[14] as DateTime?,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
      batchNumber: fields[17] as String?,
      warehouseLocation: fields[18] as String?,
      tags: (fields[19] as List?)?.cast<String>() ?? [],
      isActive: fields[20] as bool? ?? true,
      weight: fields[21] as double?,
      customFields: (fields[22] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(23) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.sku)
      ..writeByte(4)
      ..write(obj.barcode)
      ..writeByte(5)
      ..write(obj.categoryId)
      ..writeByte(6)
      ..write(obj.costPrice)
      ..writeByte(7)
      ..write(obj.sellingPrice)
      ..writeByte(8)
      ..write(obj.currentStock)
      ..writeByte(9)
      ..write(obj.minimumStock)
      ..writeByte(10)
      ..write(obj.maximumStock)
      ..writeByte(11)
      ..write(obj.unit)
      ..writeByte(12)
      ..write(obj.imagePath)
      ..writeByte(13)
      ..write(obj.supplierId)
      ..writeByte(14)
      ..write(obj.expiryDate)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.batchNumber)
      ..writeByte(18)
      ..write(obj.warehouseLocation)
      ..writeByte(19)
      ..write(obj.tags)
      ..writeByte(20)
      ..write(obj.isActive)
      ..writeByte(21)
      ..write(obj.weight)
      ..writeByte(22)
      ..write(obj.customFields);
  }
}
