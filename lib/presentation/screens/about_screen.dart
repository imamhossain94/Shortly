import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${info.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'About Shortly',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimary : Colors.black87,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? AppColors.textPrimary : Colors.black87,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      size: 64,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Short',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                        TextSpan(
                          text: 'ly',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _version.isEmpty ? 'Loading version...' : 'Version $_version',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondary : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Shortly is a premium URL shortening and link management tool. Designed for simplicity, speed, and privacy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    '© 2026 Shortly App',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
      ],
    );
  }
}
