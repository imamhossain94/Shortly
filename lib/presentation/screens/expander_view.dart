import 'package:flutter/material.dart';
import 'package:url_shortener/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../widgets/app_custom_bar.dart';
import '../providers/shortener_provider.dart';
import '../providers/history_provider.dart';
import 'result_screen.dart';

class ExpanderView extends ConsumerStatefulWidget {
  const ExpanderView({super.key});

  @override
  ConsumerState<ExpanderView> createState() => _ExpanderViewState();
}

class _ExpanderViewState extends ConsumerState<ExpanderView>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _urlController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _handleExpand() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterUrl)),
      );
      return;
    }
    ref.read(shortenerProvider.notifier).expand(url);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(shortenerProvider, (previous, next) {
      if (next.result != null && next.error == null && !next.isLoading) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(result: next.result!),
          ),
        );
        ref.read(historyProvider.notifier).refresh();
      }
    });

    final state = ref.watch(shortenerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header (fixed, non-scrollable) ────────────────────────────────
        const AppCustomBar(
          title: 'Verify',
          accentTitle: ' Link',
        ),

        // ── Scrollable content ─────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info section – minimalist redesign
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: AppColors.accent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expand Shortened Link',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.textPrimary : Colors.black87,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Safely reveal the full destination behind any shortened link.',
                                style: TextStyle(
                                  color: isDark ? AppColors.textSecondary : Colors.grey.shade600,
                                  fontSize: 12.5,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Shortened URL',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.textSecondary
                              : Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 10),

                  // Input card
                  Container(
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
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: TextField(
                      controller: _urlController,
                      style: TextStyle(
                        color:
                            isDark ? AppColors.textPrimary : Colors.black87,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'https://bit.ly/example',
                        hintStyle: const TextStyle(
                            color: AppColors.textMuted, fontSize: 14),
                        prefixIcon: const Icon(
                          Icons.shield_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.content_paste_rounded,
                              size: 18),
                          color: AppColors.textMuted,
                          onPressed: () async {
                            final data =
                                await Clipboard.getData('text/plain');
                            if (data?.text != null) {
                              _urlController.text = data!.text!;
                            }
                          },
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleExpand(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Expand button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _handleExpand,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.accent.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Expand & Verify',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),

                  // Error
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // How it works section
                  Text(
                    'How it works',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _HowItWorksStep(
                    step: '01',
                    title: 'Paste your short URL',
                    desc: 'Copy any bit.ly, tinyurl, or other shortened link.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _HowItWorksStep(
                    step: '02',
                    title: 'Tap Expand & Verify',
                    desc: 'We follow the redirect chain to find the destination.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _HowItWorksStep(
                    step: '03',
                    title: 'See the full URL',
                    desc: 'The complete original URL is revealed instantly.',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final String step;
  final String title;
  final String desc;
  final bool isDark;

  const _HowItWorksStep({
    required this.step,
    required this.title,
    required this.desc,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondary
                        : Colors.grey.shade600,
                    fontSize: 12,
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
