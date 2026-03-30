import 'package:hive/hive.dart';

@HiveType(typeId: 6)
class ChatMessageModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String text;

  @HiveField(2)
  late bool isUser;

  @HiveField(3)
  String? provider;

  @HiveField(4)
  String? tier;

  @HiveField(5)
  late double cost;

  @HiveField(6)
  late int latencyMs;

  @HiveField(7)
  late int fallbacksAttempted;

  @HiveField(8)
  late DateTime timestamp;

  @HiveField(9)
  List<String>? failedProviders;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    this.provider,
    this.tier,
    this.cost = 0.0,
    this.latencyMs = 0,
    this.fallbacksAttempted = 0,
    required this.timestamp,
    this.failedProviders,
  });

  ChatMessageModel copyWith({
    String? id,
    String? text,
    bool? isUser,
    String? provider,
    String? tier,
    double? cost,
    int? latencyMs,
    int? fallbacksAttempted,
    DateTime? timestamp,
    List<String>? failedProviders,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      provider: provider ?? this.provider,
      tier: tier ?? this.tier,
      cost: cost ?? this.cost,
      latencyMs: latencyMs ?? this.latencyMs,
      fallbacksAttempted: fallbacksAttempted ?? this.fallbacksAttempted,
      timestamp: timestamp ?? this.timestamp,
      failedProviders: failedProviders ?? this.failedProviders,
    );
  }

  @override
  String toString() =>
      'ChatMessageModel(id: $id, isUser: $isUser, provider: $provider)';
}

class ChatMessageModelAdapter extends TypeAdapter<ChatMessageModel> {
  @override
  final int typeId = 6;

  @override
  ChatMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return ChatMessageModel(
      id: fields[0] as String,
      text: fields[1] as String,
      isUser: fields[2] as bool,
      provider: fields[3] as String?,
      tier: fields[4] as String?,
      cost: (fields[5] as num?)?.toDouble() ?? 0.0,
      latencyMs: (fields[6] as num?)?.toInt() ?? 0,
      fallbacksAttempted: (fields[7] as num?)?.toInt() ?? 0,
      timestamp: fields[8] as DateTime,
      failedProviders: (fields[9] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageModel obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.isUser)
      ..writeByte(3)
      ..write(obj.provider)
      ..writeByte(4)
      ..write(obj.tier)
      ..writeByte(5)
      ..write(obj.cost)
      ..writeByte(6)
      ..write(obj.latencyMs)
      ..writeByte(7)
      ..write(obj.fallbacksAttempted)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.failedProviders);
  }
}
