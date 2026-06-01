import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class ProviderConfigState {
  final String tinyUrlToken;
  final String cuttLyKey;
  final String bitLyToken;
  final String defaultProvider;

  ProviderConfigState({
    required this.tinyUrlToken,
    required this.cuttLyKey,
    required this.bitLyToken,
    required this.defaultProvider,
  });

  ProviderConfigState copyWith({
    String? tinyUrlToken,
    String? cuttLyKey,
    String? bitLyToken,
    String? defaultProvider,
  }) {
    return ProviderConfigState(
      tinyUrlToken: tinyUrlToken ?? this.tinyUrlToken,
      cuttLyKey: cuttLyKey ?? this.cuttLyKey,
      bitLyToken: bitLyToken ?? this.bitLyToken,
      defaultProvider: defaultProvider ?? this.defaultProvider,
    );
  }
}

class ProviderKeysNotifier extends Notifier<ProviderConfigState> {
  static const String _tinyUrlTokenKey = 'tinyurl_api_token';
  static const String _cuttLyKeyKey = 'cuttly_api_key';
  static const String _bitLyTokenKey = 'bitly_api_token';
  static const String _defaultProviderKey = 'default_shortening_provider';

  @override
  ProviderConfigState build() {
    _loadConfig();
    return ProviderConfigState(
      tinyUrlToken: '',
      cuttLyKey: '',
      bitLyToken: '',
      defaultProvider: AppConstants.isGd, // Default out-of-the-box unauthenticated direct provider
    );
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final tinyToken = prefs.getString(_tinyUrlTokenKey) ?? '';
    final cuttKey = prefs.getString(_cuttLyKeyKey) ?? '';
    final bitToken = prefs.getString(_bitLyTokenKey) ?? '';
    final defProvider = prefs.getString(_defaultProviderKey) ?? AppConstants.isGd;

    state = ProviderConfigState(
      tinyUrlToken: tinyToken,
      cuttLyKey: cuttKey,
      bitLyToken: bitToken,
      defaultProvider: defProvider,
    );
  }

  Future<void> setTinyUrlToken(String token) async {
    final trimmed = token.trim();
    state = state.copyWith(tinyUrlToken: trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tinyUrlTokenKey, trimmed);
  }

  Future<void> setCuttLyKey(String key) async {
    final trimmed = key.trim();
    state = state.copyWith(cuttLyKey: trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cuttLyKeyKey, trimmed);
  }

  Future<void> setBitLyToken(String token) async {
    final trimmed = token.trim();
    state = state.copyWith(bitLyToken: trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bitLyTokenKey, trimmed);
  }

  Future<void> setDefaultProvider(String provider) async {
    state = state.copyWith(defaultProvider: provider);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultProviderKey, provider);
  }
}

final providerKeysProvider = NotifierProvider<ProviderKeysNotifier, ProviderConfigState>(
  ProviderKeysNotifier.new,
);
