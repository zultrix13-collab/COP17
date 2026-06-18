import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';

/// App display language. Defaults to English; the user can switch to Mongolian
/// from the language picker, and the choice persists across restarts.
final localeProvider = StateNotifierProvider<LocaleController, Locale>(
  (ref) => LocaleController(),
);

class LocaleController extends StateNotifier<Locale> {
  LocaleController([super.initial = const Locale('en')]);

  /// Read the persisted locale before `runApp` so the first frame is correct.
  static Future<Locale> load() async {
    final prefs = await SharedPreferences.getInstance();
    return Locale(prefs.getString(_localeKey) ?? 'en');
  }

  Future<void> set(String code) async {
    state = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }
}
