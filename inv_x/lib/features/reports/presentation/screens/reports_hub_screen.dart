import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_text.dart';

class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    const GradientText(
                      'Reports',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  _ReportTile(
                    emoji: '📈',
                    title: 'Sales Report',
                    subtitle: 'Revenue, trends, top sellers',
                    color: AppColors.success,
                    onTap: () {},
                  ),
                  _ReportTile(
                    emoji: '📦',
                    title: 'Inventory Report',
                    subtitle: 'Stock levels, turnover',
                    color: AppColors.info,
                    onTap: () {},
                  ),
                  _ReportTile(
                    emoji: '🔮',
                    title: 'Forecast Report',
                    subtitle: 'AI predictions, demand',
                    color: AppColors.primaryGradientStart,
                    onTap: () => context.push('/forecast'),
                  ),
                  _ReportTile(
                    emoji: '🚨',
                    title: 'Anomaly Report',
                    subtitle: 'Detected issues, audit',
                    color: AppColors.error,
                    onTap: () => context.push('/anomalies'),
                  ),
                  _ReportTile(
                    emoji: '🤝',
                    title: 'Supplier Report',
                    subtitle: 'Performance, delivery',
                    color: AppColors.warning,
                    onTap: () => context.push('/suppliers'),
                  ),
                  _ReportTile(
                    emoji: '💰',
                    title: 'Financial Summary',
                    subtitle: 'Profit, margins, costs',
                    color: const Color(0xFF00D1FF),
                    onTap: () {},
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
              ),
            ),

            // Recent reports section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'AI-Generated Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🤖', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'Get AI Report',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ask the AI assistant to generate detailed reports '
                        'about your inventory, sales trends, or supplier '
                        'performance.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.smart_toy_rounded, size: 18),
                        label: const Text('Generate Report →'),
                        onPressed: () => context.go('/ai-chat'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ReportTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
