import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class SupplierModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String email;

  @HiveField(3)
  late String phone;

  @HiveField(4)
  late String address;

  @HiveField(5)
  late double reliabilityScore;

  @HiveField(6)
  late int avgDeliveryDays;

  @HiveField(7)
  late List<String> productIds;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  String? notes;

  SupplierModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.reliabilityScore = 0.0,
    this.avgDeliveryDays = 0,
    List<String>? productIds,
    required this.createdAt,
    this.notes,
  }) : productIds = productIds ?? [];

  SupplierModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    double? reliabilityScore,
    int? avgDeliveryDays,
    List<String>? productIds,
    DateTime? createdAt,
    String? notes,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
      avgDeliveryDays: avgDeliveryDays ?? this.avgDeliveryDays,
      productIds: productIds ?? this.productIds,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() => 'SupplierModel(id: $id, name: $name)';
}

class SupplierModelAdapter extends TypeAdapter<SupplierModel> {
  @override
  final int typeId = 2;

  @override
  SupplierModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return SupplierModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      address: fields[4] as String,
      reliabilityScore: (fields[5] as num?)?.toDouble() ?? 0.0,
      avgDeliveryDays: (fields[6] as num?)?.toInt() ?? 0,
      productIds: (fields[7] as List?)?.cast<String>() ?? [],
      createdAt: fields[8] as DateTime,
      notes: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SupplierModel obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.reliabilityScore)
      ..writeByte(6)
      ..write(obj.avgDeliveryDays)
      ..writeByte(7)
      ..write(obj.productIds)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.notes);
  }
}
