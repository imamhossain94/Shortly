import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/url_data.dart';
import '../widgets/qr_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final isShorten = widget.result.provider != null;
    final displayUrl = isShorten
        ? widget.result.shortenedUrl
        : widget.result.expandedUrl;
    final originalUrl = widget.result.originalUrl;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isShorten ? "Shortened URL" : "Expanded URL",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "Details", icon: Icon(Icons.link)),
                Tab(text: "QR Code", icon: Icon(Icons.qr_code)),
              ],
            ),
            SizedBox(
              height: 320,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Details Tab
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              displayUrl ?? "Error",
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 5,
                            ),
                          ),
                        ).animate().scale(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.copy,
                                label: "Copy",
                                onTap: () {
                                  if (displayUrl != null) {
                                    Clipboard.setData(
                                      ClipboardData(text: displayUrl),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Copied!")),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.share,
                                label: "Share",
                                onTap: () {
                                  if (displayUrl != null)
                                    Share.share(displayUrl);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _ActionButton(
                          icon: Icons.open_in_browser,
                          label: "Open in Browser",
                          isOutlined: true,
                          onTap: () async {
                            if (displayUrl != null) {
                              final uri = Uri.parse(displayUrl);
                              if (await canLaunchUrl(uri)) {
                                launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Original: $originalUrl",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // QR Tab
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (displayUrl != null)
                            QrWidget(
                              data: displayUrl,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Colors.black,
                              backgroundColor: Colors.white,
                            ).animate().scale(),
                          const SizedBox(height: 16),
                          Text(
                            "Scan to open",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isOutlined;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: style,
    );
  }
}
