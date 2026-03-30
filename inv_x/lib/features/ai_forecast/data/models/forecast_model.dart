import 'package:hive/hive.dart';

@HiveType(typeId: 8)
class ForecastModel extends HiveObject {
  @HiveField(0)
  late String productId;

  @HiveField(1)
  late List<double> predictedDemand;

  @HiveField(2)
  late double confidence;

  @HiveField(3)
  late String recommendation;

  @HiveField(4)
  late String trendDirection; // 'UP', 'DOWN', 'STABLE'

  @HiveField(5)
  late DateTime generatedAt;

  @HiveField(6)
  late String generatedBy;

  ForecastModel({
    required this.productId,
    List<double>? predictedDemand,
    required this.confidence,
    required this.recommendation,
    required this.trendDirection,
    required this.generatedAt,
    required this.generatedBy,
  }) : predictedDemand = predictedDemand ?? [];

  ForecastModel copyWith({
    String? productId,
    List<double>? predictedDemand,
    double? confidence,
    String? recommendation,
    String? trendDirection,
    DateTime? generatedAt,
    String? generatedBy,
  }) {
    return ForecastModel(
      productId: productId ?? this.productId,
      predictedDemand: predictedDemand ?? this.predictedDemand,
      confidence: confidence ?? this.confidence,
      recommendation: recommendation ?? this.recommendation,
      trendDirection: trendDirection ?? this.trendDirection,
      generatedAt: generatedAt ?? this.generatedAt,
      generatedBy: generatedBy ?? this.generatedBy,
    );
  }

  @override
  String toString() =>
      'ForecastModel(productId: $productId, trend: $trendDirection, confidence: $confidence)';
}

class ForecastModelAdapter extends TypeAdapter<ForecastModel> {
  @override
  final int typeId = 8;

  @override
  ForecastModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return ForecastModel(
      productId: fields[0] as String,
      predictedDemand: (fields[1] as List?)?.cast<double>() ?? [],
      confidence: (fields[2] as num).toDouble(),
      recommendation: fields[3] as String,
      trendDirection: fields[4] as String,
      generatedAt: fields[5] as DateTime,
      generatedBy: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ForecastModel obj) {
    writer
      ..writeByte(7) // number of fields
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.predictedDemand)
      ..writeByte(2)
      ..write(obj.confidence)
      ..writeByte(3)
      ..write(obj.recommendation)
      ..writeByte(4)
      ..write(obj.trendDirection)
      ..writeByte(5)
      ..write(obj.generatedAt)
      ..writeByte(6)
      ..write(obj.generatedBy);
  }
}
