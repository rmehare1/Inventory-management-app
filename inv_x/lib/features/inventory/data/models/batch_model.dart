import 'package:hive/hive.dart';

@HiveType(typeId: 11)
class BatchModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String productId;

  @HiveField(2)
  late String batchNumber;

  @HiveField(3)
  late int quantity;

  @HiveField(4)
  late DateTime manufacturingDate;

  @HiveField(5)
  late DateTime expiryDate;

  @HiveField(6)
  late DateTime receivedDate;

  BatchModel({
    required this.id,
    required this.productId,
    required this.batchNumber,
    required this.quantity,
    required this.manufacturingDate,
    required this.expiryDate,
    required this.receivedDate,
  });

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  bool get isExpiringSoon =>
      expiryDate.difference(DateTime.now()).inDays <= 7 &&
      expiryDate.isAfter(DateTime.now());

  BatchModel copyWith({
    String? id,
    String? productId,
    String? batchNumber,
    int? quantity,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    DateTime? receivedDate,
  }) {
    return BatchModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      batchNumber: batchNumber ?? this.batchNumber,
      quantity: quantity ?? this.quantity,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      expiryDate: expiryDate ?? this.expiryDate,
      receivedDate: receivedDate ?? this.receivedDate,
    );
  }

  @override
  String toString() =>
      'BatchModel(id: $id, productId: $productId, batch: $batchNumber)';
}

class BatchModelAdapter extends TypeAdapter<BatchModel> {
  @override
  final int typeId = 11;

  @override
  BatchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return BatchModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      batchNumber: fields[2] as String,
      quantity: (fields[3] as num).toInt(),
      manufacturingDate: fields[4] as DateTime,
      expiryDate: fields[5] as DateTime,
      receivedDate: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BatchModel obj) {
    writer
      ..writeByte(7) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.batchNumber)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.manufacturingDate)
      ..writeByte(5)
      ..write(obj.expiryDate)
      ..writeByte(6)
      ..write(obj.receivedDate);
  }
}
