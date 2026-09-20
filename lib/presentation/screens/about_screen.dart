import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_shortener/l10n/app_localizations.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/iap_service.dart';
import '../widgets/remove_ads_sheet.dart';
import 'feedback_screen.dart';
import 'help_faq_screen.dart';

/// What the app is, what it does, and where to go next.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  /// Opens [url] externally, flagging the trip so the return doesn't land on an
  /// app-open ad.
  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      AdService().suppressNextAppOpenAd();
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.about,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
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
      body: ListView(
        // The window draws edge-to-edge, so the last row clears the gesture bar.
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _Hero(version: _version, buildNumber: _buildNumber, isDark: isDark),
          const SizedBox(height: 28),

          _SectionLabel(label: l10n.whatShortlyDoes, isDark: isDark),
          const SizedBox(height: 10),
          _Card(
            isDark: isDark,
            child: Column(
              children: [
                _Feature(
                  icon: Icons.link_rounded,
                  title: l10n.featureShortenTitle,
                  desc: l10n.featureShortenDesc,
                  isDark: isDark,
                ),
                _Divider(isDark: isDark),
                _Feature(
                  icon: Icons.verified_user_rounded,
                  title: l10n.featureExpandTitle,
                  desc: l10n.featureExpandDesc,
                  isDark: isDark,
                ),
                _Divider(isDark: isDark),
                _Feature(
                  icon: Icons.qr_code_rounded,
                  title: l10n.featureQrTitle,
                  desc: l10n.featureQrDesc,
                  isDark: isDark,
                ),
                _Divider(isDark: isDark),
                _Feature(
                  icon: Icons.lock_outline_rounded,
                  title: l10n.featurePrivacyTitle,
                  desc: l10n.featurePrivacyDesc,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Only worth the space while there is still something to buy.
          ListenableBuilder(
            listenable: IapService(),
            builder: (context, _) {
              if (IapService().isPremium) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _ProBanner(
                  isDark: isDark,
                  onTap: () => showRemoveAdsSheet(context),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          _SectionLabel(label: l10n.support, isDark: isDark),
          const SizedBox(height: 10),
          _Card(
            isDark: isDark,
            child: Column(
              children: [
                _LinkTile(
                  icon: Icons.help_outline_rounded,
                  label: l10n.helpAndFaq,
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpFaqScreen()),
                  ),
                ),
                _Divider(isDark: isDark),
                _LinkTile(
                  icon: Icons.feedback_outlined,
                  label: l10n.feedback,
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                  ),
                ),
                _Divider(isDark: isDark),
                _LinkTile(
                  icon: Icons.mail_outline_rounded,
                  label: l10n.contactDeveloper,
                  isDark: isDark,
                  onTap: () => _open(
                    'mailto:${AppConstants.developerEmail}'
                    '?subject=${Uri.encodeComponent('${AppConstants.appName} $_version')}',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _SectionLabel(label: l10n.more, isDark: isDark),
          const SizedBox(height: 10),
          _Card(
            isDark: isDark,
            child: Column(
              children: [
                _LinkTile(
                  icon: Icons.star_outline_rounded,
                  label: l10n.rateApp,
                  isDark: isDark,
                  onTap: () async {
                    final review = InAppReview.instance;
                    if (await review.isAvailable()) {
                      await review.requestReview();
                    } else {
                      await _open(AppConstants.appLink);
                    }
                  },
                ),
                _Divider(isDark: isDark),
                _LinkTile(
                  icon: Icons.share_outlined,
                  label: l10n.shareApp,
                  isDark: isDark,
                  onTap: () {
                    AdService().suppressNextAppOpenAd();
                    SharePlus.instance.share(
                      ShareParams(
                        text: '${l10n.shareAppMessage}\n${AppConstants.appLink}',
                      ),
                    );
                  },
                ),
                _Divider(isDark: isDark),
                _LinkTile(
                  icon: Icons.apps_rounded,
                  label: l10n.otherApps,
                  isDark: isDark,
                  onTap: () => _open(AppConstants.developerStoreLink),
                ),
                _Divider(isDark: isDark),
                _LinkTile(
                  icon: Icons.privacy_tip_outlined,
                  label: l10n.privacyPolicy,
                  isDark: isDark,
                  onTap: () => _open(AppConstants.privacyPolicyUrl),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Center(
            child: Text(
              l10n.madeWithCare,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              '© 2026 Shortly',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero ─────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final String version;
  final String buildNumber;
  final bool isDark;

  const _Hero({
    required this.version,
    required this.buildNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: isDark ? 0.22 : 0.1),
            AppColors.accentLight.withValues(alpha: isDark ? 0.08 : 0.03),
          ],
        ),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, size: 44, color: Colors.white),
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Short',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const TextSpan(
                  text: 'ly',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.aboutTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.textSecondary : Colors.black54,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              version.isEmpty
                  ? '${l10n.version} …'
                  : '${l10n.version} $version ($buildNumber)',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSecondary : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pro banner ───────────────────────────────────────────────────────────────

class _ProBanner extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _ProBanner({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF5A623).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: kProGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.shortlyPro,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.upgradeProDesc,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: isDark
                            ? AppColors.textSecondary
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Building blocks ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _Card({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
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
      indent: 60,
      color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200,
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool isDark;

  const _Feature({
    required this.icon,
    required this.title,
    required this.desc,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.accent),
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
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: isDark
                        ? AppColors.textSecondary
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
