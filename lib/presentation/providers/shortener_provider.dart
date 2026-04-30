import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/url_data.dart';
import '../../data/repository/url_repository.dart';
import 'history_provider.dart';

// State to hold the result of the current operation
class ShortenerState {
  final bool isLoading;
  final UrlData? result;
  final String? error;

  ShortenerState({this.isLoading = false, this.result, this.error});

  ShortenerState copyWith({
    bool? isLoading,
    UrlData? result,
    String? error,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return ShortenerState(
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ShortenerNotifier extends Notifier<ShortenerState> {
  late final UrlRepository _repository;

  @override
  ShortenerState build() {
    _repository = ref.watch(urlRepositoryProvider);
    return ShortenerState();
  }

  Future<void> shorten(String provider, String url) async {
    state = state.copyWith(isLoading: true, clearError: true, clearResult: true);
    try {
      final result = await _repository.shortenUrl(provider, url);
      state = state.copyWith(isLoading: false, result: result);
      if (result.success == true) {
        ref.read(historyProvider.notifier).refresh();
      } else {
        state = state.copyWith(
          error: "Failed to shorten URL. Please try again.",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> expand(String url) async {
    state = state.copyWith(isLoading: true, clearError: true, clearResult: true);
    try {
      final result = await _repository.expandUrl(url);
      state = state.copyWith(isLoading: false, result: result);
      if (result.success == true) {
        ref.read(historyProvider.notifier).refresh();
      } else {
        state = state.copyWith(error: "Failed to expand URL.");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearResult() {
    state = ShortenerState();
  }
}

final shortenerProvider = NotifierProvider<ShortenerNotifier, ShortenerState>(
  ShortenerNotifier.new,
);
