import 'package:flutter/material.dart';
import 'package:url_shortener/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/url_data.dart';
import '../../core/theme.dart';
import '../widgets/qr_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultDialog extends StatefulWidget {
  final UrlData result;

  const ResultDialog({super.key, required this.result});

  @override
  State<ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isShorten = widget.result.provider != null;
    final displayUrl =
        isShorten ? widget.result.shortenedUrl : widget.result.expandedUrl;
    final originalUrl = widget.result.originalUrl;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      isShorten
                          ? Icons.link_rounded
                          : Icons.open_in_new_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isShorten
                              ? AppLocalizations.of(context)!.shortenedUrl
                              : AppLocalizations.of(context)!.expanded,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (widget.result.provider != null)
                          Text(
                            'via ${widget.result.provider}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color:
                          isDark ? AppColors.textMuted : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Tab Bar ───────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBg
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(9),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondary
                    : Colors.grey.shade600,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'QR Code'),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Tab Content ───────────────────────────────────────────
            SizedBox(
              height: 320,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Details tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Main URL display
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.2),
                            ),
                          ),
                          child: SelectableText(
                            displayUrl ?? 'Error',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Original URL
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBg
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkCardBorder
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.link_off_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColors.textMuted
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${AppLocalizations.of(context)!.original}: ${originalUrl ?? '—'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondary
                                        : Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: _ActionBtn(
                                icon: Icons.copy_rounded,
                                label: AppLocalizations.of(context)!.copy,
                                onTap: () {
                                  if (displayUrl != null) {
                                    Clipboard.setData(
                                        ClipboardData(text: displayUrl));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(
                                                context)!
                                            .copiedToClipboard),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ActionBtn(
                                icon: Icons.share_rounded,
                                label: AppLocalizations.of(context)!.share,
                                isOutlined: true,
                                onTap: () {
                                  if (displayUrl != null) {
                                    SharePlus.instance.share(
                                      ShareParams(text: displayUrl),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        _ActionBtn(
                          icon: Icons.open_in_browser_rounded,
                          label: 'Open in Browser',
                          isOutlined: true,
                          onTap: () async {
                            if (displayUrl != null) {
                              final uri = Uri.parse(displayUrl);
                              if (await canLaunchUrl(uri)) {
                                launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // QR Code tab
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (displayUrl != null)
                          Expanded(
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.12),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: QrWidget(
                                  data: displayUrl,
                                  color: Colors.black,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          'Scan to open the link',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondary
                                : Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isOutlined;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
