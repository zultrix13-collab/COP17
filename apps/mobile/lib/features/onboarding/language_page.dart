import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale.dart';
import '../../core/supabase_client.dart';
import '../../l10n/app_localizations.dart';

/// Language settings, reachable from Profile. English is the default; the user
/// can switch to Mongolian here and the choice persists across restarts.
class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context)!;
    final current = ref.watch(localeProvider).languageCode;

    Future<void> choose(String code) async {
      await ref.read(localeProvider.notifier).set(code);
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').update({'locale': code}).eq('id', user.id);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LangTile(
              title: '🇬🇧 ${l10n.languageEn}',
              subtitle: l10n.defaultLabel,
              selected: current == 'en',
              onTap: () => choose('en'),
            ),
            const SizedBox(height: 8),
            _LangTile(
              title: '🇲🇳 ${l10n.languageMn}',
              subtitle: '',
              selected: current == 'mn',
              onTap: () => choose('mn'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _LangTile({
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
                  if (subtitle.isNotEmpty)
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
