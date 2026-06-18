import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/error_view.dart';
import '../../l10n/app_localizations.dart';
import 'services_repository.dart';

final _money = NumberFormat.currency(locale: 'mn_MN', symbol: '₮', decimalDigits: 0);

class ServicesPage extends ConsumerWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context)!;
    final balance = ref.watch(balanceStreamProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navServices)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          InkWell(
            onTap: () => context.push('/services/wallet'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.walletBalance,
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 4),
                balance.when(
                  data: (b) => Text(_money.format(b),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  loading: () => const Text('…', style: TextStyle(color: Colors.white70)),
                  error: (e, _) => ErrorView(error: e, compact: true),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: [
              _Tile(icon: '🛍', label: l10n.shop, onTap: () => context.push('/services/catalog/shop')),
              _Tile(icon: '🍽', label: l10n.food, onTap: () => context.push('/services/catalog/food')),
              _Tile(icon: '📱', label: 'E-SIM', onTap: () => context.push('/services/catalog/esim')),
              _Tile(icon: '🚕', label: l10n.transport, onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.comingSoon)),
                );
              }),
              _Tile(icon: '🔍', label: 'Lost & F', onTap: () => context.push('/services/lost-found')),
              _Tile(icon: '➕', label: l10n.topUp, onTap: () => context.push('/services/top-up')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ]),
      ),
    );
  }
}
