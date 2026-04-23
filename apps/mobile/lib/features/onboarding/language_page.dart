import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_client.dart';

final selectedLocaleProvider = StateProvider<String>((_) => 'mn');

class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedLocaleProvider);

    Future<void> save() async {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').update({'locale': selected}).eq('id', user.id);
      }
      if (context.mounted) context.go('/onboarding/permission');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Хэл сонгох')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LangTile(
              code: 'mn',
              title: '🇲🇳 Монгол',
              subtitle: 'Анхдагч',
              selected: selected == 'mn',
              onTap: () => ref.read(selectedLocaleProvider.notifier).state = 'mn',
            ),
            const SizedBox(height: 8),
            _LangTile(
              code: 'en',
              title: '🇬🇧 English',
              subtitle: 'Available',
              selected: selected == 'en',
              onTap: () => ref.read(selectedLocaleProvider.notifier).state = 'en',
            ),
            const Spacer(),
            FilledButton(onPressed: save, child: const Text('Эхлэх →')),
          ],
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String code;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _LangTile({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? const Color(0xFF1A6EF5) : const Color(0xFFE0E0E0)),
          color: selected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: Color(0xFF1A6EF5)),
          ],
        ),
      ),
    );
  }
}
