import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/env.dart';
import '../../core/supabase_client.dart';

final infoRepositoryProvider = Provider<InfoRepository>((ref) => InfoRepository(ref));

class InfoRepository {
  final Ref ref;
  InfoRepository(this.ref);

  Future<List<Map<String, dynamic>>> announcements() async {
    if (demoMode || reviewSession) {
      return [
        {
          'id': 'demo-1',
          'title_mn': 'SIOP Mongolia 2026-д тавтай морилно уу',
          'title_en': 'Welcome to SIOP Mongolia 2026',
          'body_mn': 'Уулзалт, арга хэмжээний хуваарийг Programme хэсгээс харна уу.',
          'published_at': DateTime.now().toIso8601String(),
        }
      ];
    }
    final data = await supabase
        .from('announcements')
        .select('*')
        .order('published_at', ascending: false, nullsFirst: false)
        .limit(20);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> faq() async {
    if (demoMode || reviewSession) {
      return [
        {'id': 'f1', 'ordering': 1, 'question_mn': 'Регистрийн бүртгэл хаана байдаг вэ?', 'answer_mn': 'Үүдний A танхимд.'},
        {'id': 'f2', 'ordering': 2, 'question_mn': 'Wi-Fi нэвтрэх үгийг хаанаас авах вэ?', 'answer_mn': 'SIOP2026 / нууц үг: mongolia2026'},
        {'id': 'f3', 'ordering': 3, 'question_mn': 'Эмнэлгийн тусламж хэрэгтэй бол?', 'answer_mn': 'SOS товч дарна уу эсвэл 103 утасна уу.'},
      ];
    }
    final data = await supabase.from('faq').select('*').order('ordering');
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> flights() async {
    if (demoMode || reviewSession) return [];
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
