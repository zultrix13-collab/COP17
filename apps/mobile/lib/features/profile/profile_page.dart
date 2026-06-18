import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env.dart';
import '../../core/widgets/error_view.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_repository.dart';
import 'profile_repository.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context)!;
    final profileAsync = ref.watch(profileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: ErrorView(error: e)),
        data: (p) {
          if (p == null) return Center(child: Text(l10n.profileNotFound));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFDCFCE7),
                    child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '👤'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(p.name.isEmpty ? p.email : p.name,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF888888)),
                            tooltip: l10n.editName,
                            onPressed: () async {
                              final ctrl = TextEditingController(text: p.name);
                              final result = await showDialog<String>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.editName),
                                  content: TextField(
                                    controller: ctrl,
                                    autofocus: true,
                                    decoration: const InputDecoration(border: OutlineInputBorder()),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text(l10n.cancel),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                                      child: Text(l10n.save),
                                    ),
                                  ],
                                ),
                              );
                              ctrl.dispose();
                              if (result != null && result.isNotEmpty && context.mounted) {
                                await ref.read(profileRepositoryProvider).updateName(result);
                                ref.invalidate(profileStreamProvider);
                              }
                            },
                          ),
                        ]),
                        Text(p.email,
                            style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${l10n.accessTierLabel}: ${p.tier}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push('/profile/digital-id'),
                icon: const Icon(Icons.qr_code_2),
                label: Text(l10n.digitalIdQr),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.push('/profile/language'),
                icon: const Icon(Icons.language),
                label: Text(l10n.languageTitle),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  reviewSession = false;
                  await ref.read(authRepositoryProvider).signOut();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(l10n.signOut, style: const TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      ),
    );
  }
}
