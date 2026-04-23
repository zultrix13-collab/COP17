import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          const SnackBar(content: Text('Үнэлгээ илгээгдлээ · +10 CO₂ оноо')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Үнэлгээ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Санал бодлоо хуваалцана уу'),
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Нэмэлт сэтгэгдэл (заавал биш)',
              ),
            ),
            const SizedBox(height: 8),
            const Text('Нэрсгүй илгээгдэнэ',
                style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
            const Spacer(),
            FilledButton(
              onPressed: _busy || _rating == 0 ? null : _submit,
              child: Text(_busy ? '…' : 'Илгээх'),
            ),
          ],
        ),
      ),
    );
  }
}
