import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/api_client.dart';
import '../programme/programme_repository.dart';

/// Ops-staff screen: pick the session they're checking into, then scan
/// attendee digital-ID QRs. Each successful scan hits `/qr/check-in` on the API.
class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});
  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  String? _sessionId;
  final _controller = MobileScannerController();
  String? _lastMsg;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handle(String token) async {
    if (_sessionId == null || _busy) return;
    setState(() { _busy = true; _lastMsg = null; });
    try {
      final res = await ref.read(apiClientProvider).post(
        '/qr/check-in',
        data: {'token': token, 'sessionId': _sessionId},
      );
      setState(() => _lastMsg = '✓ Checked in: ${res.data['userId']}');
    } catch (e) {
      setState(() => _lastMsg = 'Error: $e');
    } finally {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('Check-in scanner')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: sessionsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (list) => DropdownButtonFormField<String>(
              value: _sessionId,
              hint: const Text('Session сонгох'),
              items: list
                  .map((s) => DropdownMenuItem(value: s.id, child: Text(s.titleMn)))
                  .toList(),
              onChanged: (v) => setState(() => _sessionId = v),
            ),
          ),
        ),
        Expanded(
          child: Stack(children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final raw = capture.barcodes.firstOrNull?.rawValue;
                if (raw != null) _handle(raw);
              },
            ),
            if (_sessionId == null)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Text('Session сонгоно уу', style: TextStyle(color: Colors.white)),
                ),
              ),
          ]),
        ),
        if (_lastMsg != null)
          Container(
            padding: const EdgeInsets.all(12),
            color: _lastMsg!.startsWith('✓') ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            width: double.infinity,
            child: Text(_lastMsg!, textAlign: TextAlign.center),
          ),
      ]),
    );
  }
}
