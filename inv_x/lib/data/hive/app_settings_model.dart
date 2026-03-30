import 'package:hive/hive.dart';

@HiveType(typeId: 10)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  late String businessName;

  @HiveField(1)
  late String currency;

  @HiveField(2)
  late String currencyCode;

  @HiveField(3)
  late double dailyCostLimit;

  @HiveField(4)
  late bool enablePaidFallback;

  @HiveField(5)
  late bool enableVoice;

  @HiveField(6)
  late bool enableNotifications;

  @HiveField(7)
  late String themeMode;

  @HiveField(8)
  late int defaultLowStockThreshold;

  @HiveField(9)
  late bool isDemoMode;

  @HiveField(10)
  late String language;

  @HiveField(11)
  late bool isFirstLaunch;

  @HiveField(12)
  late bool isOnboardingComplete;

  AppSettingsModel({
    this.businessName = 'My Business',
    this.currency = '\u20B9',
    this.currencyCode = 'INR',
    this.dailyCostLimit = 1.0,
    this.enablePaidFallback = true,
    this.enableVoice = true,
    this.enableNotifications = true,
    this.themeMode = 'dark',
    this.defaultLowStockThreshold = 10,
    this.isDemoMode = false,
    this.language = 'en',
    this.isFirstLaunch = true,
    this.isOnboardingComplete = false,
  });

  AppSettingsModel copyWith({
    String? businessName,
    String? currency,
    String? currencyCode,
    double? dailyCostLimit,
    bool? enablePaidFallback,
    bool? enableVoice,
    bool? enableNotifications,
    String? themeMode,
    int? defaultLowStockThreshold,
    bool? isDemoMode,
    String? language,
    bool? isFirstLaunch,
    bool? isOnboardingComplete,
  }) {
    return AppSettingsModel(
      businessName: businessName ?? this.businessName,
      currency: currency ?? this.currency,
      currencyCode: currencyCode ?? this.currencyCode,
      dailyCostLimit: dailyCostLimit ?? this.dailyCostLimit,
      enablePaidFallback: enablePaidFallback ?? this.enablePaidFallback,
      enableVoice: enableVoice ?? this.enableVoice,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      themeMode: themeMode ?? this.themeMode,
      defaultLowStockThreshold:
          defaultLowStockThreshold ?? this.defaultLowStockThreshold,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      language: language ?? this.language,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }

  @override
  String toString() =>
      'AppSettingsModel(business: $businessName, theme: $themeMode, demo: $isDemoMode)';
}

class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = 10;

  @override
  AppSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return AppSettingsModel(
      businessName: fields[0] as String? ?? 'My Business',
      currency: fields[1] as String? ?? '\u20B9',
      currencyCode: fields[2] as String? ?? 'INR',
      dailyCostLimit: (fields[3] as num?)?.toDouble() ?? 1.0,
      enablePaidFallback: fields[4] as bool? ?? true,
      enableVoice: fields[5] as bool? ?? true,
      enableNotifications: fields[6] as bool? ?? true,
      themeMode: fields[7] as String? ?? 'dark',
      defaultLowStockThreshold: (fields[8] as num?)?.toInt() ?? 10,
      isDemoMode: fields[9] as bool? ?? false,
      language: fields[10] as String? ?? 'en',
      isFirstLaunch: fields[11] as bool? ?? true,
      isOnboardingComplete: fields[12] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer
      ..writeByte(13) // number of fields
      ..writeByte(0)
      ..write(obj.businessName)
      ..writeByte(1)
      ..write(obj.currency)
      ..writeByte(2)
      ..write(obj.currencyCode)
      ..writeByte(3)
      ..write(obj.dailyCostLimit)
      ..writeByte(4)
      ..write(obj.enablePaidFallback)
      ..writeByte(5)
      ..write(obj.enableVoice)
      ..writeByte(6)
      ..write(obj.enableNotifications)
      ..writeByte(7)
      ..write(obj.themeMode)
      ..writeByte(8)
      ..write(obj.defaultLowStockThreshold)
      ..writeByte(9)
      ..write(obj.isDemoMode)
      ..writeByte(10)
      ..write(obj.language)
      ..writeByte(11)
      ..write(obj.isFirstLaunch)
      ..writeByte(12)
      ..write(obj.isOnboardingComplete);
  }
}
