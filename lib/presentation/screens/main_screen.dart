import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shortener_view.dart';
import 'expander_view.dart';
import 'history_view.dart';
import 'menu_screen.dart';
import 'help_faq_screen.dart';
import 'about_screen.dart';
import 'feedback_screen.dart';
import '../../core/theme.dart';
import '../../core/services/iap_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_shortener/l10n/app_localizations.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  String _version = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = 'v${info.version}';
      });
    }
  }

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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
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
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.fromLTRB(28, 64, 28, 24),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.accent,
                        size: 28,
                      ),
                    ),
                    if (IapService().isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFF5A623)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF5A623).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium_rounded, size: 14, color: Colors.black87),
                            SizedBox(width: 4),
                            Text(
                              'PRO',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Short',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: 'ly',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Premium Link Management',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: 14,
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
                  label: AppLocalizations.of(context)!.appName,
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTabTapped(0),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.link_rounded,
                  label: AppLocalizations.of(context)!.myLinks,
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTabTapped(1),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.verified_user_rounded,
                  label: AppLocalizations.of(context)!.expandAndVerify,
                  isSelected: _currentIndex == 2,
                  onTap: () => _onTabTapped(2),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  label: AppLocalizations.of(context)!.settings,
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpFaqScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.feedback_outlined,
                  label: AppLocalizations.of(context)!.feedback,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  label: AppLocalizations.of(context)!.about,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
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
                      _version,
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
          Navigator.pop(context);
          onTap();
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: SizedBox(
            height: 56,
            child: Stack(
              children: [
                // Animated pill background
                AnimatedAlign(
                  alignment: Alignment(
                    -1 + (_currentIndex * (2 / 3)),
                    0,
                  ),
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  child: FractionallySizedBox(
                    widthFactor: 1 / 4,
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: isDark ? 0.18 : 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                // Nav items row
                Row(
                  children: List.generate(4, (index) {
                    final isSelected = _currentIndex == index;
                    String label = '';
                    IconData icon = Icons.home;
                    if (index == 0) {
                      label = 'Home'; // Fallback to hardcoded since no small home text
                      icon = Icons.home_rounded;
                    } else if (index == 1) {
                      label = AppLocalizations.of(context)!.myLinks;
                      icon = Icons.link_rounded;
                    } else if (index == 2) {
                      label = AppLocalizations.of(context)!.expand;
                      icon = Icons.verified_user_rounded;
                    } else if (index == 3) {
                      label = AppLocalizations.of(context)!.settings;
                      icon = Icons.settings_rounded;
                    }
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabTapped(index),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  icon,
                                  size: isSelected ? 22 : 20,
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                child: isSelected
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

