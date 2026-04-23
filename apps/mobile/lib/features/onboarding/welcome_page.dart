import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../profile/profile_repository.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (p) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text('🌿', textAlign: TextAlign.center, style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  'Тавтай морил, ${p?.name.isNotEmpty == true ? p!.name : p?.email ?? ''}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Text('COP17 · Aug 17–28, 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF888888))),
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
                      const Text('ТАНЫ ХАНДАЛТЫН ЭРХ',
                          style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Text('🟢 ', style: TextStyle(fontSize: 18)),
                        Text(_tierLabel(p?.tier ?? 'green'),
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 4),
                      const Text(
                        'Admin тохируулсан · Дүр өөрчлөгдвөл мэдэгдэнэ',
                        style: TextStyle(fontSize: 12, color: Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Эхэлцгээе →'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tierLabel(String t) => switch (t) {
        'blue' => 'Blue Zone',
        'vip' => 'VIP',
        'exhibitor' => 'Exhibitor',
        'press' => 'Press',
        _ => 'Green Zone',
      };
}
