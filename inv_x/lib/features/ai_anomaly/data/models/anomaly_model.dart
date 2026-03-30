import 'package:hive/hive.dart';

@HiveType(typeId: 9)
class AnomalyModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String type;

  @HiveField(2)
  late String severity;

  @HiveField(3)
  late String title;

  @HiveField(4)
  late String description;

  @HiveField(5)
  String? productId;

  @HiveField(6)
  String? aiExplanation;

  @HiveField(7)
  late bool isResolved;

  @HiveField(8)
  late DateTime detectedAt;

  @HiveField(9)
  DateTime? resolvedAt;

  AnomalyModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    this.productId,
    this.aiExplanation,
    this.isResolved = false,
    required this.detectedAt,
    this.resolvedAt,
  });

  AnomalyModel copyWith({
    String? id,
    String? type,
    String? severity,
    String? title,
    String? description,
    String? productId,
    String? aiExplanation,
    bool? isResolved,
    DateTime? detectedAt,
    DateTime? resolvedAt,
  }) {
    return AnomalyModel(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      description: description ?? this.description,
      productId: productId ?? this.productId,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      isResolved: isResolved ?? this.isResolved,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  String toString() =>
      'AnomalyModel(id: $id, type: $type, severity: $severity, resolved: $isResolved)';
}

class AnomalyModelAdapter extends TypeAdapter<AnomalyModel> {
  @override
  final int typeId = 9;

  @override
  AnomalyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return AnomalyModel(
      id: fields[0] as String,
      type: fields[1] as String,
      severity: fields[2] as String,
      title: fields[3] as String,
      description: fields[4] as String,
      productId: fields[5] as String?,
      aiExplanation: fields[6] as String?,
      isResolved: fields[7] as bool? ?? false,
      detectedAt: fields[8] as DateTime,
      resolvedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AnomalyModel obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.severity)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.productId)
      ..writeByte(6)
      ..write(obj.aiExplanation)
      ..writeByte(7)
      ..write(obj.isResolved)
      ..writeByte(8)
      ..write(obj.detectedAt)
      ..writeByte(9)
      ..write(obj.resolvedAt);
  }
}
