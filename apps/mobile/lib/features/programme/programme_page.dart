import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'programme_repository.dart';

class ProgrammePage extends ConsumerWidget {
  const ProgrammePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider(null));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Хөтөлбөр'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => context.push('/programme/agenda'),
            tooltip: 'My Agenda',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/scanner'),
            tooltip: 'Check-in scanner',
          ),
        ],
      ),
      body: sessions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Session нэмээгүй байна'));
          }
          final byDay = <String, List<SessionItem>>{};
          final dateKey = DateFormat('yyyy-MM-dd');
          for (final s in list) {
            byDay.putIfAbsent(dateKey.format(s.startsAt), () => []).add(s);
          }
          final dayHeader = DateFormat('MMM d (EEE)', 'en');
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(sessionsProvider),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final entry in byDay.entries) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      dayHeader.format(DateTime.parse(entry.key)),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF888888)),
                    ),
                  ),
                  for (final s in entry.value) _SessionTile(session: s),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  final SessionItem session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendance = ref.watch(myAttendanceProvider(session.id));
    final fmt = DateFormat('HH:mm');
    return InkWell(
      onTap: () => context.push('/programme/${session.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    '${fmt.format(session.startsAt)}–${fmt.format(session.endsAt)} · ${session.hall}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(session.titleMn,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ])),
          attendance.when(
            data: (s) => _StatusBadge(status: s, capacity: session.capacity),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AttendanceStatus? status;
  final int capacity;
  const _StatusBadge({required this.status, required this.capacity});
  @override
  Widget build(BuildContext context) {
    if (status == AttendanceStatus.going) {
      return const _Pill(text: 'Going ✓', color: Color(0xFF16A34A));
    }
    if (status == AttendanceStatus.waitlist) {
      return const _Pill(text: 'Waitlist', color: Color(0xFFB45309));
    }
    if (status == AttendanceStatus.attended) {
      return const _Pill(text: 'Attended', color: Color(0xFF0369A1));
    }
    return _Pill(
        text: capacity > 0 ? '$capacity' : '—', color: const Color(0xFF888888));
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
