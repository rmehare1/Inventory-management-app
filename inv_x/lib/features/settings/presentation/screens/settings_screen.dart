import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../../../../core/ai/ai_engine.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, dynamic>> _providerHealth = [];
  bool _loadingHealth = false;

  @override
  void initState() {
    super.initState();
    _loadHealth();
  }

  Future<void> _loadHealth() async {
    setState(() => _loadingHealth = true);
    try {
      final engine = InvXAIEngine.instance;
      await engine.initialize();
      final health = await engine.getProviderHealth();
      setState(() {
        _providerHealth = health;
        _loadingHealth = false;
      });
    } catch (_) {
      setState(() => _loadingHealth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('⚙️', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                const GradientText(
                  'Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // AI Provider Health
            _SectionHeader('🤖 AI Provider Health'),
            const SizedBox(height: 12),
            if (_loadingHealth)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              ..._providerHealth.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ProviderHealthCard(health: h),
                  )),

            const SizedBox(height: 24),
            _SectionHeader('🔑 Quick Actions'),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.category_rounded,
              title: 'Manage Categories',
              subtitle: 'Add, edit, delete categories',
              onTap: () => context.push('/categories'),
            ),
            _SettingsTile(
              icon: Icons.people_rounded,
              title: 'Manage Suppliers',
              subtitle: 'View and edit suppliers',
              onTap: () => context.push('/suppliers'),
            ),
            _SettingsTile(
              icon: Icons.receipt_long_rounded,
              title: 'Purchase Orders',
              subtitle: 'View and manage orders',
              onTap: () => context.push('/orders'),
            ),

            const SizedBox(height: 24),
            _SectionHeader('⚡ Preferences'),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.color_lens_rounded,
              title: 'Theme',
              subtitle: 'Dark mode (default)',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'About INV-X',
              subtitle: 'Version 1.0.0 • AI-Powered Inventory',
              onTap: () => _showAbout(context),
            ),

            const SizedBox(height: 24),

            // Cost analytics
            _SectionHeader('💰 AI Cost Analytics'),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CostRow(
                    label: 'Today\'s Cost',
                    value: '\$${InvXAIEngine.instance.todayCost.toStringAsFixed(6)}',
                  ),
                  const Divider(height: 16),
                  Text(
                    'Daily limit: \$1.00 • Paid fallback: Enabled',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'INV-X',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 INV-X. AI-Powered Inventory Management.',
      children: [
        const Text('\nPowered by 8 AI providers with cascading fallback.'),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ProviderHealthCard extends StatelessWidget {
  final Map<String, dynamic> health;
  const _ProviderHealthCard({required this.health});

  @override
  Widget build(BuildContext context) {
    final isAvailable = health['isAvailable'] == true;
    final name = health['name'] as String? ?? 'Unknown';
    final tier = health['tier'] as String? ?? '';
    final state = health['circuitState'] as String? ?? 'closed';
    final hasKey = health['hasApiKey'] == true;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAvailable ? AppColors.success : AppColors.error,
              boxShadow: [
                BoxShadow(
                  color: (isAvailable ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Tier: $tier • Circuit: $state • Key: ${hasKey ? "✅" : "❌"}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isAvailable ? 'Ready' : 'Down',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isAvailable ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGradientStart.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryGradientStart, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  const _CostRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
