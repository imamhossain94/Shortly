import 'package:flutter/material.dart';
import 'package:flutter_shortly/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../providers/shortener_provider.dart';
import '../providers/history_provider.dart';
import 'result_screen.dart';
import 'package:intl/intl.dart';

class ShortenerView extends ConsumerStatefulWidget {
  const ShortenerView({super.key});

  @override
  ConsumerState<ShortenerView> createState() => _ShortenerViewState();
}

class _ShortenerViewState extends ConsumerState<ShortenerView>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _urlController = TextEditingController();
  String _selectedProvider = AppConstants.tinyUrl;

  final List<String> _providers = [
    AppConstants.tinyUrl,
    AppConstants.chilpIt,
    AppConstants.clckRu,
    AppConstants.daGd,
    AppConstants.isGd,
    AppConstants.osdb,
    AppConstants.cuttLy,
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _handleShorten() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterUrl)),
      );
      return;
    }
    ref.read(shortenerProvider.notifier).shorten(_selectedProvider, url);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(shortenerProvider, (previous, next) {
      if (next.result != null && next.error == null && !next.isLoading) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(result: next.result!)),
        );
        ref.read(historyProvider.notifier).refresh();
      }
    });

    final state = ref.watch(shortenerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history = ref.watch(filteredHistoryProvider);

    return Container(
      color: Colors.transparent,
      child: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, size: 24),
                onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
              ),
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Short',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: 'ly',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
            ],
          ),

          // ── URL Input + Button ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Long URL',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Provider + URL input card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isDark
                          ? Border.all(color: AppColors.darkCardBorder)
                          : Border.all(color: Colors.grey.shade200),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      children: [
                        // URL TextField
                        TextField(
                          controller: _urlController,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimary
                                : Colors.black87,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'https://example.com/long-link',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.link_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.content_paste_rounded,
                                size: 18,
                              ),
                              color: AppColors.textMuted,
                              onPressed: () async {
                                final data = await Clipboard.getData(
                                  'text/plain',
                                );
                                if (data?.text != null) {
                                  _urlController.text = data!.text!;
                                }
                              },
                            ),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                          ),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleShorten(),
                        ),

                        // Provider selector row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBg.withValues(alpha: 0.5)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkCardBorder
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedProvider,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.expand_more_rounded,
                                  color: AppColors.textMuted,
                                  size: 18,
                                ),
                                dropdownColor: isDark
                                    ? AppColors.darkCard
                                    : Colors.white,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                                items: _providers
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(p),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedProvider = value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Shorten Now button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _handleShorten,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.accent.withValues(
                          alpha: 0.5,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Shorten Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),

                  // Error message
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Recent Links header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Links',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ── Recent Link Cards ─────────────────────────────────────────
          if (history.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.link_off_rounded,
                        size: 48,
                        color: isDark
                            ? AppColors.textMuted
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No links shortened yet',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textMuted
                              : Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = history[index];
                  return _LinkCard(item: item, isDark: isDark);
                }, childCount: history.length > 5 ? 5 : history.length),
              ),
            ),
        ],
      ),
    );
  }
}

/// Redesigned Card widget for recent link entries
class _LinkCard extends ConsumerWidget {
  final dynamic item;
  final bool isDark;

  const _LinkCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortUrl = item.shortenedUrl ?? item.expandedUrl ?? 'Unknown';
    final originalUrl = item.originalUrl ?? item.shortenedUrl ?? '';
    final date = DateFormat(
      'dd MMM yyyy',
    ).format(DateTime.fromMillisecondsSinceEpoch(item.timestamp));

    String faviconLetter = '?';
    Color faviconBg = AppColors.textMuted;
    try {
      final uri = Uri.parse(originalUrl);
      final host = uri.host;
      if (host.isNotEmpty) {
        faviconLetter = host.replaceAll('www.', '')[0].toUpperCase();
        faviconBg = _colorFromHost(host);
      }
    } catch (_) {}

    return Container(
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
                // Modern square rounded favicon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: faviconBg.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: faviconBg.withValues(alpha: 0.3)),
                  ),
                  child: Center(
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

                // Link info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shortUrl,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimary
                              : Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
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
    );
  }

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
}
