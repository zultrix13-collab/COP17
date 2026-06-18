import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/error_view.dart';
import '../../l10n/app_localizations.dart';
import '../profile/profile_repository.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context)!;
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: ErrorView(
                error: e,
                onRetry: () => ref.invalidate(currentProfileProvider),
              ),
            ),
            data: (p) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text('🌿', textAlign: TextAlign.center, style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  l10n.welcomeGreeting(
                      p?.name.isNotEmpty == true ? p!.name : p?.email ?? ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(l10n.siopLocationDate,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF888888))),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    border: Border.all(color: const Color(0xFF16A34A)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.accessTierLabel,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Text('🟢 ', style: TextStyle(fontSize: 18)),
                        Text(_tierLabel(p?.tier ?? 'green', l10n),
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                        l10n.accessTierNote,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: Text(l10n.getStarted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tierLabel(String t, AppL10n l10n) => switch (t) {
        'blue' => l10n.tierBlue,
        'vip' => l10n.tierVip,
        'exhibitor' => l10n.tierExhibitor,
        'press' => l10n.tierPress,
        _ => l10n.tierGreen,
      };
}
