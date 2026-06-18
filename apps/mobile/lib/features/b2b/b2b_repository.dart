import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/env.dart';
import '../../core/supabase_client.dart';

class Exhibitor {
  final String userId;
  final String company;
  final String? sector;
  final String? country;
  final String? booth;
  final String? website;
  final String? logoUrl;
  final String? descriptionMn;
  final String? descriptionEn;
  Exhibitor({
    required this.userId,
    required this.company,
    this.sector,
    this.country,
    this.booth,
    this.website,
    this.logoUrl,
    this.descriptionMn,
    this.descriptionEn,
  });
  factory Exhibitor.fromMap(Map<String, dynamic> m) => Exhibitor(
        userId: m['user_id'] as String,
        company: m['company'] as String,
        sector: m['sector'] as String?,
        country: m['country'] as String?,
        booth: m['booth'] as String?,
        website: m['website'] as String?,
        logoUrl: m['logo_url'] as String?,
        descriptionMn: m['description_mn'] as String?,
        descriptionEn: m['description_en'] as String?,
      );
  String? description(String locale) => locale == 'en'
      ? (descriptionEn ?? descriptionMn)
      : (descriptionMn ?? descriptionEn);
}

class Meeting {
  final String id;
  final String requesterId;
  final String exhibitorId;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final String? purpose;
  Meeting({
    required this.id,
    required this.requesterId,
    required this.exhibitorId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.purpose,
  });
  factory Meeting.fromMap(Map<String, dynamic> m) => Meeting(
        id: m['id'] as String,
        requesterId: m['requester_id'] as String,
        exhibitorId: m['exhibitor_id'] as String,
        startsAt: DateTime.parse(m['starts_at'] as String),
        endsAt: DateTime.parse(m['ends_at'] as String),
        status: m['status'] as String,
        purpose: m['purpose'] as String?,
      );
}

final b2bRepositoryProvider = Provider<B2BRepository>((_) => B2BRepository());

class B2BRepository {
  Future<List<Exhibitor>> list({String? sector, String? search}) async {
    var q = supabase.from('exhibitors_view').select('*');
    if (sector != null) q = q.eq('sector', sector);
    if (search != null && search.trim().isNotEmpty) {
      q = q.ilike('company', '%${search.trim()}%');
    }
    final data = await q.order('company').limit(100);
    return (data as List).map((r) => Exhibitor.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<void> requestMeeting({
    required String exhibitorId,
    required DateTime start,
    required DateTime end,
    String? purpose,
  }) async {
    if (demoMode || reviewSession) return;
    final user = supabase.auth.currentUser;
    if (user == null) throw StateError('Not authenticated');
    final userId = user.id;
    await supabase.from('b2b_meetings').insert({
      'requester_id': userId,
      'exhibitor_id': exhibitorId,
      'starts_at': start.toIso8601String(),
      'ends_at': end.toIso8601String(),
      'purpose': purpose,
    });
  }

  Future<List<Meeting>> myMeetings() async {
    if (demoMode || reviewSession) return [];
    final user = supabase.auth.currentUser;
    if (user == null) throw StateError('Not authenticated');
    final userId = user.id;
    final data = await supabase
        .from('b2b_meetings')
        .select('*')
        .or('requester_id.eq.$userId,exhibitor_id.eq.$userId')
        .order('starts_at');
    return (data as List).map((r) => Meeting.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<void> cancelMeeting(String id) async {
    if (demoMode || reviewSession) return;
    final user = supabase.auth.currentUser;
    if (user == null) return;
    await supabase
        .from('b2b_meetings')
        .update({'status': 'cancelled'})
        .eq('id', id)
        .or('requester_id.eq.${user.id},exhibitor_id.eq.${user.id}');
  }
}

final exhibitorsProvider = FutureProvider.autoDispose.family<List<Exhibitor>, String>((ref, search) {
  return ref.watch(b2bRepositoryProvider).list(search: search.isEmpty ? null : search);
});

final myMeetingsProvider = FutureProvider<List<Meeting>>((ref) {
  return ref.watch(b2bRepositoryProvider).myMeetings();
});
