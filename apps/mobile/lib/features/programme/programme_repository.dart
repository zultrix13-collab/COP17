import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/env.dart';
import '../../core/supabase_client.dart';

class SessionItem {
  final String id;
  final String titleMn;
  final String titleEn;
  final String hall;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;
  final List<String> accessTiers;
  final String? descriptionMn;
  final String? descriptionEn;
  final int goingCount;
  final List<String>? speakers;

  SessionItem({
    required this.id,
    required this.titleMn,
    required this.titleEn,
    required this.hall,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    required this.accessTiers,
    required this.goingCount,
    this.descriptionMn,
    this.descriptionEn,
    this.speakers,
  });

  factory SessionItem.fromMap(Map<String, dynamic> m) => SessionItem(
        id: m['id'] as String,
        titleMn: m['title_mn'] as String,
        titleEn: m['title_en'] as String,
        hall: m['hall'] as String,
        startsAt: DateTime.parse(m['starts_at'] as String),
        endsAt: DateTime.parse(m['ends_at'] as String),
        capacity: (m['capacity'] as num?)?.toInt() ?? 0,
        accessTiers: ((m['access_tiers'] as List?) ?? const []).cast<String>(),
        descriptionMn: m['description_mn'] as String?,
        descriptionEn: m['description_en'] as String?,
        goingCount: 0, // enriched separately if needed
        speakers: (m['speakers'] as List?)?.cast<String>(),
      );

  bool get isFull => capacity > 0 && goingCount >= capacity;
  String title(String locale) => locale == 'en'
      ? (titleEn.isNotEmpty ? titleEn : titleMn)
      : (titleMn.isNotEmpty ? titleMn : titleEn);
  String? description(String locale) => locale == 'en'
      ? (descriptionEn ?? descriptionMn)
      : (descriptionMn ?? descriptionEn);
}

enum AttendanceStatus { going, waitlist, attended, cancelled }

AttendanceStatus? _parseStatus(String? s) {
  if (s == null) return null;
  return AttendanceStatus.values.firstWhere(
    (e) => e.name == s,
    orElse: () => AttendanceStatus.going,
  );
}

final programmeRepositoryProvider =
    Provider<ProgrammeRepository>((_) => ProgrammeRepository());

class ProgrammeRepository {
  String _requireUserId() {
    final user = supabase.auth.currentUser;
    if (user == null) throw StateError('Not authenticated');
    return user.id;
  }

  Future<List<SessionItem>> list({DateTime? day}) async {
    if (demoMode || reviewSession) return _demoSessions(day: day);
    final q = supabase
        .from('sessions')
        .select(
            'id, title_mn, title_en, hall, starts_at, ends_at, capacity, access_tiers, description_mn, description_en, speakers')
        .order('starts_at');
    final data = await q;
    final items = (data as List)
        .cast<Map<String, dynamic>>()
        .map(SessionItem.fromMap)
        .toList();
    if (day != null) {
      return items
          .where((s) =>
              s.startsAt.year == day.year &&
              s.startsAt.month == day.month &&
              s.startsAt.day == day.day)
          .toList();
    }
    return items;
  }

  Future<SessionItem?> byId(String id) async {
    if (demoMode || reviewSession) {
      return _demoSessions().where((s) => s.id == id).firstOrNull;
    }
    final row =
        await supabase.from('sessions').select('*').eq('id', id).maybeSingle();
    return row == null ? null : SessionItem.fromMap(row);
  }

  /// Mark Going. If the session is full we insert as waitlist.
  /// Returns the final status.
  Future<AttendanceStatus> markGoing(String sessionId) async {
    if (demoMode || reviewSession) return AttendanceStatus.going;
    final userId = _requireUserId();
    final count = await supabase
        .from('attendance')
        .select('id')
        .eq('session_id', sessionId)
        .count();
    final session = await supabase
        .from('sessions')
        .select('capacity')
        .eq('id', sessionId)
        .single();
    final capacity = (session['capacity'] as num?)?.toInt() ?? 0;
    final status =
        (capacity > 0 && count.count >= capacity) ? 'waitlist' : 'going';
    await supabase.from('attendance').upsert({
      'user_id': userId,
      'session_id': sessionId,
      'status': status,
    }, onConflict: 'user_id,session_id');
    return _parseStatus(status)!;
  }

  Future<void> cancelAttendance(String sessionId) async {
    if (demoMode || reviewSession) return;
    final userId = _requireUserId();
    await supabase
        .from('attendance')
        .delete()
        .eq('user_id', userId)
        .eq('session_id', sessionId);
  }

