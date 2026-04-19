import 'package:doingbusiness/data/models/article_model.dart';
import 'package:flutter/material.dart';

/// Small uppercase tag shown above article titles in the feed.
/// - `ArticleSource.editorial` -> coral "GT EDITORIAL"
/// - `ArticleSource.linkedin`  -> blue "in LINKEDIN · VIA GT ALGERIA"
class SourceTag extends StatelessWidget {
  const SourceTag({super.key, required this.source});
  final ArticleSource source;

  static const _linkedinBlue = Color(0xFF0A66C2);
  static const _gtCoral = Color(0xFFE83A4E);

  @override
  Widget build(BuildContext context) {
    if (source == ArticleSource.linkedin) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _LinkedInInMark(),
          SizedBox(width: 6),
          Text(
            'LINKEDIN · VIA GT ALGERIA',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: _linkedinBlue,
            ),
          ),
        ],
      );
    }
    return const Text(
      'GT EDITORIAL',
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: _gtCoral,
      ),
    );
  }
}

class _LinkedInInMark extends StatelessWidget {
  const _LinkedInInMark();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2),
        borderRadius: BorderRadius.circular(2.5),
      ),
      child: const Text(
        'in',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}
