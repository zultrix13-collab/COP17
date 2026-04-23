import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  void _decide() {
    final session = supabase.auth.currentSession;
    if (session == null) {
      context.go('/onboarding/email');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🌿', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text('COP17', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text('Улаанбаатар 2026', style: TextStyle(color: Color(0xFF16A34A))),
          ],
        ),
      ),
    );
  }
}
