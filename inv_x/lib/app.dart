import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/hive/hive_initializer.dart';
import 'data/hive/app_settings_model.dart';

class InvXApp extends ConsumerWidget {
  const InvXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFirstLaunch = _checkFirstLaunch();
    final router = createRouter(isFirstLaunch: isFirstLaunch);

    return MaterialApp.router(
      title: 'INV-X',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }

  bool _checkFirstLaunch() {
    try {
      final box = Hive.box<AppSettingsModel>(HiveBoxes.appSettings);
      if (box.isEmpty) return true;
      final settings = box.get('default');
      return settings?.isFirstLaunch ?? true;
    } catch (_) {
      return true;
    }
  }
}
