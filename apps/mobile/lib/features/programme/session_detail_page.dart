import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/error_view.dart';
import 'programme_repository.dart';

class SessionDetailPage extends ConsumerWidget {
  final String sessionId;
  const SessionDetailPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionDetailProvider(sessionId));
    final attendance = ref.watch(myAttendanceProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Session дэлгэрэнгүй')),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: ErrorView(error: e)),
        data: (s) {
          if (s == null) return const Center(child: Text('Олдсонгүй'));
          final fmt = DateFormat('MMM d · HH:mm');
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(s.titleMn, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${fmt.format(s.startsAt)} – ${DateFormat('HH:mm').format(s.endsAt)}',
                  style: const TextStyle(color: Color(0xFF888888))),
              Text('Hall: ${s.hall}', style: const TextStyle(color: Color(0xFF888888))),
              const SizedBox(height: 12),
              Wrap(spacing: 6, children: [
                for (final t in s.accessTiers)
                  Chip(label: Text(t), labelStyle: const TextStyle(fontSize: 10)),
              ]),
              const SizedBox(height: 12),
              if (s.descriptionMn != null) Text(s.descriptionMn!),
              const SizedBox(height: 20),
              attendance.when(
                data: (status) => _ActionButton(
                  sessionId: s.id,
                  currentStatus: status,
                  onChanged: () {
                    ref.invalidate(myAttendanceProvider(s.id));
                    ref.invalidate(myAgendaProvider);
                  },
                  onGoFeedback: () => context.push('/programme/${s.id}/feedback'),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends ConsumerStatefulWidget {
  final String sessionId;
  final AttendanceStatus? currentStatus;
  final VoidCallback onChanged;
  final VoidCallback onGoFeedback;
  const _ActionButton({
    required this.sessionId,
    required this.currentStatus,
    required this.onChanged,
    required this.onGoFeedback,
  });

  @override
  ConsumerState<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends ConsumerState<_ActionButton> {
  bool _busy = false;

  Future<void> _toggle() async {
    setState(() => _busy = true);
    try {
      final repo = ref.read(programmeRepositoryProvider);
      if (widget.currentStatus == null) {
        final result = await repo.markGoing(widget.sessionId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result == AttendanceStatus.waitlist
              ? 'Суудал дүүрсэн — хүлээлтэд нэмэгдлээ'
              : 'Going ✓'),
        ));
      } else {
        await repo.cancelAttendance(widget.sessionId);
      }
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentStatus == AttendanceStatus.attended) {
      return Column(children: [
        const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 40),
        const Text('Та ирсэн'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: widget.onGoFeedback,
          icon: const Icon(Icons.star_outline),
          label: const Text('Үнэлгээ өгөх'),
        ),
      ]);
    }
    final isGoing = widget.currentStatus != null;
    return Column(children: [
      FilledButton(
        onPressed: _busy ? null : _toggle,
        style: FilledButton.styleFrom(
          backgroundColor: isGoing ? const Color(0xFFDC2626) : const Color(0xFF111111),
        ),
        child: Text(_busy
            ? '…'
            : isGoing
                ? 'Цуцлах'
                : 'Going — бүртгүүлэх ✓'),
      ),
    ]);
  }
}
