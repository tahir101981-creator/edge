import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// The same saved override and English fallback as the foreground application.
/// Reload preferences because a background isolate has a separate cache.
Future<AppLocalizations> backgroundLocalizations() async {
  String? code;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    code = prefs.getString('locale_override');
  } catch (_) {
    // Localization must not prevent presentation when preferences are unavailable.
  }
  final supported = AppLocalizations.supportedLocales;
  final candidates = [
    if (code != null) Locale(code),
    ...PlatformDispatcher.instance.locales,
  ];
  final locale = candidates.firstWhere(
    (candidate) => supported.any((s) => s.languageCode == candidate.languageCode),
    orElse: () => const Locale('en'),
  );
  return AppLocalizations.delegate.load(Locale(locale.languageCode));
}
