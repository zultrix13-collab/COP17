import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/env.dart';

StreamSubscription<String>? _tokenRefreshSub;

/// Request push permission, get an FCM token, and send it to our API so
/// notifications.service can fan out to the right devices. Call once after
/// auth completes (e.g. from Welcome page or MainShell mount).
Future<void> registerPushToken(WidgetRef ref) async {
  if (demoMode || reviewSession) return;
  try {
    final fm = FirebaseMessaging.instance;
    final settings = await fm.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await fm.getToken();
    if (token == null) return;

    await ref.read(apiClientProvider).post('/device-tokens', data: {
      'token': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
    });

    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = fm.onTokenRefresh.listen((newToken) {
      ref.read(apiClientProvider).post('/device-tokens', data: {
        'token': newToken,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    });
  } catch (_) {
    // Backend API may be unavailable; push registration is best-effort.
  }
}

void cancelPushRegistration() {
  _tokenRefreshSub?.cancel();
  _tokenRefreshSub = null;
}
