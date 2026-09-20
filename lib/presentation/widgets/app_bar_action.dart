import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// The square icon button used for [AppCustomBar] actions.
///
/// Matches the drawer button the bar draws on the leading side — same 38pt box,
/// same 11pt radius and border — so a row of actions reads as one control strip.
class AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  /// Paints the icon, border and fill in the accent colour instead of the
  /// neutral surface treatment. For actions worth drawing the eye to.
  final bool highlighted;

  /// Optional gradient fill, which takes precedence over [highlighted].
  final Gradient? gradient;

  const AppBarAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.highlighted = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color background;
    final Color border;
    final Color foreground;

    if (gradient != null) {
      background = Colors.transparent;
      border = Colors.transparent;
      foreground = Colors.white;
    } else if (highlighted) {
      background = AppColors.accent.withValues(alpha: isDark ? 0.18 : 0.1);
      border = AppColors.accent.withValues(alpha: 0.3);
      foreground = AppColors.accent;
    } else {
      background = isDark ? AppColors.darkCard : Colors.grey.shade100;
      border = isDark ? AppColors.darkCardBorder : Colors.grey.shade200;
      foreground = isDark ? AppColors.textSecondary : Colors.grey.shade700;
    }

    Widget button = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: gradient == null ? background : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onTap,
          child: Icon(icon, size: 20, color: foreground),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
