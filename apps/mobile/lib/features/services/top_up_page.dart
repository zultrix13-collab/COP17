import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'services_repository.dart';

const _presets = [10000, 20000, 50000, 100000];
final _money = NumberFormat.currency(locale: 'mn_MN', symbol: '₮', decimalDigits: 0);

class TopUpPage extends ConsumerStatefulWidget {
  const TopUpPage({super.key});
  @override
  ConsumerState<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends ConsumerState<TopUpPage> {
  int _amount = 20000;
  QPayInvoice? _invoice;
  Timer? _poll;
  String _status = 'pending';
  bool _busy = false;

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _busy = true);
    try {
      final inv = await ref.read(servicesRepositoryProvider).topUp(_amount);
      setState(() => _invoice = inv);
      _poll = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus(inv.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkStatus(String id) async {
    final s = await ref.read(servicesRepositoryProvider).invoiceStatus(id);
    if (!mounted) return;
    setState(() => _status = s);
    if (s == 'paid') {
      _poll?.cancel();
      ref.invalidate(walletTxnsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Цэнэглэлт амжилттай')),
      );
      context.pop();
    } else if (s == 'expired' || s == 'failed') {
      _poll?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Цэнэглэх')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _invoice == null ? _amountStep() : _invoiceStep(),
      ),
    );
  }

  Widget _amountStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Цэнэглэх дүн'),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF1A6EF5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _money.format(_amount),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 8, children: [
        for (final p in _presets)
          ChoiceChip(
            label: Text(_money.format(p)),
            selected: _amount == p,
            onSelected: (_) => setState(() => _amount = p),
          ),
      ]),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: _busy ? null : _start,
        child: Text(_busy ? '…' : 'QPay-аар төлөх'),
      ),
    ]);
  }

  Widget _invoiceStep() {
    return Column(children: [
      const Text('Utility апп-аараа QR кодыг уншуулна уу', textAlign: TextAlign.center),
      const SizedBox(height: 16),
      Container(
        width: 220, height: 220,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Icon(Icons.qr_code_2, size: 140)),
      ),
      const SizedBox(height: 8),
      Text('Дүн: ${_money.format(_invoice!.amount)}', style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('Статус: $_status', style: const TextStyle(color: Color(0xFF888888))),
      const SizedBox(height: 20),
      OutlinedButton(onPressed: () => _checkStatus(_invoice!.id), child: const Text('Шалгах')),
      TextButton(onPressed: () { _poll?.cancel(); context.pop(); }, child: const Text('Цуцлах')),
    ]);
  }
}
