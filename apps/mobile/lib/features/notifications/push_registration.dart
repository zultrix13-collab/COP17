import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';

/// Request push permission, get an FCM token, and send it to our API so
/// notifications.service can fan out to the right devices. Call once after
/// auth completes (e.g. from Welcome page or MainShell mount).
Future<void> registerPushToken(Ref ref) async {
  final fm = FirebaseMessaging.instance;
  final settings = await fm.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.denied) return;

  final token = await fm.getToken();
  if (token == null) return;

  await ref.read(apiClientProvider).post('/device-tokens', data: {
    'token': token,
    'platform': Platform.isIOS ? 'ios' : 'android',
  });

  fm.onTokenRefresh.listen((newToken) {
    ref.read(apiClientProvider).post('/device-tokens', data: {
      'token': newToken,
      'platform': Platform.isIOS ? 'ios' : 'android',
    });
  });
}
