import 'package:flutter/material.dart';
import 'package:url_shortener/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../widgets/app_custom_bar.dart';
import '../providers/shortener_provider.dart';
import '../providers/history_provider.dart';
import '../providers/provider_keys_provider.dart';
import 'result_screen.dart';
import 'provider_config_screen.dart';
import 'package:intl/intl.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/ad_service.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';

class ShortenerView extends ConsumerStatefulWidget {
  const ShortenerView({super.key});

  @override
  ConsumerState<ShortenerView> createState() => _ShortenerViewState();
}

class _ShortenerViewState extends ConsumerState<ShortenerView>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _urlController = TextEditingController();
  String _selectedProvider = AppConstants.daGd;
  bool _isFocused = false;
  StreamSubscription? _intentDataStreamSubscription;

  final List<String> _providers = [
    AppConstants.daGd,
    AppConstants.tinyUrl,
    AppConstants.cuttLy,
    AppConstants.bitLy,
    AppConstants.cleanUri,
    AppConstants.clckRu,
    AppConstants.isGd,
    AppConstants.osdb,
  ];

  @override
  void initState() {
    super.initState();
    _selectedProvider = ref.read(providerKeysProvider).defaultProvider;
    // Listen for shared text while app is in memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty && value.first.path.isNotEmpty) {
        setState(() {
          _urlController.text = value.first.path;
        });
      }
    });

    // Listen for shared text when app is started from closed state
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty && value.first.path.isNotEmpty) {
        setState(() {
          _urlController.text = value.first.path;
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  void _handleShorten() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterUrl)),
      );
      return;
    }

    final keys = ref.read(providerKeysProvider);

    if (_selectedProvider == AppConstants.tinyUrl && keys.tinyUrlToken.isEmpty) {
      _showTinyUrlWarningDialog(url);
      return;
    }

    if (_selectedProvider == AppConstants.bitLy && keys.bitLyToken.isEmpty) {
      _showBitlyWarningDialog(url);
      return;
    }

    ref.read(shortenerProvider.notifier).shorten(_selectedProvider, url);
  }

  // ── Provider picker (redesigned selection menu) ──────────────────────────
  void _showProviderPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grabber
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Choose provider',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textPrimary
                                : Colors.black87,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProviderConfigScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.tune_rounded,
                            size: 16, color: AppColors.accent),
                        label: const Text(
                          'Configure',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 8),
                    children: _providers
                        .map((p) => _buildProviderOption(p, isDark))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProviderOption(String p, bool isDark) {
    final isSelected = p == _selectedProvider;
    final color = _providerColor(p);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _selectedProvider = p);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.06)
              : Colors.transparent,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Center(
                  child: Text(
                    p[0].toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  p,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.accent
                        : (isDark ? AppColors.textPrimary : Colors.black87),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _providerColor(String name) {
    switch (name) {
      case AppConstants.tinyUrl:
        return const Color(0xFF1E88E5);
      case AppConstants.cuttLy:
        return const Color(0xFF007A87);
      case AppConstants.bitLy:
        return const Color(0xFFEE6123);
      case AppConstants.isGd:
        return const Color(0xFF43A047);
      case AppConstants.cleanUri:
        return const Color(0xFF8E24AA);
      case AppConstants.clckRu:
        return const Color(0xFFE53935);
      case AppConstants.daGd:
        return const Color(0xFF00ACC1);
      case AppConstants.osdb:
        return const Color(0xFF5E35B1);
      default:
        return AppColors.accent;
    }
  }

  void _showTinyUrlWarningDialog(String url) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TinyURL Preview Warning',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Shortening with TinyURL without an API token creates links that redirect through a deprecated preview countdown page.\n\nTo bypass this, we recommend either switching to Is.gd (which has seamless direct redirects) or adding a free API Token in settings.',
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(shortenerProvider.notifier).shorten(_selectedProvider, url);
              },
              child: const Text('Proceed Anyway', style: TextStyle(color: AppColors.textMuted)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProviderConfigScreen()),
                    );
                  },
                  child: const Text('Configure', style: TextStyle(color: AppColors.accent)),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedProvider = AppConstants.isGd;
                    });
                    ref.read(shortenerProvider.notifier).shorten(AppConstants.isGd, url);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Use Is.gd', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showBitlyWarningDialog(String url) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bitly Token Required',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Bit.ly requires a valid Access Token to shorten links. Please add your token in settings or switch to a free unauthenticated provider like Is.gd.',
            style: TextStyle(
              color: isDark ? AppColors.textSecondary : Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProviderConfigScreen()),
                );
              },
              child: const Text('Configure', style: TextStyle(color: AppColors.accent)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedProvider = AppConstants.isGd;
                });
                ref.read(shortenerProvider.notifier).shorten(AppConstants.isGd, url);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Use Is.gd', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(shortenerProvider, (previous, next) {
      if (next.result != null && next.error == null && !next.isLoading &&
          next.result!.provider != null) {
        // Capture result and immediately clear state to prevent re-firing on rebuilds
        final result = next.result!;
        ref.read(shortenerProvider.notifier).clearResult();

        AdService().showInterstitialAd();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
        ).then((_) {
          // Refresh history when returning from ResultScreen
          if (mounted) {
            ref.read(historyProvider.notifier).refresh();
          }
        });

        // Also refresh immediately so the "Recent Links" list below updates now
        ref.read(historyProvider.notifier).refresh();

        Future.delayed(const Duration(milliseconds: 500), () async {
          final count = ref.read(historyProvider).value?.length ?? 0;
          if (count >= 3) {
            final prefs = await SharedPreferences.getInstance();
            final prompted = prefs.getBool('review_prompted') ?? false;
            if (!prompted) {
              await prefs.setBool('review_prompted', true);
              final inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
              }
            }
          }
        });
      }
    });

    ref.listen(providerKeysProvider.select((s) => s.defaultProvider), (previous, next) {
      if (previous != next) {
        setState(() {
          _selectedProvider = next;
        });
      }
    });

    final state = ref.watch(shortenerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(historyProvider);
    final history = historyAsync.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header (fixed, non-scrollable) ────────────────────────────────
        const AppCustomBar(title: 'Short', accentTitle: 'ly'),

        // ── Scrollable Content ───────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    // Section label
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.pasteLongUrl,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondary
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── URL input card ──────────────────────────────────────────
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: _isFocused
                            ? Border.all(color: AppColors.accent, width: 2)
                            : isDark
                            ? Border.all(color: AppColors.darkCardBorder)
                            : Border.all(color: Colors.grey.shade200),
                        boxShadow: _isFocused
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _isFocused
                                        ? AppColors.accent.withValues(alpha: 0.12)
                                        : (isDark
                                              ? AppColors.darkBg.withValues(
                                                  alpha: 0.5,
                                                )
                                              : Colors.grey.shade100),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.link_rounded,
                                    size: 18,
                                    color: _isFocused
                                        ? AppColors.accent
                                        : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Focus(
                                    onFocusChange: (focused) =>
                                        setState(() => _isFocused = focused),
                                    child: TextField(
                                      controller: _urlController,
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.textPrimary
                                            : Colors.black87,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText:
                                            'https://example.com/very-long-url...',
                                        hintStyle: TextStyle(
                                          color: isDark
                                              ? AppColors.textMuted
                                              : Colors.grey.shade400,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      keyboardType: TextInputType.url,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _handleShorten(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.content_paste_rounded,
                                    size: 18,
                                    color: _isFocused
                                        ? AppColors.accent
                                        : AppColors.textMuted,
                                  ),
                                  splashRadius: 20,
                                  tooltip: AppLocalizations.of(context)!.paste,
                                  onPressed: () async {
                                    final data = await Clipboard.getData(
                                      'text/plain',
                                    );
                                    if (data?.text != null) {
                                      _urlController.text = data!.text!;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: isDark
                                  ? AppColors.darkCardBorder
                                  : Colors.grey.shade100,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.hub_outlined,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'via',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Provider selector — opens the redesigned picker
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _showProviderPicker,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.accent
                                              .withValues(alpha: 0.18),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _providerColor(
                                                  _selectedProvider),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _selectedProvider,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.accent,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.unfold_more_rounded,
                                            size: 16,
                                            color: AppColors.accent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Quick access to provider / API-key configuration
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ProviderConfigScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.tune_rounded,
                                      size: 16,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Shorten Now button
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, AppColors.accentLight],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: state.isLoading ? null : _handleShorten,
                            child: Center(
                              child: state.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.bolt_rounded, size: 18, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(context)!.shortenNow,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Error message
                    if (state.error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Recent Links header
                    Text(
                      AppLocalizations.of(context)!.recentLinks,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Recent Links List
              if (history.isEmpty)
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.link_off_rounded,
                        size: 48,
                        color: isDark
                            ? AppColors.textMuted
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.noLinksShortened,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textMuted
                              : Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length > 5 ? 5 : history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final card = _LinkCard(item: item, isDark: isDark);
                    
                    // Show first ad after 2 items, then every 4 items
                    if (index >= 1 && (index - 1) % 4 == 0) {
                      return Column(
                        children: [
                          card,
                          AdService().getNativeAdWidget(
                            key: ValueKey('recent_native_$index'),
                            isListCard: true,
                          ),
                        ],
                      );
                    }
                    return card;
                  },
                ),
            ],
          ),
        ),
      
      ],
    );
  }
}

