import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/supabase_client.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});
  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Small delay so the brand is visible for a beat on cold start.
    Future<void>.delayed(const Duration(milliseconds: 700), _decide);
  }

  void _decide() {
    if (!mounted) return;
    final session = supabase.auth.currentSession;
    context.go(session == null ? '/onboarding/email' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: copBrandGradient),
        width: double.infinity,
        child: SafeArea(
          child: Stack(
            children: [
              // Subtle steppe-dune motif in the background.
              Positioned.fill(
                child: CustomPaint(painter: _DunePainter()),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(CopRadius.xl),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/brand/siop-logo.png',
                        width: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'SIOP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Together for Change: Science, Compassion,\nand Hope for Every Child',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE8F7FA),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ulaanbaatar · Mongolia',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'June 25–28, 2026',
                      style: TextStyle(
                        color: Color(0xFFE0F7FA),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '18th SIOP Asia Congress · Corporate Convention Center Hotel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DunePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.04);
    final path = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.72,
          size.width * 0.55, size.height * 0.82)
      ..quadraticBezierTo(
          size.width * 0.8, size.height * 0.90, size.width, size.height * 0.80)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()..color = Colors.white.withValues(alpha: 0.06);
    final path2 = Path()
      ..moveTo(0, size.height * 0.90)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.85,
          size.width * 0.7, size.height * 0.93)
      ..quadraticBezierTo(
          size.width * 0.9, size.height * 0.98, size.width, size.height * 0.92)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_) => false;
}
