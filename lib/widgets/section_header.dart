import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A section header row with a title and optional "View All" action.
///
/// Matches the La Rose design: 18sp bold title, 14sp semibold primary link.
class SectionHeader extends StatelessWidget {
  /// Section title text.
  final String title;

  /// Callback when "View All" is tapped, or null to hide it.
  final VoidCallback? onViewAll;

  /// Creates a [SectionHeader] with the given [title] and optional [onViewAll].
  const SectionHeader({super.key, required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.sectionHeader(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimary,
            ),
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('View All', style: AppTheme.viewAllLink()),
            ),
          ),
      ],
    );
  }
}
