import 'package:flutter/material.dart';
import 'package:url_shortener/l10n/app_localizations.dart';
import '../../core/theme.dart';
import '../../core/services/iap_service.dart';
import 'app_bar_action.dart';

/// Gold used for every "go Pro" affordance in the app — the drawer's PRO badge,
/// the crown action, the sheet's header.
const LinearGradient kProGradient = LinearGradient(
  colors: [Color(0xFFFFD700), Color(0xFFF5A623)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Crown app-bar action that opens the remove-ads sheet.
///
/// Renders nothing once the user is premium, so the bar doesn't advertise a
/// purchase they've already made. Rebuilds itself on [IapService] changes, so a
/// purchase completed elsewhere removes it without a screen rebuild.
class RemoveAdsAction extends StatelessWidget {
  const RemoveAdsAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: IapService(),
      builder: (context, _) {
        if (IapService().isPremium) return const SizedBox.shrink();
        return AppBarAction(
          icon: Icons.workspace_premium_rounded,
          tooltip: AppLocalizations.of(context)!.upgradeNow,
          gradient: kProGradient,
          onTap: () => showRemoveAdsSheet(context),
        );
      },
    );
  }
}

/// Bottom sheet that explains what Pro removes before charging for it.
///
/// Deliberately not a one-tap purchase off the crown icon: a mis-tap in the app
/// bar shouldn't open the Play billing dialog.
Future<void> showRemoveAdsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RemoveAdsSheet(),
  );
}

class _RemoveAdsSheet extends StatelessWidget {
  const _RemoveAdsSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: IapService(),
      builder: (context, _) {
        final iap = IapService();

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: kProGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 26,
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
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimary : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          iap.productPrice,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              const _Benefit(
                icon: Icons.block_rounded,
                title: 'No ads, anywhere',
                desc: 'Every banner, interstitial and sponsored card is gone.',
              ),
              const _Benefit(
                icon: Icons.bolt_rounded,
                title: 'Faster, cleaner flow',
                desc: 'Shorten and expand without a single interruption.',
              ),
              const _Benefit(
                icon: Icons.all_inclusive_rounded,
                title: 'One-time purchase',
                desc: 'Pay once and keep it — no subscription, no renewals.',
              ),

              if (iap.errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    iap.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentLight],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: iap.isLoading ? null : () => iap.buyRemoveAds(),
                      child: Center(
                        child: iap.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.upgradeNow,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => iap.restorePurchases(),
                  child: const Text(
                    'Restore purchase',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _Benefit({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
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
                    height: 1.35,
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
