import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  int _stepIndex = 0;

  final _steps = [
    'Initializing AI Engine...',
    'Loading inventory data...',
    'Checking provider health...',
    'Ready! ✅',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _runSplashSequence();
  }

  Future<void> _runSplashSequence() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _stepIndex = i);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) context.go('/dashboard');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Text(
                  'INV-X',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI-Powered Inventory',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
              // Loading steps
              SizedBox(
                width: 260,
                child: Column(
                  children: List.generate(_steps.length, (i) {
                    final isActive = i <= _stepIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? AppColors.primaryGradientStart
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 13,
                              color: isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            ),
                            child: Text(_steps[i]),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  value: (_stepIndex + 1) / _steps.length,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.primaryGradientStart,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
