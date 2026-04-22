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
    
    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent,
                  AppColors.accent.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Short',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'ly',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Premium URL Shortener',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTabTapped(0),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.link_rounded,
                  label: 'My Links',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTabTapped(1),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.verified_user_rounded,
                  label: 'Verify Link',
                  isSelected: _currentIndex == 2,
                  onTap: () => _onTabTapped(2),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: _currentIndex == 3,
                  onTap: () => _onTabTapped(3),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Divider(),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'SUPPORT',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  label: 'Help & FAQ',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  label: 'About Shortly',
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          // Bottom section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'v3.0.2',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Icon(
                      Icons.copyright_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          onTap();
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.accent.withValues(alpha: 0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? AppColors.accent 
                    : (isDark ? AppColors.textSecondary : Colors.black54),
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? AppColors.accent 
                      : (isDark ? AppColors.textPrimary : Colors.black87),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
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
