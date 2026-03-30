import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingData(
      emoji: '🤖',
      title: 'Welcome to INV-X',
      subtitle: 'AI-Powered Autonomous\nInventory Management',
      description:
          'The smartest way to manage inventory. INV-X thinks, predicts, '
          'and acts — so you don\'t have to.',
    ),
    _OnboardingData(
      emoji: '🧠',
      title: 'Multi-AI Engine',
      subtitle: '8 AI Providers\nAutomatic Fallback',
      description:
          'Uses free AI providers first, paid only when needed. '
          'Your costs stay near zero while getting powerful AI features.',
    ),
    _OnboardingData(
      emoji: '📊',
      title: 'Smart Features',
      subtitle: 'Forecast • Detect • Report',
      description:
          'Demand forecasting, anomaly detection, smart scanning, '
          'and AI-generated business reports — all built in.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Skip'),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _buildPage(_pages[i]),
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: _currentPage == i
                        ? AppColors.primaryGradient
                        : null,
                    color: _currentPage == i ? null : AppColors.textTertiary,
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      context.go('/dashboard');
                    }
                  },
                  label: _currentPage < _pages.length - 1
                      ? 'Next →'
                      : '🚀 Get Started',
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 32),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
