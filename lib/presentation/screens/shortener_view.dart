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
  bool _isFocused = false;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header (fixed, non-scrollable) ────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
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
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
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
                      Icons.menu_rounded,
                      size: 20,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── URL Input + Button (fixed, non-scrollable) ────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section label
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Paste your long URL',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondary
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── URL input card ──────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: _isFocused
                      ? Border.all(color: AppColors.accent, width: 2)
                      : isDark
                          ? Border.all(color: AppColors.darkCardBorder)
                          : Border.all(color: Colors.grey.shade200),
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _isFocused
                                  ? AppColors.accent.withValues(alpha: 0.12)
                                  : (isDark
                                      ? AppColors.darkBg.withValues(alpha: 0.5)
                                      : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.link_rounded,
                              size: 18,
                              color: _isFocused
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Focus(
                              onFocusChange: (focused) =>
                                  setState(() => _isFocused = focused),
                              child: TextField(
                                controller: _urlController,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : Colors.black87,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'https://example.com/very-long-url...',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? AppColors.textMuted
                                        : Colors.grey.shade400,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _handleShorten(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.content_paste_rounded,
                              size: 18,
                              color: _isFocused
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                            ),
                            splashRadius: 20,
                            tooltip: 'Paste',
                            onPressed: () async {
                              final data =
                                  await Clipboard.getData('text/plain');
                              if (data?.text != null) {
                                _urlController.text = data!.text!;
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark
                            ? AppColors.darkCardBorder
                            : Colors.grey.shade100,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.hub_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'via',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedProvider,
                                isExpanded: true,
                                isDense: true,
                                icon: const Icon(
                                  Icons.expand_more_rounded,
                                  color: AppColors.textMuted,
                                  size: 16,
                                ),
                                dropdownColor: isDark
                                    ? AppColors.darkCard
                                    : Colors.white,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.accent
                                      : AppColors.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
                                    setState(
                                        () => _selectedProvider = value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.flash_on_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Shorten Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
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

              const SizedBox(height: 20),

              // Recent Links header
              Text(
                'Recent Links',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        // ── Scrollable list ────────────────────────────────────────────────
        Expanded(
          child: history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: history.length > 5 ? 5 : history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _LinkCard(item: item, isDark: isDark);
                  },
                ),
        ),
      ],
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
                // Favicon with image + letter fallback
                _FaviconWidget(
                  faviconUrl: faviconUrl,
                  faviconLetter: faviconLetter,
                  faviconBg: faviconBg,
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

/// Smart favicon widget: tries to load image favicon, falls back to letter icon
class _FaviconWidget extends StatelessWidget {
  final String? faviconUrl;
  final String faviconLetter;
  final Color faviconBg;

  const _FaviconWidget({
    required this.faviconUrl,
    required this.faviconLetter,
    required this.faviconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              // Add padding so favicon sits nicely inside the container
              frameBuilder: (ctx, child, frame, wasSynchronouslyLoaded) {
                if (frame == null) return _letterFallback();
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: child,
                );
              },
              errorBuilder: (ctx, err, stack) => _letterFallback(),
            )
          : _letterFallback(),
    );
  }

  Widget _letterFallback() {
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
}
