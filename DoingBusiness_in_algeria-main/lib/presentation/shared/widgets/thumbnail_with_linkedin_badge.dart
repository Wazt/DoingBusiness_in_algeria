import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Rounded thumbnail with an optional small blue "in" LinkedIn badge overlaid
/// at the bottom-right corner, for articles mirrored from LinkedIn.
class ThumbnailWithLinkedInBadge extends StatelessWidget {
  const ThumbnailWithLinkedInBadge({
    super.key,
    required this.imageUrl,
    required this.size,
    this.showLinkedInBadge = false,
    this.borderRadius = 8,
    this.fallbackGradientStart = const Color(0xFF8847BB),
    this.fallbackGradientEnd = const Color(0xFF4E2780),
  });

  final String imageUrl;
  final double size;
  final bool showLinkedInBadge;
  final double borderRadius;
  final Color fallbackGradientStart;
  final Color fallbackGradientEnd;

  static const _linkedinBlue = Color(0xFF0A66C2);

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: imageUrl.isEmpty
                ? _FallbackGradient(
                    start: fallbackGradientStart,
                    end: fallbackGradientEnd,
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    placeholder: (_, __) => _FallbackGradient(
                      start: fallbackGradientStart,
                      end: fallbackGradientEnd,
                    ),
                    errorWidget: (_, __, ___) => _FallbackGradient(
                      start: fallbackGradientStart,
                      end: fallbackGradientEnd,
                    ),
                  ),
          ),
          if (showLinkedInBadge)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _linkedinBlue,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: scaffoldColor, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x330A66C2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'in',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FallbackGradient extends StatelessWidget {
  const _FallbackGradient({required this.start, required this.end});
  final Color start;
  final Color end;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [start, end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
