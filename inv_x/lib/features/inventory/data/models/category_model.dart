import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String emoji;

  @HiveField(3)
  late String colorHex;

  @HiveField(4)
  String? parentId;

  @HiveField(5)
  late DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorHex,
    this.parentId,
    required this.createdAt,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? emoji,
    String? colorHex,
    String? parentId,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'CategoryModel(id: $id, name: $name, emoji: $emoji)';
}

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 1;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return CategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      emoji: fields[2] as String,
      colorHex: fields[3] as String,
      parentId: fields[4] as String?,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(6) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.colorHex)
      ..writeByte(4)
      ..write(obj.parentId)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}
