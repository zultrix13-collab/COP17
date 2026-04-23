import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

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
    // Real impl: firebase_messaging.requestPermission() — stubbed for now.
    setState(() => _notifGranted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Зөвшөөрөл')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Апп илүү сайн ажиллахад зөвшөөрлүүд хэрэгтэй.'),
            const SizedBox(height: 12),
            _PermissionTile(
              icon: '📍',
              title: 'Байршил',
              subtitle: 'Яаралтай тусламж + алхалт тоолох',
              granted: _locationGranted,
              onGrant: _reqLocation,
            ),
            const SizedBox(height: 8),
            _PermissionTile(
              icon: '🔔',
              title: 'Мэдэгдэл',
              subtitle: 'Хуваарь, зарлал, яаралтай',
              granted: _notifGranted,
              onGrant: _reqNotif,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go('/onboarding/welcome'),
              child: const Text('Үргэлжлүүлэх →'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Settings-ээс өөрчлөх боломжтой',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
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
              : OutlinedButton(onPressed: onGrant, child: const Text('Зөвшөөрөх')),
        ],
      ),
    );
  }
}
