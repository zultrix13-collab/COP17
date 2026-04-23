import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((_) => AuthRepository());

/// Thin wrapper around supabase.auth so widgets stay testable.
class AuthRepository {
  Future<void> requestOtp(String email) async {
    await supabase.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
    );
  }

  Future<AuthResponse> verifyOtp({required String email, required String token}) {
    return supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Future<void> signOut() => supabase.auth.signOut();

  Stream<AuthState> onAuthStateChange() => supabase.auth.onAuthStateChange;

  Session? get currentSession => supabase.auth.currentSession;
}

/// Emits the current Supabase session. `null` = signed out.
final sessionProvider = StreamProvider<Session?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.onAuthStateChange().map((event) => event.session);
});
