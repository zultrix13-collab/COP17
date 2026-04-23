import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              profileAsync.when(
                loading: () => const SizedBox(height: 140),
                error: (_, __) => const SizedBox.shrink(),
                data: (p) => _BrandHeader(
                  name: p?.name.isNotEmpty == true ? p!.name : (p?.email ?? ''),
                  tier: p?.tier ?? 'green',
                  onQr: () => context.push('/profile/digital-id'),
                ),
              ),
              const SizedBox(height: 14),
              const _WidgetsRow(),
              const SizedBox(height: 14),
              sessionsAsync.when(
                loading: () => const _Card(
                  child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                ),
                error: (e, _) => _Card(
                  child: Padding(padding: const EdgeInsets.all(16), child: Text('$e')),
                ),
                data: (sessions) => _TodaySessions(sessions: sessions),
              ),
              const SizedBox(height: 14),
              _QuickLinks(
                onMap:      () => context.go('/map'),
                onServices: () => context.go('/services'),
                onHelp:     () => context.push('/help'),
                onAi:       () => context.push('/information/chatbot'),
              ),
              const SizedBox(height: 14),
              const _SponsorCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Brand header ──────────────────────────────────────────────
class _BrandHeader extends StatelessWidget {
  final String name;
  final String tier;
  final VoidCallback onQr;
  const _BrandHeader({required this.name, required this.tier, required this.onQr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: copBrandGradient,
        borderRadius: BorderRadius.circular(CopRadius.xl),
        boxShadow: [
          BoxShadow(
            color: CopColors.primary.withValues(alpha: 0.25),
            blurRadius: 24, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Image.asset(
              'assets/brand/cop17-logo.png',
              height: 28,
              color: Colors.white,
              colorBlendMode: BlendMode.srcIn,
            ),
            const Spacer(),
            InkWell(
              onTap: onQr,
              borderRadius: BorderRadius.circular(CopRadius.md),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(CopRadius.md),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.qr_code_2, color: Colors.white, size: 22),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Text(tierEmoji(tier), style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(CopRadius.pill),
              ),
              child: Text(
                tierLabel(tier),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Aug 17–28, 2026 · Ulaanbaatar',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78), fontSize: 12, fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Side-by-side widgets ──────────────────────────────────────
class _WidgetsRow extends StatelessWidget {
  const _WidgetsRow();
  @override
  Widget build(BuildContext context) => Row(children: const [
    Expanded(child: _StatTile(icon: '🌿', label: 'CO₂ хэмнэлт',
      value: '12.4 kg', sub: '340 / 500 оноо', tint: CopColors.success)),
    SizedBox(width: 10),
    Expanded(child: _StatTile(icon: '🌤', label: 'Улаанбаатар',
      value: '+8°C', sub: 'Цэлмэг · 3 м/с', tint: CopColors.sky)),
  ]);
}

class _StatTile extends StatelessWidget {
  final String icon, label, value, sub;
  final Color tint;
  const _StatTile({
    required this.icon, required this.label, required this.value, required this.sub, required this.tint,
  });
  @override
  Widget build(BuildContext context) => _Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: CopColors.inkMuted, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800, color: tint, letterSpacing: -0.5,
        )),
        Text(sub, style: const TextStyle(fontSize: 11, color: CopColors.inkMuted)),
      ]),
    ),
  );
}

// ─── Today's sessions ─────────────────────────────────────────
class _TodaySessions extends StatelessWidget {
  final List<SessionItem> sessions;
  const _TodaySessions({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    final preview = sessions.take(3).toList();
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.event, size: 18, color: CopColors.primary),
            SizedBox(width: 6),
            Text('Өнөөдрийн хөтөлбөр', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
          const SizedBox(height: 10),
          if (preview.isEmpty)
            const Text('Өнөөдөр session байхгүй',
                style: TextStyle(fontSize: 12, color: CopColors.inkMuted)),
          for (int i = 0; i < preview.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: CopColors.sky.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(CopRadius.sm),
                  ),
                  child: Center(
                    child: Text(fmt.format(preview[i].startsAt),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                          color: CopColors.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(preview[i].titleMn,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(preview[i].hall,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: CopColors.inkMuted)),
                ])),
              ]),
            ),
            if (i < preview.length - 1) const Divider(height: 1),
          ],
          const SizedBox(height: 10),
          InkWell(
            onTap: () => GoRouter.of(context).go('/programme'),
            child: Row(children: const [
              Text('Бүх хөтөлбөр',
                  style: TextStyle(color: CopColors.sky, fontWeight: FontWeight.w700, fontSize: 13)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 14, color: CopColors.sky),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Quick links ──────────────────────────────────────────────
class _QuickLinks extends StatelessWidget {
  final VoidCallback onMap, onServices, onHelp, onAi;
  const _QuickLinks({
    required this.onMap, required this.onServices, required this.onHelp, required this.onAi,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, Color, VoidCallback)>[
      (Icons.map_outlined,                    'Газар',     CopColors.sky,      onMap),
      (Icons.account_balance_wallet_outlined, 'Wallet',    CopColors.primary,  onServices),
      (Icons.auto_awesome,                    'AI туслах', CopColors.tierVip,  onAi),
      (Icons.sos_outlined,                    'SOS',       CopColors.danger,   onHelp),
    ];
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.95,
      children: [
        for (final it in items)
          InkWell(
            onTap: it.$4,
            borderRadius: BorderRadius.circular(CopRadius.lg),
            child: Container(
              decoration: BoxDecoration(
                color: it.$3.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(CopRadius.lg),
                border: Border.all(color: it.$3.withValues(alpha: 0.2)),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(it.$1, size: 24, color: it.$3),
                const SizedBox(height: 6),
                Text(it.$2,
                    style: TextStyle(color: it.$3, fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
      ],
    );
  }
}

// ─── Sponsor teaser ───────────────────────────────────────────
class _SponsorCard extends StatelessWidget {
  const _SponsorCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CopColors.sand.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(CopRadius.lg),
        border: Border.all(color: CopColors.sand),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: CopColors.sand,
            borderRadius: BorderRadius.circular(CopRadius.sm),
          ),
          child: const Center(child: Text('🌱', style: TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('PLATINUM SPONSOR',
              style: TextStyle(fontSize: 10, color: Color(0xFF92400E),
                  fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          SizedBox(height: 2),
          Text('GreenTech Mongolia',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          Text('Нарны эрчим хүч · Booth G-14',
              style: TextStyle(fontSize: 11, color: CopColors.inkMuted)),
        ])),
        const Icon(Icons.arrow_forward_ios, size: 14, color: CopColors.inkMuted),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: CopColors.surface,
      borderRadius: BorderRadius.circular(CopRadius.lg),
      border: Border.all(color: CopColors.border),
    ),
    child: child,
  );
}
