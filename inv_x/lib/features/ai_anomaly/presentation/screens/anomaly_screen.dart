import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../../../../data/hive/hive_initializer.dart';
import '../../data/models/anomaly_model.dart';

class AnomalyScreen extends StatelessWidget {
  const AnomalyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<AnomalyModel>(HiveBoxes.anomalies);
    final anomalies = box.values.toList()
      ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));

    final unresolved = anomalies.where((a) => !a.isResolved).toList();
    final resolved = anomalies.where((a) => a.isResolved).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🚨 Anomaly Detection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: anomalies.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✅', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 24),
                    const GradientText(
                      'All Clear!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No anomalies detected in your inventory.\n'
                      'The AI is continuously monitoring for issues.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (unresolved.isNotEmpty) ...[
                  Text(
                    'Active Anomalies (${unresolved.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...unresolved.map((a) => _AnomalyCard(anomaly: a)),
                ],
                if (resolved.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Resolved (${resolved.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...resolved.map((a) => _AnomalyCard(anomaly: a)),
                ],
              ],
            ),
    );
  }
}

class _AnomalyCard extends StatelessWidget {
  final AnomalyModel anomaly;
  const _AnomalyCard({required this.anomaly});

  Color get _severityColor {
    switch (anomaly.severity.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.error;
      case 'HIGH':
        return const Color(0xFFFF6B6B);
      case 'MEDIUM':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData get _typeIcon {
    switch (anomaly.type.toUpperCase()) {
      case 'STOCK':
        return Icons.inventory_2_rounded;
      case 'PRICE':
        return Icons.attach_money_rounded;
      case 'MOVEMENT':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_typeIcon, color: _severityColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    anomaly.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    anomaly.severity,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _severityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              anomaly.description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (anomaly.aiExplanation != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        anomaly.aiExplanation!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${anomaly.detectedAt.day}/${anomaly.detectedAt.month}/${anomaly.detectedAt.year}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                if (anomaly.isResolved)
                  Text(
                    '✅ Resolved',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _resolveAnomaly(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Mark Resolved',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resolveAnomaly(BuildContext context) {
    anomaly.isResolved = true;
    anomaly.resolvedAt = DateTime.now();
    anomaly.save();
    (context as Element).markNeedsBuild();
  }
}
