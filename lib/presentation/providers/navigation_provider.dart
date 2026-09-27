import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'history_provider.dart';

/// Tab indices of the `PageView` in `MainScreen`, in display order.
abstract class MainTab {
  static const int home = 0;
  static const int myLinks = 1;
  static const int expand = 2;
  static const int settings = 3;

  static const int count = 4;
}

/// The tab `MainScreen` is currently showing.
///
/// Lives outside `MainScreen` so a view inside the `PageView` can send the user
/// to a sibling tab — the Expand tab linking into My Links, for instance —
/// without reaching for the parent's state.
class MainTabNotifier extends Notifier<int> {
  @override
  int build() => MainTab.home;

  void select(int index) {
    if (index < 0 || index >= MainTab.count) return;
    state = index;
  }

  /// Opens My Links already narrowed to [type] (see [HistoryType]; null shows
  /// everything).
  void openMyLinks(String? type) {
    ref.read(historyFilterProvider.notifier).updateType(type);
    state = MainTab.myLinks;
  }
}

final mainTabProvider = NotifierProvider<MainTabNotifier, int>(
  MainTabNotifier.new,
);
