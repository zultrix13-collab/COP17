import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/supabase_client.dart';

class Poi {
  final String id;
  final String nameMn;
  final String nameEn;
  final String kind;
  final int? floor;
  final LatLng? point;
  Poi({
    required this.id,
    required this.nameMn,
    required this.nameEn,
    required this.kind,
    this.floor,
    this.point,
  });

  static LatLng? _parseGeom(dynamic v) {
    // Supabase returns GeoJSON for geography via `select 'geom->>''coordinates'''`
    // — but the default select returns WKB hex. For dev: expect a manual
    // `longitude`/`latitude` column or a computed text. Skip if absent.
    if (v is Map && v['coordinates'] is List) {
      final c = v['coordinates'] as List;
      return LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble());
    }
    return null;
  }

  factory Poi.fromMap(Map<String, dynamic> m) => Poi(
        id: m['id'] as String,
        nameMn: m['name_mn'] as String,
        nameEn: m['name_en'] as String,
        kind: m['kind'] as String,
        floor: m['floor'] as int?,
        point: _parseGeom(m['geom']),
      );

  String get emoji => switch (kind) {
        'hall' => '🏛',
        'food' => '🍽',
        'medical' => '🏥',
        'entrance' => '🚪',
        'vip' => '💎',
        'press' => '📰',
        _ => '📍',
      };
}

final mapRepositoryProvider = Provider<MapRepository>((_) => MapRepository());

class MapRepository {
  Future<List<Poi>> list({String? kind, int? floor}) async {
    var q = supabase
        .from('pois')
        .select('id, name_mn, name_en, kind, floor, geom');
    if (kind != null) q = q.eq('kind', kind);
    if (floor != null) q = q.eq('floor', floor);
    final data = await q.order('name_mn');
    return (data as List).map((r) => Poi.fromMap(r as Map<String, dynamic>)).toList();
  }
}

final poisProvider = FutureProvider<List<Poi>>((ref) {
  return ref.watch(mapRepositoryProvider).list();
});
