import 'dart:async';

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
    final user = supabase.auth.currentUser;
    if (user == null) throw StateError('Not authenticated');
    final userId = user.id;
    final dio = ref.read(apiClientProvider);
    final res = await dio.get('/qr/issue', queryParameters: {'userId': userId});
    return DigitalIdToken(
      token: res.data['token'] as String,
      expiresAt: res.data['expiresAt'] as int,
    );
  }
}

/// Cached for 5 minutes (well within the 15-min token TTL), then re-fetched.
final digitalIdProvider = FutureProvider.autoDispose<DigitalIdToken>((ref) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);
  return ref.watch(digitalIdRepositoryProvider).issue();
});
