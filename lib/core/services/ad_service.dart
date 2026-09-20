import 'dart:math';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'iap_service.dart';
import '../constants.dart';
import '../theme.dart';

class AdService extends ChangeNotifier with WidgetsBindingObserver {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final IapService _iapService = IapService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _initStarted = false; // guard against double-init

  static const String _lastAppOpenAdKey = 'last_app_open_ad_time';
  static const int _appOpenAdCooldownMinutes = 30;
  static const int _interstitialCooldownSeconds = 150;
  // Show on every 2nd shorten/expand, subject to the cooldown below.
  static const int _interstitialFrequency = 2;

  // Skip the very first `resumed` after launch so an app-open ad never
  // slams over the cold start.
  bool _isFirstLaunch = true;
  // True while any full-screen ad (interstitial or app-open) is on screen, so
  // a second one can never stack on top of it.
  bool _isShowingFullScreenAd = false;
  // Set when the user intentionally leaves the app (tapped a link/share, or
  // clicked an ad). Consumed by the next resume so the return isn't ambushed
  // by an app-open ad.
  bool _suppressNextAppOpen = false;

  int _interstitialRetryAttempt = 0;
  int _appOpenRetryAttempt = 0;
  int _interstitialCounter = 0;
  DateTime? _lastInterstitialShown;

  /// Suppress the next app-open ad that would otherwise fire when the app
  /// resumes. Call right before an intentional external navigation
  /// (`launchUrl`, share sheet) or when another ad is clicked.
  void suppressNextAppOpenAd() => _suppressNextAppOpen = true;

  Future<void> init() async {
    if (_initStarted) return;
    _initStarted = true;

    if (_iapService.isPremium) {
      debugPrint('AdService: Premium user — skipping ad init.');
      return;
    }

    try {
      await AppLovinMAX.initialize(AppConstants.appLovinSdkKey);
      _isInitialized = true;
      WidgetsBinding.instance.addObserver(this);
      _attachAdListeners();
      loadInterstitial();
      loadAppOpenAd();
      notifyListeners();
      debugPrint('AdService: AppLovin MAX initialized successfully.');
    } catch (e) {
      debugPrint('AdService: AppLovin init failed: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        // Don't show an app-open ad over the cold start.
        if (_isFirstLaunch) {
          _isFirstLaunch = false;
          break;
        }
        await _showAdIfReady();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        break;
    }
  }

  void _attachAdListeners() {
    // ── Interstitial ─────────────────────────────────────────────────────
    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (ad) {
          _interstitialRetryAttempt = 0;
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          _interstitialRetryAttempt++;
          final delay = pow(2, min(6, _interstitialRetryAttempt)).toInt();
          Future.delayed(Duration(seconds: delay), loadInterstitial);
        },
        onAdDisplayedCallback: (ad) => _isShowingFullScreenAd = true,
        onAdDisplayFailedCallback: (ad, error) {
          _isShowingFullScreenAd = false;
          loadInterstitial();
        },
        // Tapping the interstitial opens external content; don't show an
        // app-open ad on the return.
        onAdClickedCallback: (ad) => _suppressNextAppOpen = true,
        onAdHiddenCallback: (ad) {
          _isShowingFullScreenAd = false;
          loadInterstitial();
        },
      ),
    );

