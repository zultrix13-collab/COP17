import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/error_view.dart';
import '../../l10n/app_localizations.dart';
import 'programme_repository.dart';

class MyAgendaPage extends ConsumerWidget {
  const MyAgendaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final agenda = ref.watch(myAgendaProvider);
    final fmt = DateFormat('MMM d · HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myAgendaTitle)),
      body: agenda.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: ErrorView(error: e)),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text(l10n.noAgenda,
                  style: const TextStyle(color: Color(0xFF888888))),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myAgendaProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final s = list[i];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFFEBEBEB)),
                  ),
                  title: Text(s.title(locale), style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${fmt.format(s.startsAt)} · ${s.hall}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/programme/${s.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
