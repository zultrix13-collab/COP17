import 'package:supabase_flutter/supabase_flutter.dart';

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
  await Supabase.initialize(url: url, anonKey: anonKey);
}

SupabaseClient get supabase => Supabase.instance.client;
