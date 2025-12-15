import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/url_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ResultCard extends StatelessWidget {
  final UrlData result;
  final VoidCallback? onClose;

  const ResultCard({super.key, required this.result, this.onClose});

  @override
  Widget build(BuildContext context) {
    // Determine what to show
    final isShorten = result.provider != null;
    // If provider is null -> it was expansion.

    final mainDisplayUrl = isShorten ? result.shortenedUrl : result.expandedUrl;
    final secondaryUrl = isShorten ? result.originalUrl : result.shortenedUrl;
    // For expansion: original was short, result is expanded.

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isShorten ? "Shortened URL" : "Expanded URL",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                mainDisplayUrl ?? "Error",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Original: $secondaryUrl",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      if (mainDisplayUrl != null) {
                        Clipboard.setData(ClipboardData(text: mainDisplayUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Copied to clipboard")),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (mainDisplayUrl != null) {
                        Share.share(mainDisplayUrl);
                      }
                    },
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                  ),
                ),
              ],
            ),
          ],
        ).animate().fadeIn().moveY(begin: 10, end: 0),
      ),
    );
  }
}
