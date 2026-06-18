import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/env.dart';
import '../../core/supabase_client.dart';
import '../../l10n/app_localizations.dart';

Future<void> _dial(String number) async {
  final uri = Uri.parse('tel:$number');
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  Future<void> _requestAccountDeletion(BuildContext context) async {
    final l10n = AppL10n.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountDialogTitle),
        content: Text(l10n.deleteAccountDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.deleteAccountCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final user = supabase.auth.currentUser;
    final email = user?.email ?? '';
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@siop.mn',
      queryParameters: {
        'subject': 'Account deletion request',
        'body': 'Please delete my account and all associated data.\n\nEmail: $email\n\nI understand this action is irreversible.',
      },
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendLocationSos(BuildContext context) async {
    if (demoMode || reviewSession) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context)!.locationSent)),
        );
      }
      return;
    }
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      final pos = await Geolocator.getCurrentPosition();
      await supabase.from('alerts_incidents').insert({
        'user_id': user.id,
        'severity': 'critical',
        'title': 'SOS from user',
        'body': 'location=${pos.latitude},${pos.longitude}',
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context)!.locationSent)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              border: Border.all(color: const Color(0xFFDC2626)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(l10n.emergencyHelp,
                  style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
                    onPressed: () => _dial('103'),
                    icon: const Icon(Icons.local_hospital_outlined),
                    label: Text(l10n.callMedical),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
                    onPressed: () => _dial('102'),
                    icon: const Icon(Icons.local_police_outlined),
                    label: Text(l10n.callPolice),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFB45309)),
                onPressed: () => _sendLocationSos(context),
                icon: const Icon(Icons.share_location),
                label: Text(l10n.sendMyLocation),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          _Tile(
            title: '🤖 AI Chatbot',
            subtitle: l10n.helpSiopInfo,
            onTap: () => context.push('/information/chatbot'),
          ),
          _Tile(
            title: l10n.contactOperator,
            subtitle: l10n.operatorHours,
            onTap: () => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(l10n.comingSoon))),
          ),
          _Tile(
            title: l10n.emergencyProcedures,
            subtitle: l10n.emergencyProceduresDesc,
            onTap: () => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(l10n.comingSoon))),
          ),
          const SizedBox(height: 8),
          const Divider(),
          _Tile(
            title: l10n.deleteAccountTitle,
            subtitle: l10n.deleteAccountSubtitle,
            onTap: () => _requestAccountDeletion(context),
            destructive: true,
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;
  const _Tile({required this.title, required this.subtitle, required this.onTap, this.destructive = false});
  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFDC2626) : null;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: onTap,
      ),
    );
  }
}
