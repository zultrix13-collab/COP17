import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'info_repository.dart';

class _Msg {
  final String who;
  final String text;
  _Msg(this.who, this.text);
}

class ChatbotPage extends ConsumerStatefulWidget {
  const ChatbotPage({super.key});
  @override
  ConsumerState<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends ConsumerState<ChatbotPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [
    _Msg('bot', 'Сайн байна уу! COP17 хөтөлбөр, байршил, FAQ асуултууд дээр туслая.'),
  ];
  bool _busy = false;

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() {
      _msgs.add(_Msg('you', text));
      _busy = true;
      _input.clear();
    });
    _scrollToBottom();
    try {
      final res = await ref.read(infoRepositoryProvider).chat(text, 'mn');
      setState(() => _msgs.add(_Msg('bot', res['answer'] as String)));
    } catch (e) {
      setState(() => _msgs.add(_Msg('bot', 'Алдаа: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI туслах')),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            itemCount: _msgs.length,
            itemBuilder: (_, i) => _Bubble(m: _msgs[i]),
          ),
        ),
        if (_busy) const LinearProgressIndicator(minHeight: 2),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  decoration: const InputDecoration(
                    hintText: 'Асуулт бичих…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                onPressed: _send,
                icon: const Icon(Icons.send),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Msg m;
  const _Bubble({required this.m});
  @override
  Widget build(BuildContext context) {
    final me = m.who == 'you';
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: me ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          m.text,
          style: TextStyle(color: me ? Colors.white : Colors.black87, fontSize: 13),
        ),
      ),
    );
  }
}
