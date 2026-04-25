import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/env.dart';
import '../../core/supabase_client.dart';

class Profile {
  final String id;
  final String email;
  final String name;
  final String locale;
  final String tier;
  final String? accreditationId;

  Profile({
    required this.id,
    required this.email,
    required this.name,
    required this.locale,
    required this.tier,
    this.accreditationId,
  });

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id: m['id'] as String,
        email: m['email'] as String,
        name: (m['name'] as String?) ?? '',
        locale: (m['locale'] as String?) ?? 'mn',
        tier: (m['tier'] as String?) ?? 'green',
        accreditationId: m['accreditation_id'] as String?,
      );
}

final profileRepositoryProvider =
    Provider<ProfileRepository>((_) => ProfileRepository());

class ProfileRepository {
  Future<Profile?> current() async {
    if (demoMode) return _demoProfile;
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final row = await supabase
        .from('profiles')
        .select('id, email, name, locale, tier, accreditation_id')
        .eq('id', user.id)
        .maybeSingle();
    return row == null ? null : Profile.fromMap(row);
  }

  /// Listen for RLS-filtered updates to the caller's own profile — tier changes
  /// pushed by admins surface instantly.
  Stream<Profile?> watchCurrent() {
    if (demoMode) return Stream.value(_demoProfile);
    final user = supabase.auth.currentUser;
    if (user == null) return const Stream.empty();
    return supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map((rows) => rows.isEmpty ? null : Profile.fromMap(rows.first));
  }
}

final _demoProfile = Profile(
  id: 'demo',
  email: 'delegate@cop17.mn',
  name: 'COP17 Delegate',
  locale: 'en',
  tier: 'green',
  accreditationId: 'COP17-DEMO',
);

final currentProfileProvider = FutureProvider<Profile?>((ref) {
  return ref.watch(profileRepositoryProvider).current();
});

final profileStreamProvider = StreamProvider<Profile?>((ref) {
  return ref.watch(profileRepositoryProvider).watchCurrent();
});