    // ── App Open Ad ───────────────────────────────────────────────────────
    AppLovinMAX.setAppOpenAdListener(
      AppOpenAdListener(
        onAdLoadedCallback: (ad) {
          _appOpenRetryAttempt = 0;
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          _appOpenRetryAttempt++;
          final delay = pow(2, min(6, _appOpenRetryAttempt)).toInt();
          Future.delayed(Duration(seconds: delay), loadAppOpenAd);
        },
        onAdDisplayedCallback: (ad) => _isShowingFullScreenAd = true,
        onAdDisplayFailedCallback: (ad, error) {
          _isShowingFullScreenAd = false;
          loadAppOpenAd();
        },
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {
          _isShowingFullScreenAd = false;
          loadAppOpenAd();
        },
        onAdRevenuePaidCallback: (ad) {},
      ),
    );
  }

  // ── App Open Ad ──────────────────────────────────────────────────────────
  void loadAppOpenAd() {
    if (_iapService.isPremium) return;
    AppLovinMAX.loadAppOpenAd(AppConstants.adUnitIdAppOpen);
  }

  Future<void> _showAdIfReady() async {
    if (!_isInitialized || _iapService.isPremium) return;

    // Never stack over a full-screen ad that's already showing.
    if (_isShowingFullScreenAd) return;

    // Returning from an intentional external action (link/share/ad click) —
    // consume the flag and skip this resume.
    if (_suppressNextAppOpen) {
      _suppressNextAppOpen = false;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? lastTimeString = prefs.getString(_lastAppOpenAdKey);
    final now = DateTime.now();

    if (lastTimeString != null) {
      final lastTime = DateTime.parse(lastTimeString);
      if (now.difference(lastTime).inMinutes < _appOpenAdCooldownMinutes) {
        return;
      }
    }

    bool isReady = (await AppLovinMAX.isAppOpenAdReady(AppConstants.adUnitIdAppOpen)) ?? false;
    if (isReady) {
      AppLovinMAX.showAppOpenAd(AppConstants.adUnitIdAppOpen);
      await prefs.setString(_lastAppOpenAdKey, now.toIso8601String());
    } else {
      AppLovinMAX.loadAppOpenAd(AppConstants.adUnitIdAppOpen);
    }
  }

  // ── Interstitial Ad ──────────────────────────────────────────────────────
  void loadInterstitial() {
    if (_iapService.isPremium) return;
    AppLovinMAX.loadInterstitial(AppConstants.adUnitIdInterstitial);
  }

  /// Call on a natural break (a completed shorten/expand). The counter is only
  /// cleared when an ad actually displays — a slot lost to the cooldown or to
  /// an unfilled ad carries over to the next action instead of being burned.
  Future<void> showInterstitialAd() async {
    if (_iapService.isPremium) return;

    _interstitialCounter++;
    if (_interstitialCounter < _interstitialFrequency) return;

    final now = DateTime.now();
    if (_lastInterstitialShown != null &&
        now.difference(_lastInterstitialShown!).inSeconds <
            _interstitialCooldownSeconds) {
      return;
    }

    final isReady =
        (await AppLovinMAX.isInterstitialReady(
          AppConstants.adUnitIdInterstitial,
        )) ??
        false;
    if (isReady) {
      AppLovinMAX.showInterstitial(AppConstants.adUnitIdInterstitial);
      _lastInterstitialShown = DateTime.now();
      _interstitialCounter = 0;
    } else {
      loadInterstitial();
    }
  }


  // ── Native Ad Widget ─────────────────────────────────────────────────────

  /// A native ad sized and styled for [style].
  ///
  /// Returns an empty box for premium users, and keeps listening afterwards so
  /// a purchase made while a list is on screen clears the slot immediately.
  Widget getNativeAdWidget({
    Key? key,
    NativeAdStyle style = NativeAdStyle.card,
  }) {
    return ListenableBuilder(
      key: key,
      listenable: _iapService,
      builder: (context, child) {
        if (_iapService.isPremium) return const SizedBox.shrink();
        return child!;
      },
      child: _NativeAdWidget(
        adUnitId: AppConstants.adUnitIdNative,
        style: style,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Native Ad Placement
// ─────────────────────────────────────────────────────────────────────────────

/// Where native ads are allowed to sit inside a scrolling list.
///
/// Centralised so every list follows the same rules rather than each one
/// carrying its own index arithmetic.
abstract class NativeAdPlacement {
  /// Index of the earliest item an ad may follow. Three real rows always come
  /// first, so a list never opens on an ad and the user reaches their own
  /// content before anything sponsored.
  static const int defaultFirstSlot = 2;

  /// Rows between consecutive ads.
  static const int defaultInterval = 6;

  /// Ads per list. A cap keeps a long history from turning into a stack of ads.
  static const int defaultMaxAds = 5;

  /// Whether an ad belongs directly after the item at [index].
  ///
  /// An ad is only placed where a real row follows it, so it always reads as
  /// in-feed content rather than a footer stuck on the end of the list.
  static bool showsAfter(
    int index,
    int itemCount, {
    int firstSlot = defaultFirstSlot,
    int interval = defaultInterval,
    int maxAds = defaultMaxAds,
  }) {
    if (index < firstSlot) return false;
    if (index >= itemCount - 1) return false;

    final offset = index - firstSlot;
    if (offset % interval != 0) return false;

    return offset ~/ interval < maxAds;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Native Ad Widget
// ─────────────────────────────────────────────────────────────────────────────

/// How a native ad presents itself.
enum NativeAdStyle {
  /// Row that mirrors a link card — icon, title, body, meta line, trailing
  /// action. Drops into a list of links without breaking its rhythm.
  listTile,

  /// Full card with a media view. For the standalone slot at the end of a
  /// screen, where there is room for one and native demand pays for the media.
  card,
}

/// Fixed slot heights.
///
/// MaxNativeAdView registers each asset view's rect with the native side while
/// handling the load event, and the native side then draws the icon and media
/// at those coordinates. The rects are therefore only correct if the layout is
/// pixel-identical before and after the ad's text arrives.
///
/// That is why the slot pins its height AND why every text asset view below is
/// wrapped in a fixed-height box: a title or body view measures zero while
/// empty, so an intrinsic layout silently shifts everything below it once the
/// SDK fills the text in — leaving the media drawn over the header, outside the
/// card, with its own Flutter box left empty.
// 112 rather than the link cards' ~99: the extra 13pt is headroom so the
// content still fits at the maximum text scale below.
const double _kNativeAdListHeight = 112;
const double _kNativeAdCardHeight = 330;

/// Ads render at a fixed text scale. Every asset view below sits in a
/// fixed-height box (see the note on the slot heights), so letting the system
/// font size grow them would reintroduce exactly the layout shift those boxes
/// exist to prevent.
const double _kNativeAdMaxTextScale = 1.0;

// Fixed boxes for the text asset views. Sized for the font sizes used below at
// scale 1.0, with a little slack.
const double _kTitleHeight = 21;
const double _kBodyLineHeight = 18;
const double _kBodyTwoLineHeight = 36;
const double _kMetaHeight = 18;

class _NativeAdWidget extends StatefulWidget {
  final String adUnitId;
  final NativeAdStyle style;

  const _NativeAdWidget({required this.adUnitId, required this.style});

  @override
  State<_NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<_NativeAdWidget>
    with AutomaticKeepAliveClientMixin {
  bool _isAdLoaded = false;
  bool _didAdFail = false;
  final MaxNativeAdViewController _controller = MaxNativeAdViewController();

  // Keep the loaded ad alive when scrolled off-screen / parent rebuilds so it
  // doesn't reload and flicker.
  @override
  bool get wantKeepAlive => true;

  bool get _isListTile => widget.style == NativeAdStyle.listTile;

  @override
  void initState() {
    super.initState();
    _controller.loadAd();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final height = _isListTile ? _kNativeAdListHeight : _kNativeAdCardHeight;

    // The slot holds its full height (and builds its content) while the ad is
    // in flight — see the note on the height constants. It collapses only once
    // a load has actually failed, so an unfilled slot leaves no gap.
    return Container(
      margin: _didAdFail ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      height: _didAdFail ? 1 : height,
      decoration: _isAdLoaded
          ? _slotDecoration(isDark)
          : const BoxDecoration(color: Colors.transparent),
      clipBehavior: Clip.hardEdge,
      child: MaxNativeAdView(
        adUnitId: widget.adUnitId,
        controller: _controller,
        listener: NativeAdListener(
          onAdLoadedCallback: (ad) {
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
                _didAdFail = false;
              });
            }
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            if (mounted) {
              setState(() {
                _isAdLoaded = false;
                _didAdFail = true;
              });
            }
          },
          // Clicking the native ad opens external content; don't show an
          // app-open ad on the return.
          onAdClickedCallback: (ad) => AdService().suppressNextAppOpenAd(),
          onAdRevenuePaidCallback: (ad) {},
        ),
        // Always built, so the asset views exist when the SDK registers them.
        // Opacity doesn't affect layout, so fading in keeps those rects valid.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: _kNativeAdMaxTextScale,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: _isAdLoaded ? 1 : 0,
            child: _isListTile
                ? _buildListTile(isDark)
                : _buildCard(isDark),
          ),
        ),
      ),
    );
  }

  /// Chrome copied from the link cards: same radius, border weight and shadow,
  /// so an ad sits in a list without looking bolted on.
  BoxDecoration _slotDecoration(bool isDark) {
    return BoxDecoration(
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
    );
  }

  // ── List tile layout ──────────────────────────────────────────────────────

  /// Mirrors `_LinkCard` / `_HistoryLinkCard`: 50pt leading icon, title, a
  /// second line of detail, a muted meta row, and a trailing accent action.
  Widget _buildListTile(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Stands in for the link cards' favicon tile.
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.25),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: const MaxNativeAdIconView(width: 50, height: 50),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Same weight and size as a link card's short URL.
                SizedBox(
                  height: _kTitleHeight,
                  child: MaxNativeAdTitleView(
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                // Same treatment as the original URL line beneath it.
                SizedBox(
                  height: _kBodyLineHeight,
                  child: MaxNativeAdBodyView(
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondary
                          : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                // Takes the place of the timestamp row.
                SizedBox(
                  height: _kMetaHeight,
                  child: Row(
                    children: [
                      const _SponsoredChip(),
                      const SizedBox(width: 6),
                      Flexible(
                        child: MaxNativeAdAdvertiserView(
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const MaxNativeAdOptionsView(width: 14, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sits where the copy button sits on a link card, widened just enough
          // for the network's call-to-action text.
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: SizedBox(
              width: 76,
              height: 38,
              child: _CallToAction(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card layout ───────────────────────────────────────────────────────────

  /// The header row repeats the list tile's anatomy, then gives the media view
  /// the remaining height — roughly 1.8:1, the shape native demand bids most on.
  Widget _buildCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.25),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: const MaxNativeAdIconView(width: 44, height: 44),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: _kTitleHeight,
                      child: MaxNativeAdTitleView(
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
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: _kMetaHeight,
                      child: Row(
                        children: [
                          Flexible(
                            child: MaxNativeAdAdvertiserView(
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const MaxNativeAdOptionsView(width: 14, height: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const _SponsoredChip(),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.hardEdge,
              child: const MaxNativeAdMediaView(),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: _kBodyTwoLineHeight,
            child: MaxNativeAdBodyView(
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : Colors.grey.shade600,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),

          const SizedBox(
            height: 44,
            width: double.infinity,
            child: _CallToAction(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// The disclosure label. Deliberately readable rather than hidden — an ad that
/// borrows the link cards' styling has to say what it is.
class _SponsoredChip extends StatelessWidget {
  const _SponsoredChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: const Text(
        'Ad',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
          height: 1.2,
        ),
      ),
    );
  }
}

/// Shared styling for the network's call-to-action button.
class _CallToAction extends StatelessWidget {
  final double fontSize;

  const _CallToAction({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return MaxNativeAdCallToActionView(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.accent),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 8),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: WidgetStateProperty.all(0),
      ),
    );
  }
}
