import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/env.dart';
import '../../core/supabase_client.dart';

class MediaAsset {
  final String id;
  final String title;
  final String kind; // 'document' | 'image' | 'video'
  final String url;
  MediaAsset({required this.id, required this.title, required this.kind, required this.url});
  factory MediaAsset.fromMap(Map<String, dynamic> m) => MediaAsset(
        id: m['id'] as String,
        title: m['title'] as String,
        kind: (m['kind'] as String?) ?? 'document',
        url: m['url'] as String,
      );

}

final mediaAssetsProvider = FutureProvider.autoDispose<List<MediaAsset>>((ref) async {
  if (demoMode || reviewSession) {
    return [
      MediaAsset(id: '1', title: 'SIOP 2026 Logo Pack', kind: 'document', url: ''),
      MediaAsset(id: '2', title: 'Congress Programme PDF', kind: 'document', url: ''),
      MediaAsset(id: '3', title: 'Press Photo Gallery', kind: 'image', url: ''),
    ];
  }
  final data = await supabase
      .from('media_assets')
      .select('id, title, kind, url')
      .order('created_at', ascending: false)
      .limit(50);
  return (data as List)
      .cast<Map<String, dynamic>>()
      .map(MediaAsset.fromMap)
      .toList();
});
