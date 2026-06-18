import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

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

  static String friendlyMessage(AppL10n l10n, Object error) {
    final s = error.toString().toLowerCase();
    if (s.contains('socketexception') || s.contains('networkerror') || s.contains('failed host lookup')) {
      return l10n.errNetwork;
    }
    if (s.contains('rate limit') || s.contains('too many') || s.contains('429')) {
      return l10n.errTooMany;
    }
    if (s.contains('user not found') || s.contains('email not confirmed') || s.contains('invalid login')) {
      return l10n.errEmailNotRegistered;
    }
    if (s.contains('otp') || s.contains('token') && s.contains('invalid')) {
      return l10n.errOtpInvalid;
    }
    if (s.contains('401') || s.contains('unauthorized') || s.contains('not authenticated')) {
      return l10n.errAuthRequired;
    }
    if (s.contains('timeout') || s.contains('timeoutexception') || s.contains('receivetimeout')) {
      return l10n.errTimeout;
    }
    return l10n.errGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context)!;
    final msg = friendlyMessage(l10n, error);
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
              child: Text(
                l10n.retryShort,
                style: const TextStyle(
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
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
