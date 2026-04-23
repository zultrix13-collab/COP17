import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import 'digital_id_repository.dart';
import 'profile_repository.dart';

class DigitalIdPage extends ConsumerWidget {
  const DigitalIdPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);
    final tokenAsync = ref.watch(digitalIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Дижитал үнэмлэх')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            profileAsync.when(
              data: (p) => Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFDCFCE7),
                    child: Text(p?.name.isNotEmpty == true ? p!.name[0].toUpperCase() : '👤'),
                  ),
                  const SizedBox(height: 8),
                  Text(p?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(p?.email ?? '', style: const TextStyle(color: Color(0xFF888888))),
                  const SizedBox(height: 4),
                  _TierBadge(tier: p?.tier ?? 'green'),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: 16),
            tokenAsync.when(
              data: (t) => _QrBox(token: t),
              loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('QR error: $e'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Offline горимд ажиллана · 15 мин бүр refresh · HMAC signature',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QrBox extends StatelessWidget {
  final DigitalIdToken token;
  const _QrBox({required this.token});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      // Real impl: use the `qr_flutter` package to render `token.token`.
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 120),
            const SizedBox(height: 4),
            Text('expires in ${token.timeLeft.inMinutes} min',
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
          ],
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});
  @override
  Widget build(BuildContext context) {
    final color = tierColor(tier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(CopRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${tierEmoji(tier)} ${tierLabel(tier)}',
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
