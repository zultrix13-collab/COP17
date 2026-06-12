import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/error_view.dart';
import 'info_repository.dart';

class InformationPage extends ConsumerWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anns = ref.watch(announcementsProvider);
    final faq = ref.watch(faqProvider);
    final flights = ref.watch(flightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мэдээлэл'),
        actions: [
          IconButton(
            tooltip: 'AI туслах',
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: () => context.push('/information/chatbot'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(announcementsProvider);
          ref.invalidate(faqProvider);
          ref.invalidate(flightsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _Section(title: '📢 Мэдэгдлүүд', child: _AnnouncementsCard(anns)),
            const SizedBox(height: 12),
            _Section(title: '✈ Нислэгийн мэдээлэл', child: _FlightsCard(flights)),
            const SizedBox(height: 12),
            _Section(title: '❓ FAQ', child: _FaqCard(faq)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 6),
      child,
    ]);
  }
}

class _AnnouncementsCard extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> anns;
  const _AnnouncementsCard(this.anns);
  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d · HH:mm');
    return anns.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator())),
      error: (e, _) => ErrorView(error: e, compact: true),
      data: (list) {
        if (list.isEmpty) return const _Empty(text: 'Одоогоор мэдэгдэл алга');
        return Column(children: [
          for (final a in list.take(5))
            _Row(
              color: switch (a['severity']) {
                'critical' => const Color(0xFFDC2626),
                'warn' => const Color(0xFFB45309),
                _ => const Color(0xFF0EA5E9),
              },
              title: a['title_mn'] as String,
              subtitle: a['published_at'] == null
                  ? (a['body_mn'] as String?) ?? ''
                  : '${fmt.format(DateTime.parse(a['published_at']))} · ${a['body_mn'] ?? ''}',
            ),
        ]);
      },
    );
  }
}

class _FlightsCard extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> flights;
  const _FlightsCard(this.flights);
  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d · HH:mm');
    return flights.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => ErrorView(error: e, compact: true),
      data: (list) {
        if (list.isEmpty) return const _Empty(text: 'Нислэгийн мэдээлэл алга');
        return Column(children: [
          for (final f in list.take(8))
            _Row(
              color: switch (f['status']) {
                'delayed' => const Color(0xFFB45309),
                'arrived' => const Color(0xFF16A34A),
                _ => const Color(0xFF888888),
              },
              title: '${f['flight_no']} · ${f['origin'] ?? ''}',
              subtitle: f['scheduled'] == null
                  ? (f['status'] as String? ?? '—')
                  : '${fmt.format(DateTime.parse(f['scheduled']))} · ${f['status'] ?? ''}',
            ),
        ]);
      },
    );
  }
}

class _FaqCard extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> faq;
  const _FaqCard(this.faq);
  @override
  Widget build(BuildContext context) {
    return faq.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => ErrorView(error: e, compact: true),
      data: (list) {
        if (list.isEmpty) return const _Empty(text: 'FAQ алга');
        return Column(children: [
          for (final f in list.take(8))
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(f['question_mn'] as String,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 12),
                  child: Text(f['answer_mn'] as String,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
                ),
              ],
            ),
        ]);
      },
    );
  }
}

class _Row extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  const _Row({required this.color, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
          ]),
        ),
      ]),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text, style: const TextStyle(color: Color(0xFF888888))),
      );
}
