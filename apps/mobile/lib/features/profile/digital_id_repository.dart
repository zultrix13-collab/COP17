import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/env.dart';
import '../../core/supabase_client.dart';

class DigitalIdToken {
  final String token;
  final int expiresAt;
  DigitalIdToken({required this.token, required this.expiresAt});
  Duration get timeLeft =>
      Duration(seconds: expiresAt - DateTime.now().millisecondsSinceEpoch ~/ 1000);
}

final digitalIdRepositoryProvider = Provider<DigitalIdRepository>((ref) {
  return DigitalIdRepository(ref);
});

class DigitalIdRepository {
  final Ref ref;
  DigitalIdRepository(this.ref);

  Future<DigitalIdToken> issue() async {
    if (demoMode || reviewSession) {
      return DigitalIdToken(
        token: 'DEMO-SIOP-2026',
        expiresAt: DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch ~/ 1000,
      );
    }
    final userId = supabase.auth.currentUser!.id;
    final dio = ref.read(apiClientProvider);
    final res = await dio.get('/qr/issue', queryParameters: {'userId': userId});
    return DigitalIdToken(
      token: res.data['token'] as String,
      expiresAt: res.data['expiresAt'] as int,
    );
  }
}

/// Refreshed every 5 min so the wallet stays well within the 15-min TTL.
final digitalIdProvider = FutureProvider.autoDispose<DigitalIdToken>((ref) async {
  final link = ref.keepAlive();
  ref.onDispose(link.close);
  return ref.watch(digitalIdRepositoryProvider).issue();
});
