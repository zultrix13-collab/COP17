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
          'body_en': 'See the schedule of sessions and events in the Programme tab.',
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
        {'id': 'f1', 'ordering': 1, 'question_mn': 'Регистрийн бүртгэл хаана байдаг вэ?', 'question_en': 'Where is registration?', 'answer_mn': 'Үүдний A танхимд.', 'answer_en': 'At Hall A by the entrance.'},
        {'id': 'f2', 'ordering': 2, 'question_mn': 'Wi-Fi нэвтрэх үгийг хаанаас авах вэ?', 'question_en': 'How do I get the Wi-Fi password?', 'answer_mn': 'Мэдээллийн ширээнд Wi-Fi карт авна уу.', 'answer_en': 'Pick up a Wi-Fi card from the information desk.'},
        {'id': 'f3', 'ordering': 3, 'question_mn': 'Эмнэлгийн тусламж хэрэгтэй бол?', 'question_en': 'What if I need medical help?', 'answer_mn': 'SOS товч дарна уу эсвэл 103 утасна уу.', 'answer_en': 'Tap the SOS button or call 103.'},
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
