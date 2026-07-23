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
  Widget getNativeAdWidget({Key? key, bool isListCard = false}) {
    if (_iapService.isPremium) return const SizedBox.shrink();
    return _NativeAdWidget(key: key, adUnitId: AppConstants.adUnitIdNative, isListCard: isListCard);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Native Ad Widget
// ─────────────────────────────────────────────────────────────────────────────

// Height of the native ad slot. Sized so the media view gets ~1.8:1, which is
// the shape native demand pays most for — a thumbnail-sized unit earns a
// fraction of the eCPM of one with real media.
const double _kNativeAdHeight = 330;

class _NativeAdWidget extends StatefulWidget {
  final String adUnitId;
  final bool isListCard;
  const _NativeAdWidget({super.key, required this.adUnitId, this.isListCard = false});

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
    
    // The slot keeps its full height (and builds its content) while the ad is
    // in flight: MaxNativeAdView registers each asset view's rect with the
    // native side as part of handling the load event, before our listener runs.
    // If the content isn't laid out at its final size by then, no asset views
    // are registered, the SDK logs "Failed to prepare native ad for
    // interaction", and the media view never appears. It collapses only once a
    // load has actually failed.
    return Container(
      margin: _didAdFail ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      height: _didAdFail ? 1 : _kNativeAdHeight,
      decoration: _isAdLoaded
          ? BoxDecoration(
              color: isDark
                  ? AppColors.darkCard
                  : (widget.isListCard ? Colors.white : Colors.grey.shade50),
              borderRadius: BorderRadius.circular(widget.isListCard ? 20 : 16),
              border: isDark
                  ? Border.all(color: AppColors.darkCardBorder, width: 1.5)
                  : Border.all(
                      color: Colors.grey.shade200,
                      width: widget.isListCard ? 1.5 : 1.0,
                    ),
              boxShadow: isDark || !widget.isListCard
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            )
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
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _isAdLoaded ? 1 : 0,
          child: _buildNativeAdContent(theme, isDark),
        ),
      ),
    );
  }

  Widget _buildNativeAdContent(ThemeData theme, bool isDark) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon, title/advertiser, "Ad" badge
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const MaxNativeAdIconView(width: 40, height: 40),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MaxNativeAdTitleView(
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    MaxNativeAdAdvertiserView(
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Ad',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Media takes whatever height is left — roughly 1.8:1, which is what
          // the native demand (Meta especially) bids highest on.
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: const Stack(
                fit: StackFit.expand,
                children: [
                  MaxNativeAdMediaView(),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: MaxNativeAdOptionsView(width: 16, height: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          MaxNativeAdBodyView(
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            width: double.infinity,
            child: MaxNativeAdCallToActionView(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppColors.accent),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16),
                ),
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                elevation: WidgetStateProperty.all(0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
