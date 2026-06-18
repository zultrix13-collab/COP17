import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _ctrl = TextEditingController();
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _ctrl.text.trim();
    // Reviewer demo bypass: only active when REVIEW_EMAIL/CODE were injected at build time.
    if (reviewEmail.isNotEmpty && reviewCode.isNotEmpty &&
        widget.email.toLowerCase() == reviewEmail && code == reviewCode) {
      reviewSession = true;
      context.go('/home');
      return;
    }
    setState(() { _busy = true; _err = null; });
    try {
      await ref.read(authRepositoryProvider).verifyOtp(
            email: widget.email,
            token: code,
          );
      if (mounted) context.go('/onboarding/permission');
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.otpTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.otpSentTo(widget.email)),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '______'),
              maxLength: 6,
              keyboardType: TextInputType.number,
            ),
            FilledButton(
              onPressed: _busy ? null : _verify,
              child: Text(_busy ? '…' : l10n.verify),
            ),
            if (_err != null) ...[
              const SizedBox(height: 8),
              Text(_err!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}