  Future<AttendanceStatus?> myAttendance(String sessionId) async {
    if (demoMode || reviewSession) return null;
    final userId = _requireUserId();
    final row = await supabase
        .from('attendance')
        .select('status')
        .eq('user_id', userId)
        .eq('session_id', sessionId)
        .maybeSingle();
    return _parseStatus(row?['status'] as String?);
  }

  Future<List<SessionItem>> myAgenda() async {
    if (demoMode || reviewSession) return _demoSessions();
    final userId = _requireUserId();
    final rows = await supabase
        .from('attendance')
        .select('session:sessions(*)')
        .eq('user_id', userId)
        .inFilter('status', ['going', 'attended']);
    return (rows as List)
        .map((r) => SessionItem.fromMap(r['session'] as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  Future<void> submitFeedback({
    required String sessionId,
    required int rating,
    String? comment,
  }) async {
    if (demoMode || reviewSession) return;
    final userId = _requireUserId();
    await supabase.from('session_feedback').upsert({
      'user_id': userId,
      'session_id': sessionId,
      'rating': rating,
      'comment': comment,
    }, onConflict: 'user_id,session_id');
  }
}

List<SessionItem> _demoSessions({DateTime? day}) {
  final items = [
    SessionItem(
      id: 'demo-opening',
      titleMn: 'Нээлтийн ёслол: Together for Change',
      titleEn: 'Opening Ceremony: Together for Change',
      hall: 'Main Plenary Hall',
      startsAt: DateTime(2026, 6, 25, 9),
      endsAt: DateTime(2026, 6, 25, 10, 30),
      capacity: 1200,
      accessTiers: const ['green', 'blue', 'vip', 'press'],
      goingCount: 0,
      descriptionMn: '18th SIOP Asia Congress-ийн нээлтийн ёслол, Улаанбаатар хотод.',
      descriptionEn: 'Opening ceremony of the 18th SIOP Asia Congress in Ulaanbaatar.',
      speakers: const ['Dr. Enkhtuya Purevsuren', 'Prof. Yoshihiro Fukuda'],
    ),
    SessionItem(
      id: 'demo-oncology-care',
      titleMn: 'Хүүхдийн хавдрын тусламж: Шинэ чиг хандлага',
      titleEn: 'Pediatric Oncology Care: Emerging Approaches',
      hall: 'Blue Sky Hall',
      startsAt: DateTime(2026, 6, 25, 11),
      endsAt: DateTime(2026, 6, 25, 12),
      capacity: 420,
      accessTiers: const ['green', 'blue'],
      goingCount: 0,
      descriptionMn:
          'Хүүхдийн хавдрын оношлогоо, эмчилгээний шинэ боломжуудын талаарх ярилцлага.',
      descriptionEn:
          'Dialogue on emerging approaches in pediatric oncology diagnosis and treatment.',
      speakers: const ['Dr. Aiko Sato', 'Dr. Priya Nair'],
    ),
    SessionItem(
      id: 'demo-survivorship',
      titleMn: 'Survivorship болон Compassionate Care',
      titleEn: 'Survivorship and Compassionate Care Roundtable',
      hall: 'Steppe Forum',
      startsAt: DateTime(2026, 6, 25, 14),
      endsAt: DateTime(2026, 6, 25, 15, 30),
      capacity: 260,
      accessTiers: const ['vip', 'exhibitor'],
      goingCount: 0,
      descriptionMn:
          'Хорт хавдраас сэргэсэн хүүхдүүдийн дараагийн амьдрал, асаргаа сувилгааны асуудал.',
      descriptionEn:
          'Roundtable on long-term survivorship and compassionate care for childhood cancer patients.',
      speakers: const ['Prof. Li Wei', 'Dr. Sara Khalil'],
    ),
  ];
  if (day == null) return items;
  return items
      .where((s) =>
          s.startsAt.year == day.year &&
          s.startsAt.month == day.month &&
          s.startsAt.day == day.day)
      .toList();
}

final sessionsProvider =
    FutureProvider.autoDispose.family<List<SessionItem>, DateTime?>((ref, day) {
  return ref.watch(programmeRepositoryProvider).list(day: day);
});

final sessionDetailProvider =
    FutureProvider.autoDispose.family<SessionItem?, String>((ref, id) {
  return ref.watch(programmeRepositoryProvider).byId(id);
});

final myAttendanceProvider =
    FutureProvider.autoDispose.family<AttendanceStatus?, String>((ref, sessionId) {
  return ref.watch(programmeRepositoryProvider).myAttendance(sessionId);
});

final myAgendaProvider = FutureProvider<List<SessionItem>>((ref) {
  return ref.read(programmeRepositoryProvider).myAgenda();
});
