import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AppCustomBar extends StatelessWidget {
  final String title;
  final String? accentTitle;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool showDrawerButton;
  final EdgeInsets padding;

  const AppCustomBar({
    super.key,
    required this.title,
    this.accentTitle,
    this.actions,
    this.bottom,
    this.showDrawerButton = true,
    this.padding = const EdgeInsets.fromLTRB(16, 56, 16, 10),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTitle(context, isDark),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actions != null) ...[
                    ...actions!,
                    if (showDrawerButton) const SizedBox(width: 8),
                  ],
                  if (showDrawerButton) _buildDrawerButton(context, isDark),
                ],
              ),
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: 14),
            bottom!,
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isDark) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimary : Colors.black87,
                ),
          ),
          if (accentTitle != null) ...[
          TextSpan(
            text: accentTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
          ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerButton(BuildContext context, bool isDark) {
    return Builder(
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
    );
  }
}
