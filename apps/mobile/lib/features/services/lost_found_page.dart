import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'services_repository.dart';

final _lostFoundProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, kind) {
  return ref.watch(servicesRepositoryProvider).lostFound(kind);
});

class LostFoundPage extends ConsumerStatefulWidget {
  const LostFoundPage({super.key});
  @override
  ConsumerState<LostFoundPage> createState() => _LostFoundPageState();
}

class _LostFoundPageState extends ConsumerState<LostFoundPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'Гээсэн'), Tab(text: 'Олдсон')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _List(kind: 'lost'),
          _List(kind: 'found'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Мэдэгдэл'),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _ReportSheet(),
        ),
      ),
    );
  }
}

class _List extends ConsumerWidget {
  final String kind;
  const _List({required this.kind});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(_lostFoundProvider(kind));
    final fmt = DateFormat('MMM d · HH:mm');
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('Хоосон', style: TextStyle(color: Color(0xFF888888))));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(_lostFoundProvider(kind)),
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = list[i];
              return ListTile(
                title: Text(r['title'] as String),
                subtitle: Text(
                  '${r['description'] ?? ''}\n${fmt.format(DateTime.parse(r['created_at'] as String))}',
                ),
                isThreeLine: true,
              );
            },
          ),
        );
      },
    );
  }
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet();
  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  String _kind = 'lost';
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _busy = false;

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(servicesRepositoryProvider).reportItem(
            kind: _kind,
            title: _title.text.trim(),
            description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
          );
      ref.invalidate(_lostFoundProvider(_kind));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'lost', label: Text('Гээсэн')),
            ButtonSegment(value: 'found', label: Text('Олдсон')),
          ],
          selected: {_kind},
          onSelectionChanged: (s) => setState(() => _kind = s.first),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _title,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Юу гээсэн/олдсон?',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _desc,
          minLines: 2, maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Нэмэлт тайлбар',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(_busy ? '…' : 'Илгээх'),
        ),
        const SizedBox(height: 12),
      ]),
    );
  }
}
