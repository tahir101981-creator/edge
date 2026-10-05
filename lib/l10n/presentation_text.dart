import 'app_localizations.dart';
import 'display_text.dart';

/// Known formatted presentation values and absence reasons, never storage keys.
String presentationText(AppLocalizations? l, String text) {
  if (l == null) return text;
  final literal = localizedText(l, text);
  if (literal != text) return literal;
  final countSuffix = RegExp(r'^(.*?) There were (\d+), and it needs (\d+)\.$').firstMatch(text);
  if (countSuffix != null) {
    return l.supplementReasonCount(localizedText(l, countSuffix[1]!), countSuffix[2]!, countSuffix[3]!);
  }
  final needNights = RegExp(r'^Need (\d+) more nights?$').firstMatch(text);
  if (needNights != null) return l.supplementNeedNights(int.parse(needNights[1]!));
  final needDays = RegExp(r'^Wear (\d+) more days? to unlock$').firstMatch(text);
  if (needDays != null) return l.supplementNeedDays(int.parse(needDays[1]!));
  final of = RegExp(r'^(.*?) of (.*?) (nights|days|doses)$').firstMatch(text);
  if (of != null) return l.supplementCountOf(of[1]!, of[2]!, localizedText(l, of[3]!));
  final outOf = RegExp(r'^of (.*?)$').firstMatch(text);
  if (outOf != null) return l.supplementOutOf(presentationText(l, outOf[1]!));
  final duration = RegExp(r'^(?:(\d+)h )?(\d+)m$').firstMatch(text);
  if (duration != null) {
    return duration[1] == null
        ? l.supplementMinutesValue(duration[2]!)
        : l.supplementHoursMinutesValue(duration[1]!, duration[2]!);
  }
  final valueUnit = RegExp(r'^([+−\-\d., ]+) (bpm|ms|kg|km|m|kcal|br/min|min)$').firstMatch(text);
  if (valueUnit != null) return '${valueUnit[1]} ${localizedText(l, valueUnit[2]!)}';
  return text;
}
