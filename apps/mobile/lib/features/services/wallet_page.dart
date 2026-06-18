import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/error_view.dart';
import '../../l10n/app_localizations.dart';
import 'services_repository.dart';

final _money = NumberFormat.currency(locale: 'mn_MN', symbol: '₮', decimalDigits: 0);
final _time = DateFormat('MMM d · HH:mm');

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context)!;
    final balance = ref.watch(balanceStreamProvider);
    final txns = ref.watch(walletTxnsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletTxnsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.balance, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 4),
                balance.when(
                  data: (b) => Text(_money.format(b),
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                  loading: () => const CircularProgressIndicator(color: Colors.white),
                  error: (e, _) => ErrorView(error: e, compact: true),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: FilledButton.icon(
                onPressed: () => context.push('/services/top-up'),
                icon: const Icon(Icons.add), label: Text(l10n.topUp),
              )),
            ]),
            const SizedBox(height: 16),
            Text(l10n.recentTransactions,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            txns.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(error: e, compact: true),
              data: (list) {
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      Text(l10n.noTransactions,
                          style: const TextStyle(color: Color(0xFF888888))),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/services/top-up'),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.topUpNow),
                      ),
                    ]),
                  );
                }
                return Column(children: [
                  for (final t in list)
                    ListTile(
                      dense: true,
                      title: Text(t.reference ?? t.kind,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(_time.format(t.createdAt),
                          style: const TextStyle(fontSize: 11)),
                      trailing: Text(
                        '${t.amount > 0 ? '+' : ''}${_money.format(t.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: t.amount > 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
