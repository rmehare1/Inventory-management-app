import 'package:hive/hive.dart';

@HiveType(typeId: 5)
class OrderItemModel extends HiveObject {
  @HiveField(0)
  late String productId;

  @HiveField(1)
  late String productName;

  @HiveField(2)
  late int quantity;

  @HiveField(3)
  late double unitPrice;

  @HiveField(4)
  late double totalPrice;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  OrderItemModel copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  String toString() =>
      'OrderItemModel(productId: $productId, qty: $quantity, total: $totalPrice)';
}

class OrderItemModelAdapter extends TypeAdapter<OrderItemModel> {
  @override
  final int typeId = 5;

  @override
  OrderItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return OrderItemModel(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: (fields[2] as num).toInt(),
      unitPrice: (fields[3] as num).toDouble(),
      totalPrice: (fields[4] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderItemModel obj) {
    writer
      ..writeByte(5) // number of fields
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.totalPrice);
  }
}
