import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'supabase_client.dart';

const _defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/v1',
);

/// Dio with a Supabase-access-token bearer injector.
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: _defaultBaseUrl, connectTimeout: const Duration(seconds: 8)));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (opts, handler) {
        final token = supabase.auth.currentSession?.accessToken;
        if (token != null) {
          opts.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(opts);
      },
    ),
  );
  return dio;
});
