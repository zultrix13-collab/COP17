import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/widgets/glass_container.dart';
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
      body: Container(
        decoration: const BoxDecoration(gradient: copLandGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(profileStreamProvider);
              ref.invalidate(sessionsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                profileAsync.when(
                  loading: () => const SizedBox(height: 140),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (p) => _BrandHeader(
                    name:
                        p?.name.isNotEmpty == true ? p!.name : (p?.email ?? ''),
                    tier: p?.tier ?? 'green',
                    onQr: () => context.push('/profile/digital-id'),
                  ),
                ),
                const SizedBox(height: 12),
                const _WidgetsRow(),
                const SizedBox(height: 18),
                sessionsAsync.when(
                  loading: () => const _Card(
                    child: SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator())),
                  ),
                  error: (e, _) => _Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16), child: Text('$e')),
                  ),
                  data: (sessions) => _TodaySessions(sessions: sessions),
                ),
                const SizedBox(height: 18),
                const _EventStatsRow(),
                const SizedBox(height: 18),
                const _MissionCard(),
                const SizedBox(height: 18),
                _QuickLinks(
                  onMap: () => context.go('/map'),
                  onServices: () => context.go('/services'),
                  onHelp: () => context.push('/help'),
                  onAi: () => context.push('/information/chatbot'),
                ),
                const SizedBox(height: 18),
                const _SponsorCard(),
              ],
            ),
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
  const _BrandHeader(
      {required this.name, required this.tier, required this.onQr});

  @override
  Widget build(BuildContext context) {
    final daysLeft = DateTime(2026, 8, 17).difference(DateTime.now()).inDays;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: copBrandGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: CopColors.primary.withValues(alpha: 0.25),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HeroPatternPainter())),
          Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset('assets/brand/cop17-logo.png',
                      fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UNCCD COP17',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ulaanbaatar, Mongolia',
                          style: TextStyle(
                            color: Color(0xDDE8F7FA),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                ),
                _GlassIconButton(
                    icon: Icons.qr_code_2, tooltip: 'Digital ID', onTap: onQr),
              ]),
              const SizedBox(height: 28),
              const Text(
                'Restoring Land,\nRestoring Hope',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeroChip(
                    icon: Icons.calendar_today_outlined,
                    text: 'Aug 17-28, 2026',
                  ),
                  _HeroChip(
                    icon: Icons.public,
                    text: '197 Parties',
                  ),
                  _HeroChip(
                    icon: _tierIcon(tier),
                    text: tierLabel(tier),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              GlassContainer(
                blur: 14,
                opacity: 0.12,
                padding: const EdgeInsets.all(14),
                borderRadius: BorderRadius.circular(20),
                child: Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.person_outline,
                        color: CopColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            daysLeft > 0
                                ? '$daysLeft days to opening day'
                                : 'COP17 is in session',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]),
                  ),
                  IconButton.filledTonal(
                    onPressed: onQr,
                    icon: const Icon(Icons.arrow_forward),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: CopColors.primary,
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: GlassContainer(
              blur: 10,
              opacity: 0.12,
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(16),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
      );
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeroChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => GlassContainer(
        blur: 10,
        opacity: 0.1,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        borderRadius: BorderRadius.circular(CopRadius.pill),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ]),
      );
}

class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    final center = Offset(size.width * 0.86, size.height * 0.18);
    for (var i = 0; i < 14; i++) {
      final dx = (i - 7) * 28.0;
      canvas.drawLine(
          center, Offset(size.width + dx, size.height * 0.76), rayPaint);
    }

    final dunePaint = Paint()..color = Colors.white.withValues(alpha: 0.07);
    final dune = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.74,
          size.width * 0.58, size.height * 0.86)
      ..quadraticBezierTo(
          size.width * 0.82, size.height * 0.96, size.width, size.height * 0.84)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(dune, dunePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

IconData _tierIcon(String tier) => switch (tier) {
      'vip' => Icons.workspace_premium_outlined,
      'exhibitor' => Icons.storefront_outlined,
      'press' => Icons.article_outlined,
      'blue' => Icons.verified_outlined,
      _ => Icons.eco_outlined,
    };

// ─── Mission card ─────────────────────────────────────────────
class _MissionCard extends StatelessWidget {
  const _MissionCard();

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: CopColors.primary,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: CopColors.land.withValues(alpha: 0.18)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
                child: CustomPaint(painter: _MissionPatternPainter())),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(CopRadius.pill),
                      ),
                      child:
                          const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.spa_outlined, size: 15, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Road to COP17',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A global forum for action on desertification, drought, and rangeland resilience.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Mongolia brings together governments, communities, and innovators to restore land and strengthen livelihoods.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: Colors.white.withValues(alpha: 0.74),
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      );
}

class _MissionPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 5; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - 105 + i * 18, 20 + i * 18, 130, 130),
          const Radius.circular(18),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Official event stats ─────────────────────────────────────
class _EventStatsRow extends StatelessWidget {
  const _EventStatsRow();

