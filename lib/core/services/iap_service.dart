import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class IapService extends ChangeNotifier {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _productPrice = 'USD 0.99 /lifetime';
  String get productPrice => _productPrice;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _initialized = false;

  static const String _premiumKey = 'is_premium';
  static const Set<String> _productIds = {AppConstants.productRemoveAds};

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Always load persisted premium status first so UI is correct immediately
    await _loadPremiumStatus();

    // Attach purchase stream listener (always safe)
    try {
      final purchaseUpdated = _iap.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _listenToPurchaseUpdated,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          debugPrint('IapService: Stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('IapService: Could not attach purchase stream: $e');
    }

    // Restore purchases in background — never block startup or crash on error
    _silentRestore();
    _loadProductPrice();
  }

  Future<void> _loadProductPrice() async {
    try {
      final bool available = await _iap.isAvailable();
      if (!available) return;
      
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_productIds);

      if (response.productDetails.isNotEmpty) {
        final matches =
            response.productDetails.where((p) => p.id == AppConstants.productRemoveAds);
        final ProductDetails productDetails =
            matches.isNotEmpty ? matches.first : response.productDetails.first;
        
        _productPrice = '${productDetails.currencyCode} ${productDetails.rawPrice} /lifetime';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('IapService: _loadProductPrice error: $e');
    }
  }

  /// Attempts a restore silently; any error is caught and logged only.
  Future<void> _silentRestore() async {
    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        debugPrint('IapService: Billing not available on this device/build.');
        return;
      }
      await _iap.restorePurchases();
    } catch (e) {
      // Expected in debug builds / unsigned APKs — not a crash-worthy error.
      debugPrint('IapService: restorePurchases skipped: $e');
    }
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumKey) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('IapService: Could not load premium status: $e');
    }
  }

  Future<void> _setPremiumStatus(bool status) async {
    _isPremium = status;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, status);
    } catch (e) {
      debugPrint('IapService: Could not persist premium status: $e');
    }
    notifyListeners();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      debugPrint('IapService: Purchase status: ${purchaseDetails.status}');
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _isLoading = true;
        notifyListeners();
      } else {
        _isLoading = false;
        if (purchaseDetails.status == PurchaseStatus.error) {
          _errorMessage = purchaseDetails.error?.message ?? 'Purchase failed';
          notifyListeners();
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _deliverProduct(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          try {
            _iap.completePurchase(purchaseDetails);
          } catch (e) {
            debugPrint('IapService: completePurchase error: $e');
          }
        }
        notifyListeners();
      }
    }
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.productID == AppConstants.productRemoveAds) {
      _setPremiumStatus(true);
      debugPrint('IapService: Premium unlocked!');
    }
  }

  Future<void> buyRemoveAds() async {
    _errorMessage = null;

    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        _errorMessage = 'Store not available. Please check your connection.';
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('IapService: Products not found: ${response.notFoundIDs}');
      }

      final List<ProductDetails> products = response.productDetails;
      if (products.isEmpty) {
        _isLoading = false;
        _errorMessage = 'Product not found in store. Please try again later.';
        notifyListeners();
        return;
      }

      final matches =
          products.where((p) => p.id == AppConstants.productRemoveAds);
      final ProductDetails productDetails =
          matches.isNotEmpty ? matches.first : products.first;

      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Purchase failed: $e';
      notifyListeners();
      debugPrint('IapService: buyRemoveAds error: $e');
    }
  }

  Future<void> restorePurchases() async {
    await _silentRestore();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
