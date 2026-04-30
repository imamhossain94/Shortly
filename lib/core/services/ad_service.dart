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
  static const int _appOpenAdCooldownMinutes = 60; // Increased from 10
  static const int _interstitialCooldownSeconds = 300; // Increased from 60
  static const int _interstitialFrequency = 8; // Increased from 3

  bool _isFirstLaunch = true;
  int _interstitialRetryAttempt = 0;
  int _appOpenRetryAttempt = 0;
  int _interstitialCounter = 0;
  DateTime? _lastInterstitialShown;

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
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) => loadInterstitial(),
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) => loadInterstitial(),
      ),
    );

    // ── App Open Ad ───────────────────────────────────────────────────────
    AppLovinMAX.setAppOpenAdListener(
      AppOpenAdListener(
        onAdLoadedCallback: (ad) {
          _appOpenRetryAttempt = 0;
          if (_isFirstLaunch) {
            _isFirstLaunch = false;
            _showAdIfReady();
          }
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          _appOpenRetryAttempt++;
          final delay = pow(2, min(6, _appOpenRetryAttempt)).toInt();
          Future.delayed(Duration(seconds: delay), loadAppOpenAd);
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {
          loadAppOpenAd();
        },
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {
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

  Future<void> showInterstitialAd() async {
    if (_iapService.isPremium) return;

    // Time-based cooldown
    final now = DateTime.now();
    if (_lastInterstitialShown != null) {
      final elapsed = now.difference(_lastInterstitialShown!);
      if (elapsed.inSeconds < _interstitialCooldownSeconds) return;
    }

    // Frequency counter
    _interstitialCounter++;
    if (_interstitialCounter % _interstitialFrequency != 0) return;

    final isReady =
        (await AppLovinMAX.isInterstitialReady(
          AppConstants.adUnitIdInterstitial,
        )) ??
        false;
    if (isReady) {
      AppLovinMAX.showInterstitial(AppConstants.adUnitIdInterstitial);
      _lastInterstitialShown = DateTime.now();
    } else {
      loadInterstitial();
    }
  }

  // ── Banner Ad Widget ─────────────────────────────────────────────────────
  Widget getBannerAdWidget() {
    if (_iapService.isPremium) return const SizedBox.shrink();
    return const _BannerAdWidget();
  }

  // ── Native Ad Widget ─────────────────────────────────────────────────────
  Widget getNativeAdWidget() {
    if (_iapService.isPremium) return const SizedBox.shrink();
    return _NativeAdWidget(adUnitId: AppConstants.adUnitIdNative);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner Ad Widget
// ─────────────────────────────────────────────────────────────────────────────
class _BannerAdWidget extends StatefulWidget {
  const _BannerAdWidget();

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  bool _isAdLoaded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Keep height 1 (NOT 0) when not loaded — height:0 prevents MaxAdView
      // from requesting the ad. It expands to 50 once the ad is loaded.
      height: _isAdLoaded ? 50 : 1,
      child: MaxAdView(
        adUnitId: AppConstants.adUnitIdBanner,
        adFormat: AdFormat.banner,
        listener: AdViewAdListener(
          onAdLoadedCallback: (ad) {
            if (mounted) setState(() => _isAdLoaded = true);
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            if (mounted) setState(() => _isAdLoaded = false);
          },
          onAdClickedCallback: (ad) {},
          onAdExpandedCallback: (ad) {},
          onAdCollapsedCallback: (ad) {},
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Native Ad Widget
// ─────────────────────────────────────────────────────────────────────────────
class _NativeAdWidget extends StatefulWidget {
  final String adUnitId;
  const _NativeAdWidget({required this.adUnitId});

  @override
  State<_NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<_NativeAdWidget> {
  bool _isAdLoaded = false;
  final MaxNativeAdViewController _controller = MaxNativeAdViewController();

  @override
  void initState() {
    super.initState();
    _controller.loadAd();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: _isAdLoaded ? const EdgeInsets.only(bottom: 12) : EdgeInsets.zero,
      height: _isAdLoaded ? 140 : 0,
      decoration: _isAdLoaded
          ? BoxDecoration(
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
            )
          : null,
      clipBehavior: _isAdLoaded ? Clip.hardEdge : Clip.none,
      child: MaxNativeAdView(
        adUnitId: widget.adUnitId,
        controller: _controller,
        listener: NativeAdListener(
          onAdLoadedCallback: (ad) {
            if (mounted) setState(() => _isAdLoaded = true);
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            if (mounted) setState(() => _isAdLoaded = false);
          },
          onAdClickedCallback: (ad) {},
          onAdRevenuePaidCallback: (ad) {},
        ),
        child: _isAdLoaded ? _buildNativeAdContent(theme, isDark) : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildNativeAdContent(ThemeData theme, bool isDark) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: icon + text + CTA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const MaxNativeAdIconView(width: 36, height: 36),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Ad',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: MaxNativeAdBodyView(
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 32,
                  child: MaxNativeAdCallToActionView(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(theme.primaryColor),
                      foregroundColor:
                          WidgetStateProperty.all(Colors.white),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      textStyle: WidgetStateProperty.all(
                        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      elevation: WidgetStateProperty.all(0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: media thumbnail
          Card(
            color: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: const BorderSide(color: Colors.white24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  const MaxNativeAdMediaView(width: 80, height: 120),
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: MaxNativeAdOptionsView(width: 16, height: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
