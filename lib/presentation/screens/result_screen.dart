import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/url_data.dart';
import '../../core/theme.dart';
import '../../core/services/ad_service.dart';
import '../widgets/qr_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatefulWidget {
  final UrlData result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isShorten ? 'Shortened Link' : 'Expanded Link',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimary : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.textPrimary : Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
            AdService().showInterstitialAd();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Provider info
            if (isShorten)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hub_rounded, size: 14, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        'Powered by ${widget.result.provider}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: isDark ? Border.all(color: AppColors.darkCardBorder) : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.accent,
                  unselectedLabelColor:
                      isDark ? AppColors.textSecondary : Colors.grey.shade500,
                  labelStyle:
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  unselectedLabelStyle:
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'Details'),
                    Tab(text: 'QR Code'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  // Details tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Primary URL',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkCardBorder
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  displayUrl ?? 'Error',
                                  style: TextStyle(
                                    color: isDark ? AppColors.textPrimary : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, color: AppColors.accent),
                                onPressed: () {
                                  if (displayUrl != null) {
                                    Clipboard.setData(ClipboardData(text: displayUrl));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Copied to clipboard')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Original Destination',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkCardBorder
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: SelectableText(
                            originalUrl ?? '—',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondary : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (displayUrl != null) {
                                    SharePlus.instance.share(ShareParams(text: displayUrl));
                                  }
                                },
                                icon: const Icon(Icons.share_rounded, size: 20),
                                label: const Text('Share Link', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  if (displayUrl != null) {
                                    final uri = Uri.parse(displayUrl);
                                    if (await canLaunchUrl(uri)) {
                                      launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  }
                                },
                                icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                                label: const Text('Open in Browser', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? AppColors.textPrimary : Colors.black87,
                                  side: BorderSide(
                                    color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        AdService().getNativeAdWidget(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // QR Code tab
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          if (displayUrl != null) ...[
                            // Outer card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkCard
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkCardBorder
                                      : Colors.grey.shade200,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(
                                        alpha: isDark ? 0.12 : 0.08),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // QR with scan-frame corners
                                  Center(
                                    child: SizedBox(
                                      width: 220,
                                      height: 220,
                                      child: Stack(
                                        children: [
                                          // White QR background
                                          Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: QrWidget(
                                              data: displayUrl,
                                              color: Colors.black,
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          // Top-left corner
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: _ScanCorner(
                                                topLeft: true),
                                          ),
                                          // Top-right corner
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: _ScanCorner(
                                                topRight: true),
                                          ),
                                          // Bottom-left corner
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            child: _ScanCorner(
                                                bottomLeft: true),
                                          ),
                                          // Bottom-right corner
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: _ScanCorner(
                                                bottomRight: true),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  // URL chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppColors.accent
                                              .withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.link_rounded,
                                            size: 13,
                                            color: AppColors.accent),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            displayUrl,
                                            style: const TextStyle(
                                              color: AppColors.accent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Point your camera at the QR code\nto open the link instantly.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondary
                                    : Colors.grey.shade500,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),
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

/// Accent-coloured L-shaped corner marker for the QR scan frame.
class _ScanCorner extends StatelessWidget {
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  const _ScanCorner({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    const size = 22.0;
    const thickness = 3.0;
    const radius = 6.0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
          color: AppColors.accent,
          thickness: thickness,
          radius: radius,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;
  final Color color;
  final double thickness;
  final double radius;

  _CornerPainter({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.color,
    required this.thickness,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    if (topLeft) {
      path.moveTo(0, h);
      path.lineTo(0, radius);
      path.arcToPoint(Offset(radius, 0),
          radius: Radius.circular(radius), clockwise: true);
      path.lineTo(w, 0);
    } else if (topRight) {
      path.moveTo(0, 0);
      path.lineTo(w - radius, 0);
      path.arcToPoint(Offset(w, radius),
          radius: Radius.circular(radius), clockwise: true);
      path.lineTo(w, h);
    } else if (bottomLeft) {
      path.moveTo(w, h);
      path.lineTo(radius, h);
      path.arcToPoint(Offset(0, h - radius),
          radius: Radius.circular(radius), clockwise: true);
      path.lineTo(0, 0);
    } else if (bottomRight) {
      path.moveTo(w, 0);
      path.lineTo(w, h - radius);
      path.arcToPoint(Offset(w - radius, h),
          radius: Radius.circular(radius), clockwise: true);
      path.lineTo(0, h);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) => false;
}
