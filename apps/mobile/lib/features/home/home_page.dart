import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../profile/profile_repository.dart';
import '../programme/programme_repository.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);
    final today = DateTime.now();
    final sessionsAsync = ref.watch(
      sessionsProvider(DateTime(today.year, today.month, today.day)),
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(profileStreamProvider);
            ref.invalidate(sessionsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              profileAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (p) => _ZoneHeader(
                  name: p?.name.isNotEmpty == true ? p!.name : (p?.email ?? ''),
                  tier: p?.tier ?? 'green',
                  onQr: () => context.push('/profile/digital-id'),
                ),
              ),
              const SizedBox(height: 10),
              const _WidgetsRow(),
              const SizedBox(height: 10),
              sessionsAsync.when(
                loading: () => const _Card(child: Center(child: Padding(
                  padding: EdgeInsets.all(12), child: CircularProgressIndicator(),
                ))),
                error: (e, _) => _Card(child: Padding(
                  padding: const EdgeInsets.all(12), child: Text('$e'),
                )),
                data: (sessions) => _TodaySessions(sessions: sessions),
              ),
              const SizedBox(height: 10),
              _QuickLinks(
                onMap: () => context.go('/map'),
                onServices: () => context.go('/services'),
                onHelp: () => context.push('/help'),
                onAi: () => context.push('/information/chatbot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneHeader extends StatelessWidget {
  final String name;
  final String tier;
  final VoidCallback onQr;
  const _ZoneHeader({required this.name, required this.tier, required this.onQr});

  @override
  Widget build(BuildContext context) {
    final (color, emoji, label) = switch (tier) {
      'vip' => (const Color(0xFF7C3AED), '💎', 'VIP Guest'),
      'blue' => (const Color(0xFF1A6EF5), '🔵', 'Blue Zone'),
      'exhibitor' => (const Color(0xFFB45309), '🏢', 'Exhibitor'),
      'press' => (const Color(0xFF0369A1), '📰', 'Press'),
      _ => (const Color(0xFF16A34A), '🟢', 'Green Zone'),
    };
    return _Card(
      color: color.withOpacity(0.08),
      border: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(name, style: TextStyle(fontSize: 11, color: color)),
            ]),
          ),
          InkWell(
            onTap: onQr,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(border: Border.all(color: color), borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.qr_code_2, size: 18),
            ),
          ),
        ]),
      ),
    );
  }
}

class _WidgetsRow extends StatelessWidget {
  const _WidgetsRow();
  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      Expanded(child: _StatTile(
        title: '🌿 CO₂ хэмнэлт',
        value: '12.4 кг',
        sub: '340 / 500 оноо',
        color: Color(0xFF16A34A),
      )),
      SizedBox(width: 8),
      Expanded(child: _StatTile(
        title: '🌤 Улаанбаатар',
        value: '+8°C',
        sub: 'Цэлмэг · 3 м/с',
        color: Color(0xFF0369A1),
      )),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final Color color;
  const _StatTile({required this.title, required this.value, required this.sub, required this.color});
  @override
  Widget build(BuildContext context) {
    return _Card(
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
        ]),
      ),
    );
  }
}

class _TodaySessions extends StatelessWidget {
  final List<SessionItem> sessions;
  const _TodaySessions({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📅 Өнөөдрийн хөтөлбөр',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          if (sessions.isEmpty)
            const Text('Өнөөдөр session байхгүй',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
          for (final s in sessions.take(3))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.titleMn, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  Text('${fmt.format(s.startsAt)} · ${s.hall}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
                ])),
                Text(fmt.format(s.startsAt),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1A6EF5))),
              ]),
            ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => GoRouter.of(context).go('/programme'),
            child: const Text('Бүх хөтөлбөр →',
                style: TextStyle(fontSize: 12, color: Color(0xFF1A6EF5))),
          ),
        ]),
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  final VoidCallback onMap;
  final VoidCallback onServices;
  final VoidCallback onHelp;
  final VoidCallback onAi;
  const _QuickLinks({
    required this.onMap,
    required this.onServices,
    required this.onHelp,
    required this.onAi,
  });
  @override
  Widget build(BuildContext context) {
    Widget btn(IconData i, String label, Color c, VoidCallback f) => OutlinedButton.icon(
          onPressed: f,
          icon: Icon(i, size: 16, color: c),
          label: Text(label, style: TextStyle(color: c, fontSize: 11)),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
        );
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: [
        btn(Icons.map_outlined, 'Газар', const Color(0xFF0EA5E9), onMap),
        btn(Icons.shopping_bag_outlined, 'Wallet', const Color(0xFF16A34A), onServices),
        btn(Icons.smart_toy_outlined, 'AI', const Color(0xFF111111), onAi),
        btn(Icons.sos_outlined, 'SOS', const Color(0xFFDC2626), onHelp),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? border;
  const _Card({required this.child, this.color, this.border});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        border: Border.all(color: border ?? const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
