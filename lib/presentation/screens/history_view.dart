import 'package:flutter/material.dart';
import 'package:flutter_shortly/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../dialogs/result_dialog.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the filtered history
    final history = ref.watch(filteredHistoryProvider);
    final historyState = ref.watch(historyProvider);

    if (historyState.isLoading && history.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.history),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SearchBar(
              controller: _searchController,
              hintText: "${AppLocalizations.of(context)!.search}...",
              leading: const Icon(Icons.search),
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              onChanged: (value) {
                ref.read(historyFilterProvider.notifier).updateQuery(value);
              },
              trailing: [
                PopupMenuButton<String?>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    ref.read(historyFilterProvider.notifier).updateType(value);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: null,
                      child: Text(AppLocalizations.of(context)!.all),
                    ),
                    PopupMenuItem(
                      value: 'shorten',
                      child: Text(AppLocalizations.of(context)!.shortenedUrl),
                    ),
                    PopupMenuItem(
                      value: 'expand',
                      child: Text(AppLocalizations.of(context)!.expanded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(historyProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              // Optional: Clear all logic
            },
          ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noHistory,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ).animate().fadeIn(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Dismissible(
                  key: Key(item.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  onDismissed: (_) {
                    ref.read(historyProvider.notifier).deleteUrl(item.id!);
                  },
                  child: Card(
                    elevation: 0,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(
                          item.provider != null
                              ? Icons.link
                              : Icons.unfold_more,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        item.shortenedUrl ?? item.expandedUrl ?? "Unknown",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            item.provider != null
                                ? "${AppLocalizations.of(context)!.original}: ${item.originalUrl}"
                                : "${AppLocalizations.of(context)!.expanded}: ${item.expandedUrl}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMd().add_jm().format(
                              DateTime.fromMillisecondsSinceEpoch(
                                item.timestamp,
                              ),
                            ),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ResultDialog(result: item),
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: (20 * index).ms).slideX(begin: 0.1),
                );
              },
            ),
    );
  }
}
