import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shortener_view.dart';
import 'expander_view.dart';
import 'history_view.dart';
import 'menu_screen.dart';
import '../../core/theme.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.link_rounded, label: 'My Links'),
    _NavItem(icon: Icons.verified_user_rounded, label: 'Verify'),
    _NavItem(icon: Icons.flag_rounded, label: 'Report'),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Update system UI based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark
            ? AppColors.darkSurface
            : Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Stack(
      children: [
        // Base background
        Container(color: isDark ? AppColors.darkBg : Colors.white),

        // Primary Dynamic Glow - Shifted Top-Left for natural lighting
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.4, -0.6),
              radius: 1.5,
              colors: [
                Color(0x4064B5F6),
                Color(0x2042A5F5),
                Colors.transparent,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Secondary Soft Glow - Bottom-Right to balance composition
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.8, 0.8),
              radius: 1.8,
              colors: [
                Color(0x1564B5F6),
                Color(0x0A42A5F5),
                Colors.transparent,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Foreground Content
        Scaffold(
          backgroundColor: Colors.transparent,
          drawer: _buildNavigationDrawer(context),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              ShortenerView(),
              HistoryView(),
              ExpanderView(),
              MenuScreen(),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(context, isDark),
        ),
      ],
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return NavigationDrawer(
      backgroundColor: isDark ? AppColors.darkSurface : null,
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        _onTabTapped(index);
        Navigator.pop(context);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Short',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textPrimary
                                    : Colors.black87,
                              ),
                        ),
                        TextSpan(
                          text: 'ly',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'URL Shortener & Expander',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 8),
        NavigationDrawerDestination(
          icon: const Icon(Icons.home_rounded),
          label: const Text('Home'),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.link_rounded),
          label: const Text('My Links'),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.verified_user_rounded),
          label: const Text('Verify / Expand'),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.flag_rounded),
          label: const Text('Report / Settings'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Divider(height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Support',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 8),
        NavigationDrawerDestination(
          icon: const Icon(Icons.help_outline_rounded),
          label: const Text('Help & FAQ'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _currentIndex == index;
              return Expanded(
                child: InkWell(
                  onTap: () => _onTabTapped(index),
                  splashColor: AppColors.accent.withValues(alpha: 0.08),
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
