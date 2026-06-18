import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Stores Supabase session tokens in the OS secure keychain/keystore
/// instead of plain SharedPreferences/NSUserDefaults.
class SecureLocalStorage extends LocalStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _key = 'sb_session';

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: _key);

  @override
  Future<String?> accessToken() => _storage.read(key: _key);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _key, value: persistSessionString);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _key);
}

/// Call once in `main()` before `runApp`.
///
/// URL + anon key are build-time injected via `--dart-define`:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
Future<void> initSupabase() async {
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (url.isEmpty || anonKey.isEmpty) {
    throw StateError('SUPABASE_URL and SUPABASE_ANON_KEY must be provided');
  }
  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureLocalStorage(),
      authFlowType: AuthFlowType.pkce,
    ),
  );
}

SupabaseClient get supabase => Supabase.instance.client;
