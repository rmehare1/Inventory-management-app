import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/hive/hive_initializer.dart';
import 'data/hive/app_settings_model.dart';
import 'data/seed/seed_data_generator.dart';
import 'core/ai/ai_engine.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Initializes all app-level services before [runApp].
///
/// Call `await bootstrap()` in `main()`.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Lock to portrait on mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dark system UI overlay
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A0F),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Hive and open all boxes
  await HiveInitializer.init();

  // Initialize AI Engine
  await InvXAIEngine.instance.initialize();

  // Seed demo data on first launch
  await _seedIfFirstLaunch();
}

Future<void> _seedIfFirstLaunch() async {
  final settingsBox = Hive.box<AppSettingsModel>(HiveBoxes.appSettings);

  if (settingsBox.isEmpty) {
    // First launch — create default settings and seed demo data
    final settings = AppSettingsModel();
    await settingsBox.put('default', settings);
    await SeedDataGenerator.generateAll();
  } else {
    final settings = settingsBox.get('default');
    if (settings != null && settings.isDemoMode && settingsBox.length == 1) {
      // Demo mode enabled but data might be missing
      final productsBox = Hive.box(HiveBoxes.products);
      if (productsBox.isEmpty) {
        await SeedDataGenerator.generateAll();
      }
    }
  }
}
