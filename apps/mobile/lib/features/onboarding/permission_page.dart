import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});
  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool _locationGranted = false;
  bool _notifGranted = false;

  Future<void> _reqLocation() async {
    final perm = await Geolocator.requestPermission();
    setState(() => _locationGranted =
        perm == LocationPermission.always || perm == LocationPermission.whileInUse);
  }

  Future<void> _reqNotif() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    setState(() => _notifGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.permissionTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.permissionIntro),
            const SizedBox(height: 12),
            _PermissionTile(
              icon: '📍',
              title: l10n.permLocation,
              subtitle: l10n.permLocationDesc,
              granted: _locationGranted,
              onGrant: _reqLocation,
            ),
            const SizedBox(height: 8),
            _PermissionTile(
              icon: '🔔',
              title: l10n.permNotification,
              subtitle: l10n.permNotificationDesc,
              granted: _notifGranted,
              onGrant: _reqNotif,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go('/onboarding/welcome'),
              child: Text(l10n.continueBtn),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.permSettingsNote,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback onGrant;
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onGrant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
          ),
          granted
              ? const Icon(Icons.check_circle, color: Color(0xFF16A34A))
              : OutlinedButton(
                  onPressed: onGrant,
                  child: Text(AppL10n.of(context)!.grant)),
        ],
      ),
    );
  }
}
