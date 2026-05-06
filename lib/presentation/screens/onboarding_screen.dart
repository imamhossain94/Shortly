import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const _seenKey = 'onboarding_seen';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey) ?? false;
  }

  static Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _iconAnimController;
  late Animation<double> _iconScale;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.link_rounded,
      gradientColors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
      bgAccent: Color(0x201A73E8),
      title: 'Shorten Any Link',
      subtitle:
          'Turn long, unwieldy URLs into clean short links in under a second. Choose from 7 powerful providers.',
    ),
    _OnboardingPage(
      icon: Icons.security_rounded,
      gradientColors: [Color(0xFF00897B), Color(0xFF004D40)],
      bgAccent: Color(0x2000897B),
      title: 'Verify Before You Click',
      subtitle:
          'Never get tricked by suspicious links. Instantly reveal the true destination of any shortened URL.',
    ),
    _OnboardingPage(
      icon: Icons.history_rounded,
      gradientColors: [Color(0xFF7B2FBE), Color(0xFF4A148C)],
      bgAccent: Color(0x207B2FBE),
      title: 'Track Your History',
      subtitle:
          'All your links, organised and searchable. Copy, share, or revisit any link with a single tap.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = CurvedAnimation(
      parent: _iconAnimController,
      curve: Curves.elasticOut,
    );
    _iconAnimController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconAnimController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await OnboardingScreen.markAsSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final page = _pages[_currentPage];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : Colors.white;
    final gradientEnd = isDark ? const Color(0xFF0A0A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientEnd,
                  page.bgAccent.withValues(alpha: isDark ? 0.2 : 0.05),
                  gradientEnd,
                ],
              ),
            ),
          ),

          // Glow blob top-right
          Positioned(
            top: -80,
            right: -80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.gradientColors[0].withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Glow blob bottom-left
          Positioned(
            bottom: -60,
            left: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.gradientColors[1].withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Skip button
          if (_currentPage < _pages.length - 1)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(
                      foregroundColor: subtitleColor,
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Page content
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _iconAnimController.reset();
              _iconAnimController.forward();
            },
            itemBuilder: (context, index) {
              final p = _pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.12),

                    // Icon with glow ring
                    ScaleTransition(
                      scale: _iconScale,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: p.gradientColors,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: p.gradientColors[0].withValues(alpha: 0.5),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          p.icon,
                          size: 58,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    Text(
                      p.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      p.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: subtitleColor,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Bottom controls
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dot indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final isSelected = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _pages[_currentPage].gradientColors[0]
                                : (isDark ? Colors.white24 : Colors.black12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _pages[_currentPage].gradientColors,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _pages[_currentPage]
                                  .gradientColors[0]
                                  .withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _nextPage,
                            child: Center(
                              child: Text(
                                _currentPage == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final List<Color> gradientColors;
  final Color bgAccent;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.gradientColors,
    required this.bgAccent,
    required this.title,
    required this.subtitle,
  });
}