  @override
  Widget build(BuildContext context) {
    const items = <(String, String, IconData, Color)>[
      ('10k+', 'Participants', Icons.groups_2_outlined, CopColors.primary),
      ('81k', 'Sq meters', Icons.domain_outlined, CopColors.sky),
      ('100+', 'Suppliers', Icons.handshake_outlined, CopColors.land),
      ('80+', 'Projects', Icons.eco_outlined, CopColors.sun),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Event scale', action: 'Official'),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 360;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmall ? 2 : 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 110,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return _SoftCard(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: item.$4.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.$3, size: 18, color: item.$4),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            item.$1,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: item.$4,
                                letterSpacing: -0.4),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 9.5,
                                color: CopColors.inkMuted,
                                fontWeight: FontWeight.w700),
                          ),
                        ]),
                  ),
                );
              },
            );
          }
        ),
      ],
    );
  }
}

// ─── Side-by-side widgets ──────────────────────────────────────
class _WidgetsRow extends StatelessWidget {
  const _WidgetsRow();
  @override
  Widget build(BuildContext context) => Row(children: const [
        Expanded(
            child: _StatTile(
                icon: Icons.eco_outlined,
                label: 'Restoration points',
                value: '340',
                sub: 'Next reward at 500',
                tint: CopColors.success)),
        SizedBox(width: 10),
        Expanded(
            child: _StatTile(
                icon: Icons.wb_sunny_outlined,
                label: 'Ulaanbaatar',
                value: '+8°C',
                sub: 'Clear · 3 m/s',
                tint: CopColors.sky)),
      ]);
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label, value, sub;
  final Color tint;
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.tint,
  });
  @override
  Widget build(BuildContext context) => _SoftCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: tint),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11,
                        color: CopColors.inkMuted,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: tint,
                  letterSpacing: -0.5,
                )),
            Text(sub,
                style:
                    const TextStyle(fontSize: 11, color: CopColors.inkMuted)),
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
    return _SoftCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(
                child: _SectionHeader(title: 'Today agenda', action: 'Live')),
            IconButton(
              onPressed: () => GoRouter.of(context).go('/programme'),
              icon: const Icon(Icons.arrow_forward),
              style: IconButton.styleFrom(
                backgroundColor: CopColors.surfaceAlt,
                foregroundColor: CopColors.primary,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          if (preview.isEmpty)
            const _EmptyLine(
                icon: Icons.event_busy_outlined,
                text: 'No sessions scheduled for today'),
          for (int i = 0; i < preview.length; i++)
            _SessionPreviewTile(
              session: preview[i],
              time: fmt.format(preview[i].startsAt),
              active: i == 0,
            ),
        ]),
      ),
    );
  }
}

class _SessionPreviewTile extends StatelessWidget {
  final SessionItem session;
  final String time;
  final bool active;
  const _SessionPreviewTile({
    required this.session,
    required this.time,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? CopColors.land : CopColors.sky;
    return InkWell(
      onTap: () => context.push('/programme/${session.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: active ? 0.09 : 0.055),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Row(children: [
          Container(
            width: 56,
            height: 54,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (active) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: CopColors.land,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Next up',
                    style: TextStyle(
                      color: CopColors.land,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ]),
              if (active) const SizedBox(height: 3),
              Text(
                session.titleMn,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: CopColors.inkMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    session.hall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5,
                        color: CopColors.inkMuted,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ]),
          ),
          const Icon(Icons.chevron_right, color: CopColors.inkMuted),
        ]),
      ),
    );
  }
}

// ─── Quick links ──────────────────────────────────────────────
class _QuickLinks extends StatelessWidget {
  final VoidCallback onMap, onServices, onHelp, onAi;
  const _QuickLinks({
    required this.onMap,
    required this.onServices,
    required this.onHelp,
    required this.onAi,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, Color, VoidCallback)>[
      (Icons.map_outlined, 'Map', CopColors.sky, onMap),
      (
        Icons.account_balance_wallet_outlined,
        'Wallet',
        CopColors.primary,
        onServices
      ),
      (Icons.auto_awesome, 'AI Guide', CopColors.tierVip, onAi),
      (Icons.sos_outlined, 'SOS', CopColors.danger, onHelp),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Quick access', action: 'Tools'),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 4 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 64,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final it = items[i];
                return InkWell(
                  onTap: it.$4,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: CopColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: it.$3.withValues(alpha: 0.18)),
                      boxShadow: [
                        BoxShadow(
                          color: CopColors.primary.withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: it.$3.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(it.$1, size: 20, color: it.$3),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(it.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: CopColors.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w900)),
                      ),
                    ]),
                  ),
                );
              },
            );
          }
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
    return _SoftCard(
      child: Row(children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: CopColors.sun.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.energy_savings_leaf_outlined,
              color: CopColors.warning),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
              Text('PLATINUM SPONSOR',
                  style: TextStyle(
                      fontSize: 10,
                      color: CopColors.warning,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2)),
              SizedBox(height: 2),
              Text('GreenTech Mongolia',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text('Нарны эрчим хүч · Booth G-14',
                  style: TextStyle(fontSize: 11, color: CopColors.inkMuted)),
            ])),
        const Icon(Icons.arrow_forward_ios,
            size: 14, color: CopColors.inkMuted),
      ]).paddingAll(14),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  const _SectionHeader({required this.title, required this.action});

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: CopColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: CopColors.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(CopRadius.pill),
          ),
          child: Text(
            action,
            style: const TextStyle(
              color: CopColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ]);
}

class _EmptyLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CopColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Icon(icon, color: CopColors.inkMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: CopColors.inkMuted, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
      );
}

extension _WidgetPadding on Widget {
  Widget paddingAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  const _SoftCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: CopColors.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          boxShadow: [
            BoxShadow(
              color: CopColors.primary.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      );
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
