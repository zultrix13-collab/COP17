import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/error_view.dart';
import '../auth/auth_repository.dart';
import 'profile_repository.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Профайл')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: ErrorView(error: e)),
        data: (p) {
          if (p == null) return const Center(child: Text('Профайл олдсонгүй'));
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
                        Text(p.name.isEmpty ? p.email : p.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(p.email,
                            style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('Tier: ${p.tier}',
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
                label: const Text('Дижитал үнэмлэх QR'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Гарах', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      ),
    );
  }
}
