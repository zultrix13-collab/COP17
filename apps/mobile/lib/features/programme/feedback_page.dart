import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/error_view.dart';
import '../../l10n/app_localizations.dart';
import 'programme_repository.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  final String sessionId;
  const FeedbackPage({super.key, required this.sessionId});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  int _rating = 0;
  final _ctrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) return;
    setState(() => _busy = true);
    try {
      await ref.read(programmeRepositoryProvider).submitFeedback(
            sessionId: widget.sessionId,
            rating: _rating,
            comment: _ctrl.text.trim().isEmpty ? null : _ctrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context)!.feedbackSent)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorView.friendlyMessage(AppL10n.of(context)!, e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedbackTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.shareThoughts),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final active = i < _rating;
                return IconButton(
                  iconSize: 36,
                  icon: Icon(active ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF59E0B)),
                  onPressed: () => setState(() => _rating = i + 1),
                );
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.extraComment,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.sentAnonymously,
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy || _rating == 0 ? null : _submit,
              child: Text(_busy ? '…' : l10n.send),
            ),
          ],
        ),
      ),
    );
  }
}
