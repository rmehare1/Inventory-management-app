part of 'app_router.dart';

/// Bottom navigation shell scaffold with glassmorphism nav bar.
class ShellScaffold extends StatefulWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  int _currentIndex = 0;

  static const _tabs = [
    _NavTab('/dashboard', Icons.home_rounded, 'Home'),
    _NavTab('/inventory', Icons.inventory_2_rounded, 'Inventory'),
    _NavTab('/ai-chat', Icons.smart_toy_rounded, 'AI'),
    _NavTab('/reports', Icons.bar_chart_rounded, 'Reports'),
    _NavTab('/more', Icons.more_horiz_rounded, 'More'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync index with current route
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) {
        if (_currentIndex != i) {
          setState(() => _currentIndex = i);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isActive = _currentIndex == index;
                return _buildNavItem(tab, isActive, index);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavTab tab, bool isActive, int index) {
    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() => _currentIndex = index);
          context.go(tab.path);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGradientStart.withValues(alpha: 0.15),
                    AppColors.primaryGradientEnd.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: isActive
                  ? (bounds) => AppColors.primaryGradient.createShader(bounds)
                  : (bounds) => const LinearGradient(
                        colors: [AppColors.textTertiary, AppColors.textTertiary],
                      ).createShader(bounds),
              child: Icon(
                tab.icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 2),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: Text(
                  tab.label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavTab {
  final String path;
  final IconData icon;
  final String label;
  const _NavTab(this.path, this.icon, this.label);
}
