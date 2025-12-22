import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/url_data.dart';
import '../../data/repository/url_repository.dart';

final urlRepositoryProvider = Provider((ref) => UrlRepository());

class HistoryFilter {
  final String query;
  final String? type; // 'shorten', 'expand', or null (all)

  HistoryFilter({this.query = '', this.type});

  HistoryFilter copyWith({String? query, String? type}) {
    return HistoryFilter(query: query ?? this.query, type: type ?? this.type);
  }
}

// StateProvider is available in Riverpod. If it errors, it might be due to package version or import.
// flutter_riverpod exports StateProvider from riverpod.
// Let's use Notifier for Filter to be consistent with everything else.
class FilterNotifier extends Notifier<HistoryFilter> {
  @override
  HistoryFilter build() {
    return HistoryFilter();
  }

  void updateQuery(String newQuery) {
    state = HistoryFilter(query: newQuery, type: state.type);
  }

  void updateType(String? newType) {
    state = HistoryFilter(query: state.query, type: newType);
  }
}

final historyFilterProvider = NotifierProvider<FilterNotifier, HistoryFilter>(
  FilterNotifier.new,
);

class HistoryNotifier extends AsyncNotifier<List<UrlData>> {
  late final UrlRepository _repository;

  @override
  Future<List<UrlData>> build() async {
    _repository = ref.watch(urlRepositoryProvider);
    return _getAllHistory();
  }

  Future<List<UrlData>> _getAllHistory() async {
    return _repository.getHistory();
  }

  Future<void> deleteUrl(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteUrl(id);
      return _getAllHistory();
    });
  }

  void refresh() {
    ref.invalidateSelf();
  }
}

final historyProvider = AsyncNotifierProvider<HistoryNotifier, List<UrlData>>(
  HistoryNotifier.new,
);

final filteredHistoryProvider = Provider<List<UrlData>>((ref) {
  final historyAsync = ref.watch(historyProvider);
  final filter = ref.watch(historyFilterProvider);

  return historyAsync.maybeWhen(
    data: (history) {
      if (filter.query.isEmpty && filter.type == null) {
        return history;
      }

      return history.where((item) {
        bool matchesQuery = true;
        if (filter.query.isNotEmpty) {
          final q = filter.query.toLowerCase();
          matchesQuery =
              (item.originalUrl?.toLowerCase().contains(q) ?? false) ||
              (item.shortenedUrl?.toLowerCase().contains(q) ?? false) ||
              (item.expandedUrl?.toLowerCase().contains(q) ?? false);
        }

        if (!matchesQuery) return false;

        if (filter.type == 'shorten') {
          return item.provider != null;
        } else if (filter.type == 'expand') {
          return item.provider == null;
        }
        return true;
      }).toList();
    },
    orElse: () => [],
  );
});
