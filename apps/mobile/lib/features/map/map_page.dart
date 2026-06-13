import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/widgets/error_view.dart';
import 'map_repository.dart';

/// UB Misheel Expo Center coords (venue placeholder).
const _defaultCenter = LatLng(47.9185, 106.9177);

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});
  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Газрын зураг'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'Дотоод'), Tab(text: 'Гадаад')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [_IndoorView(), _OutdoorView()],
      ),
    );
  }
}

class _IndoorView extends ConsumerWidget {
  const _IndoorView();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pois = ref.watch(poisProvider);
    return pois.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: ErrorView(error: e)),
      data: (list) {
        final indoor = list.where((p) => p.floor != null).toList()
          ..sort((a, b) => a.floor!.compareTo(b.floor!));
        if (indoor.isEmpty) return const Center(child: Text('POI алга'));
        final byFloor = <int, List<Poi>>{};
        for (final p in indoor) {
          byFloor.putIfAbsent(p.floor!, () => []).add(p);
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final entry in byFloor.entries) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('${entry.key} давхар',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF888888))),
              ),
              for (final p in entry.value)
                ListTile(
                  leading: Text(p.emoji, style: const TextStyle(fontSize: 20)),
                  title: Text(p.nameMn),
                  subtitle: Text(p.kind),
                  trailing: const Icon(Icons.directions),
                  onTap: () => _showDirections(context, p),
                ),
            ],
          ],
        );
      },
    );
  }

  void _showDirections(BuildContext context, Poi p) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${p.emoji} ${p.nameMn}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('${p.floor} давхар · ${p.kind}',
              style: const TextStyle(color: Color(0xFF888888))),
          const SizedBox(height: 20),
          const Icon(Icons.turn_right, size: 48, color: Color(0xFF1A6EF5)),
          const Text(
            'Turn-by-turn: QR checkpoint эсвэл BLE beacon-оор\nхолын зайг урьдчилан тооцно (MAP-04).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
        ]),
      ),
    );
  }
}

class _OutdoorView extends ConsumerWidget {
  const _OutdoorView();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pois = ref.watch(poisProvider);
    final markers = pois.maybeWhen(
      data: (list) => list
          .where((p) => p.point != null)
          .map((p) => Marker(
                point: p.point!,
                width: 30, height: 30,
                child: Tooltip(
                  message: p.nameMn,
                  child: Text(p.emoji, style: const TextStyle(fontSize: 20)),
                ),
              ))
          .toList(),
      orElse: () => <Marker>[],
    );
    return FlutterMap(
      options: const MapOptions(initialCenter: _defaultCenter, initialZoom: 14),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'mn.siop',
          // Swap for offline `FileTileProvider` + MBTiles to satisfy MAP-05.
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
