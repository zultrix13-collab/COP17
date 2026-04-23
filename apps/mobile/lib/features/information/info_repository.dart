import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/supabase_client.dart';

final infoRepositoryProvider = Provider<InfoRepository>((ref) => InfoRepository(ref));

class InfoRepository {
  final Ref ref;
  InfoRepository(this.ref);

  Future<List<Map<String, dynamic>>> announcements() async {
    final data = await supabase
        .from('announcements')
        .select('*')
        .order('published_at', ascending: false, nullsFirst: false)
        .limit(20);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> faq() async {
    final data = await supabase.from('faq').select('*').order('ordering');
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> flights() async {
    final data = await supabase
        .from('flights')
        .select('*')
        .order('scheduled', ascending: true, nullsFirst: false)
        .limit(20);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> chat(String message, String locale) async {
    final res = await ref.read(apiClientProvider).post('/ai/chat', data: {
      'message': message,
      'locale': locale,
    });
    return res.data as Map<String, dynamic>;
  }
}

final announcementsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(infoRepositoryProvider).announcements();
});

final faqProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(infoRepositoryProvider).faq();
});

final flightsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(infoRepositoryProvider).flights();
});
