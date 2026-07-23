import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SplashTexturedScreen extends StatefulWidget {
  final Widget? nextScreen;

  const SplashTexturedScreen({super.key, this.nextScreen});

  @override
  State<SplashTexturedScreen> createState() => _SplashTexturedScreenState();
}

class _SplashTexturedScreenState extends State<SplashTexturedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _textFade;
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
    );
    _footerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
    );

    _animController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (widget.nextScreen != null) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => widget.nextScreen!,
              transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        } else {
          Navigator.of(context).pushReplacementNamed('/welcome');
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLowest,
      body: Stack(
        children: [
          // Decorative background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _DecorativePatternPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                // Logo
                SlideTransition(
                  position: _logoSlide,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 128,
                        height: 128,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Branding
                FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      Text(
                        'Your Portion',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.onSurface,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Faith \u2022 Purpose \u2022 Stewardship',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Footer
                FadeTransition(
                  opacity: _footerFade,
                  child: Column(
                    children: [
                      _PulseRing(),
                      const SizedBox(height: 16),
                      Text(
                        'Growing Faith, Building Communities.',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.outline,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryContainer.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    final random = Random(42);
    for (double y = 100; y < size.height; y += 200) {
      path.moveTo(-50, y);
      for (double x = 0; x <= size.width + 50; x += 50) {
        final dy = random.nextDouble() * 40 - 20;
        path.lineTo(x, y + dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PulseRing extends StatefulWidget {
  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnim = Tween<double>(begin: 0.1, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryContainer.withValues(alpha: _opacityAnim.value),
                  ),
                ),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryContainer),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
