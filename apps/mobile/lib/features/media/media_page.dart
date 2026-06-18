import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/error_view.dart';
import '../../l10n/app_localizations.dart';
import 'media_repository.dart';

class MediaPage extends ConsumerWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context)!;
    final assetsAsync = ref.watch(mediaAssetsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mediaTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(mediaAssetsProvider),
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(l10n.liveBroadcast,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(l10n.openingCeremonyVenue,
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 6),
                  const Chip(
                    label: Text('● LIVE', style: TextStyle(color: Colors.red)),
                    backgroundColor: Colors.white24,
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.mic_outlined),
                title: Text(l10n.interviewBooking),
                subtitle: Text(l10n.pressBadgeRequired),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(l10n.comingSoon))),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 4),
            assetsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(error: e, compact: true,
                  onRetry: () => ref.invalidate(mediaAssetsProvider)),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l10n.noMediaAssets,
                          style: const TextStyle(color: Color(0xFF888888))),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final asset in list)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.folder_zip_outlined),
                          title: Text(asset.title,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(asset.kind),
                          trailing: const Icon(Icons.download),
                          onTap: () => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(l10n.comingSoon))),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
