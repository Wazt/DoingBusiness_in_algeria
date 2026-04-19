import 'package:doingbusiness/data/models/article_model.dart';
import 'package:flutter/material.dart';

/// ════════════════════════════════════════════════════════════════════════
///  SourceBadge — shows "via LinkedIn" on mirrored articles
/// ════════════════════════════════════════════════════════════════════════
///  Renders nothing for editorial articles (default case, no visual noise).
///  For LinkedIn articles, a small pill with LinkedIn's brand color.
/// ════════════════════════════════════════════════════════════════════════

class SourceBadge extends StatelessWidget {
  final ArticleSource source;

  /// Compact mode = just the icon (for tight spaces like grid thumbnails).
  final bool compact;

  /// Use light-on-dark styling (for use on dark/image overlays).
  final bool onDark;

  const SourceBadge({
    super.key,
    required this.source,
    this.compact = false,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (source == ArticleSource.editorial) {
      return const SizedBox.shrink();
    }

    const linkedinBlue = Color(0xFF0A66C2);
    final bgColor = onDark ? Colors.white : linkedinBlue;
    final fgColor = onDark ? linkedinBlue : Colors.white;

    if (compact) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          'in',
          style: TextStyle(
            color: fgColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            height: 1,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'in',
            style: TextStyle(
              color: fgColor,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              height: 1,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LinkedIn',
            style: TextStyle(
              color: fgColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
