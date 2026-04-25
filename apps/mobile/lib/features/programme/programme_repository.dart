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
      );

  bool get isFull => capacity > 0 && goingCount >= capacity;
  String title(String locale) => locale == 'en' ? titleEn : titleMn;
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
  Future<List<SessionItem>> list({DateTime? day}) async {
    if (demoMode) return _demoSessions(day: day);
    final q = supabase
        .from('sessions')
        .select(
            'id, title_mn, title_en, hall, starts_at, ends_at, capacity, access_tiers, description_mn, description_en')
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
    final row =
        await supabase.from('sessions').select('*').eq('id', id).maybeSingle();
    return row == null ? null : SessionItem.fromMap(row);
  }

  /// Mark Going. If the session is full we insert as waitlist.
  /// Returns the final status.
  Future<AttendanceStatus> markGoing(String sessionId) async {
    final userId = supabase.auth.currentUser!.id;
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
    final userId = supabase.auth.currentUser!.id;
    await supabase
        .from('attendance')
        .delete()
        .eq('user_id', userId)
        .eq('session_id', sessionId);
  }

  Future<AttendanceStatus?> myAttendance(String sessionId) async {
    final userId = supabase.auth.currentUser!.id;
    final row = await supabase
        .from('attendance')
        .select('status')
        .eq('user_id', userId)
        .eq('session_id', sessionId)
        .maybeSingle();
    return _parseStatus(row?['status'] as String?);
  }

  Future<List<SessionItem>> myAgenda() async {
    final userId = supabase.auth.currentUser!.id;
    final rows = await supabase
        .from('attendance')
        .select('session:sessions(*)')
        .eq('user_id', userId);
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
    final userId = supabase.auth.currentUser!.id;
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
      titleMn: 'Opening Plenary: Restoring Land, Restoring Hope',
      titleEn: 'Opening Plenary: Restoring Land, Restoring Hope',
      hall: 'Main Plenary Hall',
      startsAt: DateTime(2026, 8, 17, 9),
      endsAt: DateTime(2026, 8, 17, 10, 30),
      capacity: 1200,
      accessTiers: const ['green', 'blue', 'vip', 'press'],
      goingCount: 0,
      descriptionMn: 'Global opening session for UNCCD COP17 in Ulaanbaatar.',
      descriptionEn: 'Global opening session for UNCCD COP17 in Ulaanbaatar.',
    ),
    SessionItem(
      id: 'demo-rangelands',
      titleMn: 'Rangeland Resilience and Pastoralist Futures',
      titleEn: 'Rangeland Resilience and Pastoralist Futures',
      hall: 'Blue Sky Hall',
      startsAt: DateTime(2026, 8, 17, 11),
      endsAt: DateTime(2026, 8, 17, 12),
      capacity: 420,
      accessTiers: const ['green', 'blue'],
      goingCount: 0,
      descriptionMn:
          'Dialogue on sustainable rangelands and pastoralist livelihoods.',
      descriptionEn:
          'Dialogue on sustainable rangelands and pastoralist livelihoods.',
    ),
    SessionItem(
      id: 'demo-investment',
      titleMn: 'Land Restoration Investment Roundtable',
      titleEn: 'Land Restoration Investment Roundtable',
      hall: 'Steppe Forum',
      startsAt: DateTime(2026, 8, 17, 14),
      endsAt: DateTime(2026, 8, 17, 15, 30),
      capacity: 260,
      accessTiers: const ['vip', 'exhibitor'],
      goingCount: 0,
      descriptionMn:
          'Financing practical restoration and drought resilience solutions.',
      descriptionEn:
          'Financing practical restoration and drought resilience solutions.',
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
    FutureProvider.family<List<SessionItem>, DateTime?>((ref, day) {
  return ref.read(programmeRepositoryProvider).list(day: day);
});

final sessionDetailProvider =
    FutureProvider.family<SessionItem?, String>((ref, id) {
  return ref.read(programmeRepositoryProvider).byId(id);
});

final myAttendanceProvider =
    FutureProvider.family<AttendanceStatus?, String>((ref, sessionId) {
  return ref.read(programmeRepositoryProvider).myAttendance(sessionId);
});

final myAgendaProvider = FutureProvider<List<SessionItem>>((ref) {
  return ref.read(programmeRepositoryProvider).myAgenda();
});
