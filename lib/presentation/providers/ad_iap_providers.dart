import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/iap_service.dart';
import '../../core/services/ad_service.dart';

/// Provides the singleton IapService instance.
final iapServiceProvider = Provider<IapService>((ref) => IapService());

/// Provides the singleton AdService instance.
final adServiceProvider = Provider<AdService>((ref) => AdService());
