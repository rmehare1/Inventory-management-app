import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class StockMovementModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String productId;

  @HiveField(2)
  late String type; // 'IN', 'OUT', 'ADJUST', 'RETURN', 'DAMAGE'

  @HiveField(3)
  late int quantity;

  @HiveField(4)
  late int previousStock;

  @HiveField(5)
  late int newStock;

  @HiveField(6)
  String? reason;

  @HiveField(7)
  String? referenceId;

  @HiveField(8)
  late DateTime timestamp;

  @HiveField(9)
  late bool isAnomalous;

  @HiveField(10)
  String? anomalyReason;

  StockMovementModel({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.reason,
    this.referenceId,
    required this.timestamp,
    this.isAnomalous = false,
    this.anomalyReason,
  });

  StockMovementModel copyWith({
    String? id,
    String? productId,
    String? type,
    int? quantity,
    int? previousStock,
    int? newStock,
    String? reason,
    String? referenceId,
    DateTime? timestamp,
    bool? isAnomalous,
    String? anomalyReason,
  }) {
    return StockMovementModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      previousStock: previousStock ?? this.previousStock,
      newStock: newStock ?? this.newStock,
      reason: reason ?? this.reason,
      referenceId: referenceId ?? this.referenceId,
      timestamp: timestamp ?? this.timestamp,
      isAnomalous: isAnomalous ?? this.isAnomalous,
      anomalyReason: anomalyReason ?? this.anomalyReason,
    );
  }

  @override
  String toString() =>
      'StockMovementModel(id: $id, productId: $productId, type: $type, qty: $quantity)';
}

class StockMovementModelAdapter extends TypeAdapter<StockMovementModel> {
  @override
  final int typeId = 3;

  @override
  StockMovementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return StockMovementModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      type: fields[2] as String,
      quantity: (fields[3] as num).toInt(),
      previousStock: (fields[4] as num).toInt(),
      newStock: (fields[5] as num).toInt(),
      reason: fields[6] as String?,
      referenceId: fields[7] as String?,
      timestamp: fields[8] as DateTime,
      isAnomalous: fields[9] as bool? ?? false,
      anomalyReason: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StockMovementModel obj) {
    writer
      ..writeByte(11) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.previousStock)
      ..writeByte(5)
      ..write(obj.newStock)
      ..writeByte(6)
      ..write(obj.reason)
      ..writeByte(7)
      ..write(obj.referenceId)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.isAnomalous)
      ..writeByte(10)
      ..write(obj.anomalyReason);
  }
}
