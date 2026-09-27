import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/url_data.dart';
import '../../data/repository/url_repository.dart';

final urlRepositoryProvider = Provider((ref) => UrlRepository());

/// The `type` values [HistoryFilter] accepts. `null` means "no filter".
abstract class HistoryType {
  static const String? all = null;
  static const String shortened = 'shorten';
  static const String expanded = 'expand';
}

class HistoryFilter {
  final String query;

  /// One of [HistoryType], or null for everything.
  final String? type;

  HistoryFilter({this.query = '', this.type});

  HistoryFilter copyWith({String? query, String? type}) {
    return HistoryFilter(query: query ?? this.query, type: type ?? this.type);
  }
}

class FilterNotifier extends Notifier<HistoryFilter> {
  @override
  HistoryFilter build() {
    return HistoryFilter();
  }

  void updateQuery(String newQuery) {
    state = HistoryFilter(query: newQuery, type: state.type);
  }

  void updateType(String? newType) {
    // The filter menu sends 'all' for the unfiltered entry; normalise it so
    // callers only ever compare against the two real types.
    final normalised = newType == 'all' ? HistoryType.all : newType;
    state = HistoryFilter(query: state.query, type: normalised);
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

  Future<void> refresh() async {
    // Keep previous data visible while refreshing (no loading flash)
    state = await AsyncValue.guard(() => _getAllHistory());
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

        if (filter.type == HistoryType.shortened) {
          return item.provider != null;
        } else if (filter.type == HistoryType.expanded) {
          return item.provider == null;
        }
        return true;
      }).toList();
    },
    orElse: () => [],
  );
});