/// Redesigned Card widget for recent link entries
class _LinkCard extends ConsumerWidget {
  final dynamic item;
  final bool isDark;

  const _LinkCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortUrl = item.shortenedUrl ?? item.expandedUrl ?? 'Unknown';
    final originalUrl = item.originalUrl ?? item.shortenedUrl ?? '';
    final date = DateFormat(
      'dd MMM yyyy',
    ).format(DateTime.fromMillisecondsSinceEpoch(item.timestamp));

    String faviconLetter = '?';
    Color faviconBg = AppColors.textMuted;
    String? faviconUrl;
    try {
      final uri = Uri.parse(originalUrl);
      final host = uri.host;
      if (host.isNotEmpty) {
        faviconLetter = host.replaceAll('www.', '')[0].toUpperCase();
        faviconBg = _colorFromHost(host);
        faviconUrl =
            'https://www.google.com/s2/favicons?sz=64&domain=${uri.scheme}://$host';
      }
    } catch (_) {}

    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red, size: 24),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Delete Link',
                style: TextStyle(color: isDark ? AppColors.textPrimary : Colors.black87),
              ),
              content: Text(
                'Are you sure you want to delete this link?',
                style: TextStyle(color: isDark ? AppColors.textSecondary : Colors.grey.shade700),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (_) {
        ref.read(historyProvider.notifier).deleteUrl(item.id!);
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: AppColors.darkCardBorder, width: 1.5)
            : Border.all(color: Colors.grey.shade200, width: 1.5),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ResultScreen(result: item)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Favicon with image + letter fallback
                _FaviconWidget(
                  faviconUrl: faviconUrl,
                  faviconLetter: faviconLetter,
                  faviconBg: faviconBg,
                ),
                const SizedBox(width: 16),

                // Link info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shortUrl,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimary
                              : Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        originalUrl,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondary
                              : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions: copy
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: shortUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.copiedToClipboard)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Color _colorFromHost(String host) {
    final colors = [
      const Color(0xFF3B5998),
      const Color(0xFF1DA1F2),
      const Color(0xFF25D366),
      const Color(0xFFE1306C),
      const Color(0xFFFF0000),
      const Color(0xFF0077B5),
      const Color(0xFFFF6600),
      const Color(0xFF7B2FBE),
      const Color(0xFF00897B),
    ];
    return colors[host.hashCode.abs() % colors.length];
  }
}

/// Smart favicon widget: tries to load image favicon, falls back to letter icon
class _FaviconWidget extends StatelessWidget {
  final String? faviconUrl;
  final String faviconLetter;
  final Color faviconBg;

  const _FaviconWidget({
    required this.faviconUrl,
    required this.faviconLetter,
    required this.faviconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: faviconBg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: faviconBg.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: faviconUrl != null
          ? Image.network(
              faviconUrl!,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              // Add padding so favicon sits nicely inside the container
              frameBuilder: (ctx, child, frame, wasSynchronouslyLoaded) {
                if (frame == null) return _letterFallback();
                return Padding(padding: const EdgeInsets.all(10), child: child);
              },
              errorBuilder: (ctx, err, stack) => _letterFallback(),
            )
          : _letterFallback(),
    );
  }

  Widget _letterFallback() {
    return Center(
      child: Text(
        faviconLetter,
        style: TextStyle(
          color: faviconBg,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
