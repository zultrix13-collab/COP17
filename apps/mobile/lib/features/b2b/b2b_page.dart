import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'b2b_repository.dart';

class B2BPage extends ConsumerStatefulWidget {
  const B2BPage({super.key});
  @override
  ConsumerState<B2BPage> createState() => _B2BPageState();
}

class _B2BPageState extends ConsumerState<B2BPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(exhibitorsProvider(_search));
    return Scaffold(
      appBar: AppBar(
        title: const Text('B2B Exhibitors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note_outlined),
            tooltip: 'Миний Meetings',
            onPressed: () => context.push('/b2b/meetings'),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Компани хайх',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        Expanded(
          child: list.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('Exhibitor алга'));
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(exhibitorsProvider),
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final e = items[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(e.company.characters.first.toUpperCase())),
                      title: Text(e.company,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text([e.sector, e.country, e.booth]
                          .where((x) => x != null && x.isNotEmpty).join(' · ')),
                      trailing: FilledButton.tonal(
                        onPressed: () => context.push('/b2b/${e.userId}'),
                        child: const Text('Meeting →'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class MeetingRequestPage extends ConsumerStatefulWidget {
  final String exhibitorId;
  const MeetingRequestPage({super.key, required this.exhibitorId});
  @override
  ConsumerState<MeetingRequestPage> createState() => _MeetingRequestPageState();
}

class _MeetingRequestPageState extends ConsumerState<MeetingRequestPage> {
  final _purpose = TextEditingController();
  DateTime? _slot;
  bool _busy = false;

  List<DateTime> _slots() {
    // Next 3 days, 10:00 & 14:00 slots each.
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    return [
      for (var d = 1; d <= 3; d++)
        for (final hour in [10, 14])
          base.add(Duration(days: d, hours: hour)),
    ];
  }

  Future<void> _submit() async {
    if (_slot == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(b2bRepositoryProvider).requestMeeting(
            exhibitorId: widget.exhibitorId,
            start: _slot!,
            end: _slot!.add(const Duration(minutes: 30)),
            purpose: _purpose.text.trim().isEmpty ? null : _purpose.text.trim(),
          );
      ref.invalidate(myMeetingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Хүсэлт илгээгдлээ — admin батална')),
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
    final fmt = DateFormat('MMM d · HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Meeting хүсэлт')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Цаг сонгох'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in _slots())
              ChoiceChip(
                label: Text(fmt.format(s)),
                selected: _slot == s,
                onSelected: (_) => setState(() => _slot = s),
              ),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _purpose,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Зорилго',
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: _busy || _slot == null ? null : _submit,
            child: Text(_busy ? '…' : 'Хүсэлт илгээх'),
          ),
        ]),
      ),
    );
  }
}

class MyMeetingsPage extends ConsumerWidget {
  const MyMeetingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetings = ref.watch(myMeetingsProvider);
    final fmt = DateFormat('MMM d · HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Миний Meetings')),
      body: meetings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Meeting алга', style: TextStyle(color: Color(0xFF888888))));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final m = list[i];
              final color = switch (m.status) {
                'approved' => const Color(0xFF16A34A),
                'rejected' => const Color(0xFFDC2626),
                'cancelled' => const Color(0xFF888888),
                _ => const Color(0xFFB45309),
              };
              return ListTile(
                title: Text(m.purpose ?? 'Meeting',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${fmt.format(m.startsAt)} – ${DateFormat('HH:mm').format(m.endsAt)}'),
                trailing: Chip(
                  label: Text(m.status, style: TextStyle(color: color, fontSize: 11)),
                  backgroundColor: color.withOpacity(0.1),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
