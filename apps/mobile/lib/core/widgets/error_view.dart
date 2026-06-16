import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final bool compact;

  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  static String friendlyMessage(Object error) {
    final s = error.toString().toLowerCase();
    if (s.contains('socketexception') || s.contains('networkerror') || s.contains('failed host lookup')) {
      return 'Интернэт холболт алдаатай байна.';
    }
    if (s.contains('rate limit') || s.contains('too many') || s.contains('429')) {
      return 'Хэт олон удаа оролдлоо. 1 цагийн дараа дахин оролдоно уу.';
    }
    if (s.contains('user not found') || s.contains('email not confirmed') || s.contains('invalid login')) {
      return 'И-мэйл хаяг бүртгэлгүй байна. Зохион байгуулагчтай холбогдоно уу.';
    }
    if (s.contains('otp') || s.contains('token') && s.contains('invalid')) {
      return 'Код буруу эсвэл хугацаа дууссан байна. Дахин код авна уу.';
    }
    if (s.contains('401') || s.contains('unauthorized') || s.contains('not authenticated')) {
      return 'Нэвтрэх шаардлагатай. Та дахин нэвтэрнэ үү.';
    }
    if (s.contains('timeout') || s.contains('timeoutexception') || s.contains('receivetimeout')) {
      return 'Хүсэлт хугацаа дуусав. Дахин оролдоно уу.';
    }
    return 'Алдаа гарлаа. Дахин оролдоно уу.';
  }

  @override
  Widget build(BuildContext context) {
    final msg = friendlyMessage(error);
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(msg, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRetry,
              child: const Text(
                'Дахин',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1A6EF5),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: Color(0xFFCCCCCC)),
            const SizedBox(height: 12),
            Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF555555))),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Дахин оролдох'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
