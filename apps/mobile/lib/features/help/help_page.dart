import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_client.dart';

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  Future<void> _sendLocationSos(BuildContext context) async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      await supabase.from('alerts_incidents').insert({
        'severity': 'critical',
        'title': 'SOS from user',
        'body': 'location=${pos.latitude},${pos.longitude}',
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Байршил илгээгдлээ · Ops team мэдэгдэнэ')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Тусламж')),
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
              const Text('🚨 Яаралтай тусламж',
                  style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
                    onPressed: () {}, // dial 103 via url_launcher
                    icon: const Icon(Icons.local_hospital_outlined),
                    label: const Text('103 Эмнэлэг'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
                    onPressed: () {},
                    icon: const Icon(Icons.local_police_outlined),
                    label: const Text('102 Цагдаа'),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFB45309)),
                onPressed: () => _sendLocationSos(context),
                icon: const Icon(Icons.share_location),
                label: const Text('Миний байршил явуулах'),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          _Tile(
            title: '🤖 AI Chatbot',
            subtitle: 'SIOP мэдээлэл, FAQ, хөтөлбөр',
            onTap: () => context.push('/information/chatbot'),
          ),
          _Tile(
            title: '📞 Оператортой холбогдох',
            subtitle: 'Хүн хариулах · 08:00–22:00',
            onTap: () {},
          ),
          _Tile(
            title: '📋 Яаралтай журам',
            subtitle: 'Гал, газар хөдлөлт, эрүүл мэнд',
            onTap: () {},
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
  const _Tile({required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
