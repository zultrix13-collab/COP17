import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/env.dart';
import '../../core/supabase_client.dart';

class WalletTxn {
  final int id;
  final String kind;
  final int amount;
  final String? reference;
  final DateTime createdAt;
  WalletTxn(this.id, this.kind, this.amount, this.reference, this.createdAt);
  factory WalletTxn.fromMap(Map<String, dynamic> m) => WalletTxn(
        m['id'] as int,
        m['kind'] as String,
        (m['amount'] as num).toInt(),
        m['reference'] as String?,
        DateTime.parse(m['created_at'] as String),
      );
}

class Product {
  final String id;
  final String kind;
  final String nameMn;
  final String nameEn;
  final int price;
  final String? imageUrl;
  final String? vendor;
  Product({
    required this.id,
    required this.kind,
    required this.nameMn,
    required this.nameEn,
    required this.price,
    this.imageUrl,
    this.vendor,
  });
  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'] as String,
        kind: m['kind'] as String,
        nameMn: m['name_mn'] as String,
        nameEn: m['name_en'] as String,
        price: (m['price'] as num).toInt(),
        imageUrl: m['image_url'] as String?,
        vendor: m['vendor'] as String?,
      );
}

class QPayInvoice {
  final String id;
  final String qrText;
  final String deepLink;
  final int amount;
  QPayInvoice({required this.id, required this.qrText, required this.deepLink, required this.amount});
}

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) => ServicesRepository(ref));

class ServicesRepository {
  final Ref ref;
  ServicesRepository(this.ref);

  Future<int> balance() async {
    if (demoMode || reviewSession) return 0;
    final dio = ref.read(apiClientProvider);
    final res = await dio.get('/wallet/balance');
    return (res.data['balance'] as num).toInt();
  }

  Stream<int> watchBalance() {
    final user = supabase.auth.currentUser;
    if (user == null) return const Stream.empty();
    return supabase
        .from('wallets')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', user.id)
        .map((rows) => rows.isEmpty ? 0 : (rows.first['balance'] as num).toInt());
  }

  Future<List<WalletTxn>> recentTxns({int limit = 20}) async {
    if (demoMode || reviewSession) return [];
    final user = supabase.auth.currentUser!;
    final data = await supabase
        .from('wallet_txns')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((r) => WalletTxn.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<List<Product>> catalog(String kind) async {
    final data = await supabase
        .from('products')
        .select('*')
        .eq('kind', kind)
        .eq('active', true)
        .order('name_mn');
    return (data as List).map((r) => Product.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<QPayInvoice> topUp(int amount) async {
    final res = await ref.read(apiClientProvider).post('/payments/qpay/top-up', data: {'amount': amount});
    return QPayInvoice(
      id: res.data['id'] as String,
      qrText: res.data['qrText'] as String,
      deepLink: res.data['deepLink'] as String,
      amount: (res.data['amount'] as num).toInt(),
    );
  }

  Future<String> invoiceStatus(String invoiceId) async {
    final res = await ref.read(apiClientProvider).get('/payments/qpay/$invoiceId/status');
    return res.data['status'] as String;
  }

  Future<Map<String, dynamic>> purchase(List<({String productId, int quantity})> items) async {
    final res = await ref.read(apiClientProvider).post('/wallet/purchase', data: {
      'items': items.map((i) => {'productId': i.productId, 'quantity': i.quantity}).toList(),
    });
    return res.data as Map<String, dynamic>;
  }

  // Lost & Found ──────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> lostFound(String kind) async {
    final data = await supabase
        .from('lost_found')
        .select('*')
        .eq('kind', kind)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> reportItem({
    required String kind,
    required String title,
    String? description,
  }) async {
    if (demoMode || reviewSession) return;
    final user = supabase.auth.currentUser!;
    await supabase.from('lost_found').insert({
      'kind': kind,
      'title': title,
      'description': description,
      'reporter_id': user.id,
    });
  }
}

final balanceStreamProvider = StreamProvider<int>((ref) {
  return ref.watch(servicesRepositoryProvider).watchBalance();
});

final walletTxnsProvider = FutureProvider<List<WalletTxn>>((ref) {
  return ref.watch(servicesRepositoryProvider).recentTxns();
});

final catalogProvider = FutureProvider.family<List<Product>, String>((ref, kind) {
  return ref.watch(servicesRepositoryProvider).catalog(kind);
});
