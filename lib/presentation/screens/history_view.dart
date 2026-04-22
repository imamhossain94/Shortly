import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shortly/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../widgets/app_custom_bar.dart';
import '../providers/history_provider.dart';
import 'result_screen.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allHistory = historyState.value ?? [];

    // Local filtering logic
    final history = allHistory.where((item) {
      bool matchesQuery = true;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        matchesQuery =
            (item.originalUrl?.toLowerCase().contains(q) ?? false) ||
            (item.shortenedUrl?.toLowerCase().contains(q) ?? false) ||
            (item.expandedUrl?.toLowerCase().contains(q) ?? false);
      }

      if (!matchesQuery) return false;

      if (_filterType == 'shorten') {
        return item.provider != null;
      } else if (_filterType == 'expand') {
        return item.provider == null;
      }
      return true;
    }).toList();

    if (historyState.isLoading && allHistory.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header + Search (fixed, non-scrollable) ──────────────────────
        AppCustomBar(
          title: 'My ',
          accentTitle: 'Links',
          actions: [
            GestureDetector(
              onTap: () => ref.read(historyProvider.notifier).refresh(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(11),
                  border: isDark
                      ? Border.all(color: AppColors.darkCardBorder)
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: isDark ? AppColors.textSecondary : Colors.grey.shade600,
                ),
              ),
            ),
          ],
          bottom: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: isDark
                  ? Border.all(color: AppColors.darkCardBorder)
                  : Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: isDark ? AppColors.textPrimary : Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search links...',
                hintStyle: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textMuted, size: 19),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 17),
                        color: AppColors.textMuted,
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : PopupMenuButton<String?>(
                        icon: const Icon(Icons.filter_list_rounded,
                            size: 18, color: AppColors.textMuted),
                        onSelected: (value) {
                          setState(() {
                            _filterType = value;
                          });
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'all',
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
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),

        // ── Summary chips (fixed, non-scrollable) ──────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              _SummaryChip(
                label: '${history.length} Links',
                isDark: isDark,
                isAccent: false,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label:
                    '${history.where((i) => i.provider != null).length} Shortened',
                isDark: isDark,
                isAccent: true,
              ),
            ],
          ),
        ),

        // ── Scrollable list ─────────────────────────────────────────────
        Expanded(
          child: history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off_rounded,
                        size: 56,
                        color: isDark
                            ? AppColors.textMuted
                            : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppLocalizations.of(context)!.noHistory,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textMuted
                              : Colors.grey.shade500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _HistoryLinkCard(item: item, isDark: isDark, ref: ref);
                  },
                ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool isAccent;

  const _SummaryChip({
    required this.label,
    required this.isDark,
    required this.isAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isAccent
            ? AppColors.accent.withValues(alpha: 0.12)
            : (isDark ? AppColors.darkCard : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(20),
        border: isAccent
            ? Border.all(color: AppColors.accent.withValues(alpha: 0.3))
            : Border.all(
                color: isDark
                    ? AppColors.darkCardBorder
                    : Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAccent
              ? AppColors.accent
              : (isDark ? AppColors.textSecondary : Colors.grey.shade700),
        ),
      ),
    );
  }
}

class _HistoryLinkCard extends StatelessWidget {
  final dynamic item;
  final bool isDark;
  final WidgetRef ref;

  const _HistoryLinkCard({
    required this.item,
    required this.isDark,
    required this.ref,
  });

  Color _colorFromHost(String host) {
    final colors = [
      const Color(0xFF3B5998),
      const Color(0xFF1DA1F2),
      const Color(0xFF25D366),
      const Color(0xFFE1306C),
      const Color(0xFFFF0000),
      const Color(0xFF0077B5),
      const Color(0xFFFF6600),
      const Color(0xFF7B2FBE),
      const Color(0xFF00897B),
    ];
    return colors[host.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isShorten = item.provider != null;
    final shortUrl =
        item.shortenedUrl ?? item.expandedUrl ?? 'Unknown';
    final originalUrl = item.originalUrl ?? item.shortenedUrl ?? '';
    final date = DateFormat('dd MMM yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(item.timestamp),
    );

    String faviconLetter = '?';
    Color faviconBg = AppColors.textMuted;
    String? faviconUrl;
    try {
      final uri = Uri.parse(originalUrl);
      final host = uri.host;
      if (host.isNotEmpty) {
        faviconLetter = host.replaceAll('www.', '')[0].toUpperCase();
        faviconBg = _colorFromHost(host);
        faviconUrl =
            'https://www.google.com/s2/favicons?sz=64&domain=${uri.scheme}://$host';
      }
    } catch (_) {}

    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child:
            const Icon(Icons.delete_rounded, color: Colors.red, size: 24),
      ),
      onDismissed: (_) {
        ref.read(historyProvider.notifier).deleteUrl(item.id!);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
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
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ResultScreen(result: item)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Favicon with image + letter fallback
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: faviconBg.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: faviconBg.withValues(alpha: 0.25)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: faviconUrl != null
                        ? Image.network(
                            faviconUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                            frameBuilder: (ctx, child, frame, wasSynchronouslyLoaded) {
                              if (frame == null) {
                                return Center(
                                  child: Text(
                                    faviconLetter,
                                    style: TextStyle(
                                      color: faviconBg,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: child,
                              );
                            },
                            errorBuilder: (ctx, err, stack) => Center(
                              child: Text(
                                faviconLetter,
                                style: TextStyle(
                                  color: faviconBg,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              faviconLetter,
                              style: TextStyle(
                                color: faviconBg,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                shortUrl,
                                style: TextStyle(
                                  color: isDark ? AppColors.textPrimary : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          originalUrl,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondary
                                : Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isShorten
                                    ? AppColors.accent.withValues(alpha: 0.12)
                                    : Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isShorten ? 'Shortened' : 'Expanded',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isShorten
                                      ? AppColors.accent
                                      : Colors.green.shade600,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions: copy
                  Container(
                    padding: const EdgeInsets.only(left: 12),
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: shortUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
