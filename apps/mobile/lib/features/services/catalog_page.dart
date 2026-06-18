import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/error_view.dart';
import '../../l10n/app_localizations.dart';
import 'services_repository.dart';

final _money = NumberFormat.currency(locale: 'mn_MN', symbol: '₮', decimalDigits: 0);

/// Mutable cart keyed by product id → quantity, scoped to a kind.
/// autoDispose so the cart resets naturally when the user leaves the catalog.
final cartProvider =
    StateProvider.autoDispose.family<Map<String, int>, String>((_, __) => {});

String _kindTitle(String kind, AppL10n l10n) => switch (kind) {
      'shop' => l10n.shop,
      'food' => l10n.food,
      'esim' => 'E-SIM',
      _ => kind,
    };

class CatalogPage extends ConsumerWidget {
  final String kind;
  const CatalogPage({super.key, required this.kind});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final catalog = ref.watch(catalogProvider(kind));
    final cart = ref.watch(cartProvider(kind));
    final total = catalog.valueOrNull == null
        ? 0
        : cart.entries.fold<int>(0, (s, e) {
            final p = catalog.value!.firstWhere(
              (x) => x.id == e.key,
              orElse: () => Product(id: '', kind: kind, nameMn: '', nameEn: '', price: 0),
            );
            return s + p.price * e.value;
          });

    return Scaffold(
      appBar: AppBar(title: Text(_kindTitle(kind, l10n))),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: ErrorView(error: e)),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(l10n.noProducts));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final p = list[i];
              final qty = cart[p.id] ?? 0;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEBEBEB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name(locale), style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (p.vendor != null)
                      Text(p.vendor!, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                    const SizedBox(height: 4),
                    Text(_money.format(p.price)),
                  ])),
                  _QtyStepper(
                    qty: qty,
                    onChange: (q) {
                      final next = {...cart};
                      if (q <= 0) {
                        next.remove(p.id);
                      } else {
                        next[p.id] = q;
                      }
                      ref.read(cartProvider(kind).notifier).state = next;
                    },
                  ),
                ]),
              );
            },
          );
        },
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: () => context.push('/services/checkout/$kind'),
                  child: Text(l10n.cartTotal(_money.format(total))),
                ),
              ),
            ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChange;
  const _QtyStepper({required this.qty, required this.onChange});
  @override
  Widget build(BuildContext context) {
    if (qty == 0) {
      return OutlinedButton(
          onPressed: () => onChange(1),
          child: Text(AppL10n.of(context)!.addToCart));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: const Icon(Icons.remove), onPressed: () => onChange(qty - 1)),
      Text('$qty', style: const TextStyle(fontWeight: FontWeight.w700)),
      IconButton(icon: const Icon(Icons.add), onPressed: () => onChange(qty + 1)),
    ]);
  }
}

class CheckoutPage extends ConsumerStatefulWidget {
  final String kind;
  const CheckoutPage({super.key, required this.kind});
  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  bool _busy = false;

  Future<void> _pay() async {
    final cart = ref.read(cartProvider(widget.kind));
    final items = cart.entries.map((e) => (productId: e.key, quantity: e.value)).toList();
    setState(() => _busy = true);
    try {
      final res = await ref.read(servicesRepositoryProvider).purchase(items);
      if (!mounted) return;
      ref.read(cartProvider(widget.kind).notifier).state = {};
      ref.invalidate(walletTxnsProvider);
      ref.invalidate(balanceStreamProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context)!.paidOrder(() { final id = res['orderId'] as String; return id.substring(0, id.length.clamp(0, 8)); }()))),
      );
      context.go('/services');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final cart = ref.watch(cartProvider(widget.kind));
    final catalog = ref.watch(catalogProvider(widget.kind));
    final balance = ref.watch(balanceStreamProvider);

    if (cart.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
      return const SizedBox.shrink();
    }
    final items = catalog.valueOrNull
            ?.where((p) => cart.containsKey(p.id))
            .map((p) => (product: p, quantity: cart[p.id]!))
            .toList() ??
        const [];
    final total = items.fold<int>(0, (s, e) => s + e.product.price * e.quantity);
    final bal = balance.valueOrNull ?? 0;
    final enough = bal >= total;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final e in items)
            ListTile(
              dense: true,
              title: Text(e.product.name(locale)),
              subtitle: Text('${e.quantity} × ${_money.format(e.product.price)}'),
              trailing: Text(_money.format(e.product.price * e.quantity),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l10n.total, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(_money.format(total),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ]),
          const SizedBox(height: 8),
          Text(
            enough
                ? l10n.walletEnough(_money.format(bal))
                : l10n.walletShort(_money.format(bal)),
            style: TextStyle(color: enough ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
          ),
          const Spacer(),
          FilledButton(
            onPressed: !enough || _busy ? null : _pay,
            child: Text(_busy ? '…' : l10n.payWithWallet),
          ),
        ]),
      ),
    );
  }
}
