import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';

bool _dateDataLoaded = false;

/// Also works in standalone share cards without the app's localization loader.
String displayDate(BuildContext context, DateTime date) {
  if (!_dateDataLoaded) {
    // The bundled local initializer installs symbols and patterns synchronously,
    // then returns an already-completed Future; it performs no I/O.
    unawaited(initializeDateFormatting());
    _dateDataLoaded = true;
  }
  final code = AppLocalizations.of(context)?.localeName ??
      Localizations.localeOf(context).languageCode;
  return DateFormat.yMMMd(DateFormat.localeExists(code) ? code : 'en').format(date);
}
