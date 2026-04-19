import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Bottom navigation: 4 icons + center purple AI sparkle FAB.
/// Active state: icon in brandPurpleDark + coral underline bar.
class EditorialBottomNav extends StatelessWidget {
  const EditorialBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabTap,
    required this.onAskAiTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTabTap;
  final VoidCallback onAskAiTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: AppColors.lightBorder.withOpacity(0.6)),
          ),
        ),
        child: SizedBox(
          height: 74,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                active: currentIndex == 0,
                onTap: () => onTabTap(0),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                active: currentIndex == 1,
                onTap: () => onTabTap(1),
              ),
              _AiFab(onTap: onAskAiTap),
              _NavItem(
                icon: Icons.bookmark_outline_rounded,
                active: currentIndex == 2,
                onTap: () => onTabTap(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                active: currentIndex == 3,
                onTap: () => onTabTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: active ? AppColors.brandPurpleDark : AppColors.lightTextTertiary,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: active ? 18 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.brandCoral,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiFab extends StatelessWidget {
  const _AiFab({required this.onTap});
  final VoidCallback onTap;

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8847BB),
      Color(0xFF4E2780),
      Color(0xFF2E1650),
    ],
    stops: [0.0, 0.6, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -14),
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _gradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandPurple.withOpacity(0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: AppColors.brandPurple.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(child: _AiSparkle(size: 24)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ask AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandPurpleDark,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gemini-style dual sparkle — two 4-point stars, different sizes.
/// Crisp path-based rendering so it scales on any device density.
class _AiSparkle extends StatelessWidget {
  const _AiSparkle({this.size = 24, this.color = Colors.white});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparklePainter(color: color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // Big sparkle centered slightly off-center
    _drawStar(
      canvas,
      paint,
      center: Offset(size.width * 0.58, size.height * 0.42),
      outer: size.width * 0.33,
      curve: 0.45,
    );
    // Small accent sparkle bottom-left
    _drawStar(
      canvas,
      paint,
      center: Offset(size.width * 0.30, size.height * 0.72),
      outer: size.width * 0.16,
      curve: 0.45,
    );
  }

  /// Draws a 4-point star via cubic curves that "pinch in" between points —
  /// the recognizable AI sparkle shape (Gemini / Bard / ChatGPT family).
  void _drawStar(
    Canvas canvas,
    Paint paint, {
    required Offset center,
    required double outer,
    required double curve,
  }) {
    final path = Path();
    // 4 points: top, right, bottom, left
    final top = Offset(center.dx, center.dy - outer);
    final right = Offset(center.dx + outer, center.dy);
    final bottom = Offset(center.dx, center.dy + outer);
    final left = Offset(center.dx - outer, center.dy);

    final control = outer * curve;

    path.moveTo(top.dx, top.dy);
    // top -> right with a pinch-in control point near the center
    path.quadraticBezierTo(center.dx + control, center.dy - control, right.dx, right.dy);
    path.quadraticBezierTo(center.dx + control, center.dy + control, bottom.dx, bottom.dy);
    path.quadraticBezierTo(center.dx - control, center.dy + control, left.dx, left.dy);
    path.quadraticBezierTo(center.dx - control, center.dy - control, top.dx, top.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => oldDelegate.color != color;
}
