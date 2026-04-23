import 'package:flutter/material.dart';

class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('▶ ШУУД ДАМЖУУЛАЛТ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Opening Ceremony · State Palace (Төрийн ордон)',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                SizedBox(height: 6),
                Chip(
                  label: Text('● LIVE', style: TextStyle(color: Colors.red)),
                  backgroundColor: Colors.white24,
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.folder_zip_outlined),
              title: const Text('Press Kit'),
              subtitle: const Text('Логонууд, зураг, баримт бичиг'),
              trailing: const Icon(Icons.download),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mic_outlined),
              title: const Text('Ярилцлага захиалга'),
              subtitle: const Text('Press badge шаардлагатай'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
