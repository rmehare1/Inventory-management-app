import 'package:hive/hive.dart';
import 'package:inv_x/features/orders/data/models/order_item_model.dart';

@HiveType(typeId: 4)
class PurchaseOrderModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String supplierId;

  @HiveField(2)
  late List<OrderItemModel> items;

  @HiveField(3)
  late double totalAmount;

  @HiveField(4)
  late String status; // 'DRAFT', 'PENDING', 'CONFIRMED', 'SHIPPED', 'RECEIVED', 'CANCELLED'

  @HiveField(5)
  late DateTime orderDate;

  @HiveField(6)
  DateTime? expectedDelivery;

  @HiveField(7)
  DateTime? receivedDate;

  @HiveField(8)
  late bool isAiGenerated;

  @HiveField(9)
  String? aiReason;

  PurchaseOrderModel({
    required this.id,
    required this.supplierId,
    List<OrderItemModel>? items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.expectedDelivery,
    this.receivedDate,
    this.isAiGenerated = false,
    this.aiReason,
  }) : items = items ?? [];

  PurchaseOrderModel copyWith({
    String? id,
    String? supplierId,
    List<OrderItemModel>? items,
    double? totalAmount,
    String? status,
    DateTime? orderDate,
    DateTime? expectedDelivery,
    DateTime? receivedDate,
    bool? isAiGenerated,
    String? aiReason,
  }) {
    return PurchaseOrderModel(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      receivedDate: receivedDate ?? this.receivedDate,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      aiReason: aiReason ?? this.aiReason,
    );
  }

  @override
  String toString() =>
      'PurchaseOrderModel(id: $id, status: $status, total: $totalAmount)';
}

class PurchaseOrderModelAdapter extends TypeAdapter<PurchaseOrderModel> {
  @override
  final int typeId = 4;

  @override
  PurchaseOrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return PurchaseOrderModel(
      id: fields[0] as String,
      supplierId: fields[1] as String,
      items: (fields[2] as List?)?.cast<OrderItemModel>() ?? [],
      totalAmount: (fields[3] as num).toDouble(),
      status: fields[4] as String,
      orderDate: fields[5] as DateTime,
      expectedDelivery: fields[6] as DateTime?,
      receivedDate: fields[7] as DateTime?,
      isAiGenerated: fields[8] as bool? ?? false,
      aiReason: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseOrderModel obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.supplierId)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.totalAmount)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.orderDate)
      ..writeByte(6)
      ..write(obj.expectedDelivery)
      ..writeByte(7)
      ..write(obj.receivedDate)
      ..writeByte(8)
      ..write(obj.isAiGenerated)
      ..writeByte(9)
      ..write(obj.aiReason);
  }
}
