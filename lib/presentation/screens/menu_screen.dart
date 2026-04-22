import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_shortly/l10n/app_localizations.dart';
import '../../core/theme.dart';
import '../widgets/app_custom_bar.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header (fixed, non-scrollable) ────────────────────────────────
        const AppCustomBar(title: 'Settings'),

        // ── Scrollable content ─────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // ── Profile Header – minimalist redesign ──────────────
                  // ── Profile / Upgrade Section ─────────────────────────────
                  Builder(
                    builder: (context) {
                      // Mock Pro state for demonstration
                      const bool isPro = true;

                      if (isPro) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: isDark ? Border.all(color: AppColors.darkCardBorder) : Border.all(color: Colors.grey.shade200),
                            boxShadow: isDark ? null : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Shortly Pro',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.textPrimary : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Active',
                                          style: TextStyle(
                                            color: AppColors.accent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.verified_user_rounded,
                                    color: AppColors.accent.withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  // Clean Avatar with accent border
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.accent.withValues(alpha: 0.15),
                                        width: 2.5,
                                      ),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'S',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Shortly User',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.textPrimary : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Enjoying ad-free experience',
                                          style: TextStyle(
                                            color: isDark ? AppColors.textSecondary : Colors.grey.shade600,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }

                      // ── Upgrade Card (Non-Pro UI) based on attachment ────
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: isDark ? Border.all(color: AppColors.darkCardBorder) : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Shortly Pro',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.textPrimary : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF007A87).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Free',
                                        style: TextStyle(
                                          color: Color(0xFF007A87),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$4.99 /mo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textSecondary : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: isDark ? AppColors.accent : Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Upgrade pro to remove ads, enjoy seamless experience.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppColors.textSecondary : Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: isDark ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Upgrade Now',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.chevron_right_rounded, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Appearance section ─────────────────────────────
                  _SectionHeader(label: 'Appearance', isDark: isDark),
                  const SizedBox(height: 10),

                  _SettingsCard(
                    isDark: isDark,
                    children: [
                      _ThemeTile(
                        icon: Icons.brightness_auto_rounded,
                        label: AppLocalizations.of(context)!.system,
                        value: ThemeMode.system,
                        groupValue: themeMode,
                        ref: ref,
                        isDark: isDark,
                      ),
                      _Divider(isDark: isDark),
                      _ThemeTile(
                        icon: Icons.light_mode_rounded,
                        label: AppLocalizations.of(context)!.light,
                        value: ThemeMode.light,
                        groupValue: themeMode,
                        ref: ref,
                        isDark: isDark,
                      ),
                      _Divider(isDark: isDark),
                      _ThemeTile(
                        icon: Icons.dark_mode_rounded,
                        label: AppLocalizations.of(context)!.dark,
                        value: ThemeMode.dark,
                        groupValue: themeMode,
                        ref: ref,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Options section ────────────────────────────────
                  _SectionHeader(label: 'Options', isDark: isDark),
                  const SizedBox(height: 10),

                  _SettingsCard(
                    isDark: isDark,
                    children: [
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        trailing: Text(
                          Localizations.localeOf(context).languageCode == 'en'
                              ? 'English'
                              : 'Español',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                        isDark: isDark,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Text('Select Language'),
                              children: [
                                SimpleDialogOption(
                                  onPressed: () {
                                    ref
                                        .read(localeProvider.notifier)
                                        .setLocale(const Locale('en'));
                                    Navigator.pop(context);
                                  },
                                  child: const Text('English'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    ref
                                        .read(localeProvider.notifier)
                                        .setLocale(const Locale('es'));
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Español'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      _Divider(isDark: isDark),
                      _SettingsTile(
                        icon: Icons.feedback_outlined,
                        label: 'Feedback',
                        isDark: isDark,
                        onTap: () async {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'feedback@shortly.app',
                            query: 'subject=Shortly App Feedback',
                          );
                          if (await canLaunchUrl(emailLaunchUri)) {
                            launchUrl(emailLaunchUri);
                          }
                        },
                      ),
                      _Divider(isDark: isDark),
                      _SettingsTile(
                        icon: Icons.share_rounded,
                        label: AppLocalizations.of(context)!.share,
                        isDark: isDark,
                        onTap: () {
                          SharePlus.instance.share(
                            ShareParams(text: 'Check out Shortly, the best URL shortener app!'),
                          );
                        },
                      ),
                      _Divider(isDark: isDark),
                      _SettingsTile(
                        icon: Icons.star_rate_rounded,
                        label: 'Rate App',
                        isDark: isDark,
                        onTap: () async {
                          final Uri url = Uri.parse(
                              'market://details?id=com.example.shortly');
                          if (!await launchUrl(url)) {
                            final webUrl = Uri.parse(
                              'https://play.google.com/store/apps/details?id=com.example.shortly',
                            );
                            if (await canLaunchUrl(webUrl)) {
                              launchUrl(webUrl,
                                  mode: LaunchMode.externalApplication);
                            }
                          }
                        },
                      ),
                      _Divider(isDark: isDark),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        isDark: isDark,
                        onTap: () async {
                          final Uri url =
                              Uri.parse('https://example.com/privacy');
                          if (await canLaunchUrl(url)) {
                            launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── About section ──────────────────────────────────
                  _SectionHeader(label: 'About', isDark: isDark),
                  const SizedBox(height: 10),

                  _SettingsCard(
                    isDark: isDark,
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'Version',
                        isDark: isDark,
                        trailing: const Text(
                          '1.0.0',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                      ),
                      _Divider(isDark: isDark),
                      _SettingsTile(
                        icon: Icons.apps_rounded,
                        label: 'Other Apps',
                        isDark: isDark,
                        onTap: () async {
                          final Uri url = Uri.parse(
                            'https://play.google.com/store/apps/developer?id=ExampleDeveloper',
                          );
                          if (await canLaunchUrl(url)) {
                            launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ],
                  ),

              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: isDark ? AppColors.textMuted : Colors.grey.shade500,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: AppColors.darkCardBorder)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.darkCardBorder : Colors.grey.shade100,
      indent: 58,
      endIndent: 0,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.isDark,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                ),
              ),
              trailing ??
                  (onTap != null
                      ? Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.textMuted
                              : Colors.grey.shade400,
                        )
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeMode value;
  final ThemeMode groupValue;
  final WidgetRef ref;
  final bool isDark;

  const _ThemeTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.ref,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(themeProvider.notifier).setTheme(value),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : AppColors.accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.accent
                      : (isDark ? AppColors.textMuted : Colors.grey.shade500),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.accent
                        : (isDark ? AppColors.textPrimary : Colors.black87),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.accent, size: 20)
              else
                Icon(
                  Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color:
                      isDark ? AppColors.textMuted : Colors.grey.shade300,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
