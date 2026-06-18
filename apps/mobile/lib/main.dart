import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/locale.dart';
import 'core/supabase_client.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initSupabase();
  final savedLocale = await LocaleController.load();
  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith((ref) => LocaleController(savedLocale)),
      ],
      child: const SiopApp(),
    ),
  );
}

class SiopApp extends ConsumerWidget {
  const SiopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'SIOP',
      theme: buildSiopTheme(),
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
    );
  }
}
