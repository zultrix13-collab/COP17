import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';

class EmailPage extends ConsumerStatefulWidget {
  const EmailPage({super.key});
  @override
  ConsumerState<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends ConsumerState<EmailPage> {
  final _ctrl = TextEditingController();
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _ctrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _err = AppL10n.of(context)!.errEmailNotRegistered);
      return;
    }
    // Reviewer demo account: its mailbox can't receive a code, so skip the
    // network request and go straight to the code screen.
    if (reviewEmail.isNotEmpty && email.toLowerCase() == reviewEmail) {
      context.go('/onboarding/otp', extra: email);
      return;
    }
    setState(() { _busy = true; _err = null; });
    try {
      await ref.read(authRepositoryProvider).requestOtp(email);
      if (mounted) context.go('/onboarding/otp', extra: email);
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
      appBar: AppBar(title: Text(l10n.emailTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.emailPrompt),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
                hintText: 'you@example.mn',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _send,
              child: Text(_busy ? '…' : l10n.sendCode),
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
