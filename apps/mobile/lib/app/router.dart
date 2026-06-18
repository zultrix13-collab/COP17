import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/auth_repository.dart';
import '../features/home/home_page.dart';
import '../features/onboarding/splash_page.dart';
import '../features/onboarding/email_page.dart';
import '../features/onboarding/otp_page.dart';
import '../features/onboarding/language_page.dart';
import '../features/onboarding/permission_page.dart';
import '../features/onboarding/welcome_page.dart';
import '../features/programme/programme_page.dart';
import '../features/programme/session_detail_page.dart';
import '../features/programme/feedback_page.dart';
import '../features/programme/my_agenda_page.dart';
import '../features/scanner/scanner_page.dart';
import '../features/information/information_page.dart';
import '../features/information/chatbot_page.dart';
import '../features/help/help_page.dart';
import '../features/media/media_page.dart';
import '../features/b2b/b2b_page.dart';
import '../features/services/services_page.dart';
import '../features/services/wallet_page.dart';
import '../features/services/top_up_page.dart';
import '../features/services/catalog_page.dart';
import '../features/services/lost_found_page.dart';
import '../features/map/map_page.dart';
import '../features/profile/profile_page.dart';
import '../features/profile/digital_id_page.dart';
import '../features/shell/main_shell.dart';
import '../core/env.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final notifier = _AuthChangeNotifier(repo);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (ctx, state) {
      if (demoMode || reviewSession) return null;
      final isAuthed = repo.currentSession != null;
      final loc = state.matchedLocation;
      final onboarding = loc.startsWith('/onboarding') || loc == '/splash';
      if (!isAuthed && !onboarding) return '/onboarding/email';
      if (isAuthed && onboarding && loc != '/splash') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/onboarding/email', builder: (_, __) => const EmailPage()),
      GoRoute(
        path: '/onboarding/otp',
        builder: (_, state) => OtpPage(email: (state.extra as String?) ?? ''),
      ),
      GoRoute(
          path: '/onboarding/permission',
          builder: (_, __) => const PermissionPage()),
      GoRoute(
          path: '/onboarding/welcome', builder: (_, __) => const WelcomePage()),
      GoRoute(
          path: '/profile/digital-id',
          builder: (_, __) => const DigitalIdPage()),
      GoRoute(
          path: '/profile/language',
          builder: (_, __) => const LanguagePage()),
      GoRoute(
          path: '/programme/agenda', builder: (_, __) => const MyAgendaPage()),
      GoRoute(path: '/scanner', builder: (_, __) => const ScannerPage()),
      GoRoute(
          path: '/information/chatbot',
          builder: (_, __) => const ChatbotPage()),
      GoRoute(path: '/help', builder: (_, __) => const HelpPage()),
      GoRoute(path: '/media', builder: (_, __) => const MediaPage()),
      GoRoute(path: '/b2b', builder: (_, __) => const B2BPage()),
      GoRoute(
          path: '/b2b/meetings', builder: (_, __) => const MyMeetingsPage()),
      GoRoute(
        path: '/b2b/:id',
        builder: (_, state) =>
            MeetingRequestPage(exhibitorId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/services/wallet', builder: (_, __) => const WalletPage()),
      GoRoute(path: '/services/top-up', builder: (_, __) => const TopUpPage()),
      GoRoute(
          path: '/services/lost-found',
          builder: (_, __) => const LostFoundPage()),
      GoRoute(
        path: '/services/catalog/:kind',
        builder: (_, state) => CatalogPage(kind: state.pathParameters['kind']!),
      ),
      GoRoute(
        path: '/services/checkout/:kind',
        builder: (_, state) =>
            CheckoutPage(kind: state.pathParameters['kind']!),
      ),
      GoRoute(
        path: '/programme/:id',
        builder: (_, state) =>
            SessionDetailPage(sessionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/programme/:id/feedback',
        builder: (_, state) =>
            FeedbackPage(sessionId: state.pathParameters['id']!),
      ),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(
              path: '/programme', builder: (_, __) => const ProgrammePage()),
          GoRoute(
              path: '/information',
              builder: (_, __) => const InformationPage()),
          GoRoute(path: '/services', builder: (_, __) => const ServicesPage()),
          GoRoute(path: '/map', builder: (_, __) => const MapPage()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ],
      ),
    ],
  );
});

/// Notifies GoRouter when the Supabase session changes so `redirect` reruns.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(AuthRepository repo) {
    _sub = repo.onAuthStateChange().listen((_) => notifyListeners());
  }
  late final StreamSubscription<AuthState> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
