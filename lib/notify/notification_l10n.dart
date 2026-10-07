import '../l10n/app_localizations.dart';
import '../l10n/display_text.dart';
import '../l10n/sweep_text.dart';

/// Adapt the existing English presentation contracts at the OS boundary.
/// Detectors, persisted findings, dedupe keys, schedules and routes stay intact.
/// Unknown text (including model-generated and user-provided text) is preserved.
String notificationText(AppLocalizations l, String text) {
  final sweep = sweepText(l, text);
  if (sweep != text) return sweep;
  final literal = localizedText(l, text);
  if (literal != text) return literal;
  String? match(String pattern, String Function(RegExpMatch) render) {
    final m = RegExp('^$pattern\$', dotAll: true).firstMatch(text);
    return m == null ? null : render(m);
  }

  final translated =
      match(r'Your band is at (.*?)%. Charge it soon\.',
          (m) => l.supplementNotificationLowBattery(m[1]!)) ??
      match(r'Recovery (.*?), slept (.*?)h (.*?)m\.',
          (m) => l.supplementNotificationRecoverySleep(m[1]!, m[2]!, m[3]!)) ??
      match(r'Recovery (.*?)\.', (m) => l.supplementNotificationRecovery(m[1]!)) ??
      match(r'You hit about (.*?) steps — at or above your (.*?) goal\.',
          (m) => l.supplementNotificationGoal(m[1]!, m[2]!)) ??
      match(r'Nothing above resting effort has been recorded for (.*?) minutes\. If the session is over, finish it from the Workout tab\.',
          (m) => l.supplementNotificationIdle(m[1]!)) ??
      match(r'No new data for about (.*?) hours\. Open OpenStrap to reconnect — background sync may have stalled\.',
          (m) => l.supplementNotificationStale(m[1]!)) ??
      match(r'Your bedtime is around (.*?)\. Start slowing down\.',
          (m) => l.supplementNotificationWindDown(m[1]!)) ??
      match(r'(.*?) things to look at', (m) => l.supplementNotificationFindings(m[1]!)) ??
      match(r'At (.*?)%/h it runs out around (.*?) — before you wake\. Charge it now to keep tonight.s sleep\.',
          (m) => l.supplementNotificationBatteryBefore(m[1]!, m[2]!)) ??
      match(r'At (.*?)%/h it runs out around (.*?), just after your usual wake time — about (.*?)% left when you get up\. Charge it now to keep tonight.s sleep\.',
          (m) => l.supplementNotificationBatteryLowWake(m[1]!, m[2]!, m[3]!)) ??
      match(r'At (.*?)%/h it runs out around (.*?), after your usual wake time\.',
          (m) => l.supplementNotificationBatteryAfter(m[1]!, m[2]!)) ??
      match(r'This week flagged: (.*?)\. Details live on Health\.',
          (m) => l.supplementNotificationWeeklyFlags(m[1]!.split(', ').map((part) => notificationText(l, part)).join(', '))) ??
      match(r'possible illness onset ×(.*?)', (m) => l.supplementNotificationIllnessCount(m[1]!)) ??
      match(r'unusual physiology ×(.*?)', (m) => l.supplementNotificationAnomalyCount(m[1]!)) ??
      match(r'elevated skin temperature ×(.*?)', (m) => l.supplementNotificationTemperatureCount(m[1]!)) ??
      match(r'Resting heart rate ran about (.*?) bpm higher late in the week than early\.',
          (m) => l.supplementNotificationWeeklyRhr(m[1]!));
  if (translated != null) return translated;
  if (text.startsWith('• ')) {
    return text.split('\n').map((line) {
      if (!line.startsWith('• ')) return line;
      final parts = line.substring(2).split(' — ');
      if (parts.length < 2) return line;
      // A finding title itself can contain an em dash. Try every boundary.
      for (var i = 1; i < parts.length; i++) {
        final title = parts.take(i).join(' — ');
        final localizedTitle = localizedText(l, title);
        if (localizedTitle != title) {
          return '• $localizedTitle — ${notificationText(l, parts.skip(i).join(' — '))}';
        }
      }
      return line;
    }).join('\n');
  }
  return text;
}
