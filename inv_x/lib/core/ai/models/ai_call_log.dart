import 'package:hive/hive.dart';

@HiveType(typeId: 7)
class AiCallLog extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String provider;

  @HiveField(2)
  late String tier;

  @HiveField(3)
  late bool success;

  @HiveField(4)
  late int latencyMs;

  @HiveField(5)
  late double cost;

  @HiveField(6)
  String? errorMessage;

  @HiveField(7)
  late List<String> failedProviders;

  @HiveField(8)
  late DateTime timestamp;

  @HiveField(9)
  late String requestType;

  AiCallLog({
    required this.id,
    required this.provider,
    required this.tier,
    required this.success,
    required this.latencyMs,
    required this.cost,
    this.errorMessage,
    List<String>? failedProviders,
    required this.timestamp,
    required this.requestType,
  }) : failedProviders = failedProviders ?? [];

  AiCallLog copyWith({
    String? id,
    String? provider,
    String? tier,
    bool? success,
    int? latencyMs,
    double? cost,
    String? errorMessage,
    List<String>? failedProviders,
    DateTime? timestamp,
    String? requestType,
  }) {
    return AiCallLog(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      tier: tier ?? this.tier,
      success: success ?? this.success,
      latencyMs: latencyMs ?? this.latencyMs,
      cost: cost ?? this.cost,
      errorMessage: errorMessage ?? this.errorMessage,
      failedProviders: failedProviders ?? this.failedProviders,
      timestamp: timestamp ?? this.timestamp,
      requestType: requestType ?? this.requestType,
    );
  }

  @override
  String toString() =>
      'AiCallLog(id: $id, provider: $provider, success: $success)';
}

class AiCallLogAdapter extends TypeAdapter<AiCallLog> {
  @override
  final int typeId = 7;

  @override
  AiCallLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return AiCallLog(
      id: fields[0] as String,
      provider: fields[1] as String,
      tier: fields[2] as String,
      success: fields[3] as bool,
      latencyMs: (fields[4] as num).toInt(),
      cost: (fields[5] as num).toDouble(),
      errorMessage: fields[6] as String?,
      failedProviders: (fields[7] as List?)?.cast<String>() ?? [],
      timestamp: fields[8] as DateTime,
      requestType: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AiCallLog obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.provider)
      ..writeByte(2)
      ..write(obj.tier)
      ..writeByte(3)
      ..write(obj.success)
      ..writeByte(4)
      ..write(obj.latencyMs)
      ..writeByte(5)
      ..write(obj.cost)
      ..writeByte(6)
      ..write(obj.errorMessage)
      ..writeByte(7)
      ..write(obj.failedProviders)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.requestType);
  }
}
