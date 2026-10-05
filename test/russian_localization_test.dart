import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openstrap_edge/l10n/app_localizations.dart';
import 'package:openstrap_edge/l10n/app_localizations_ru.dart';
import 'package:openstrap_edge/state/locale_controller.dart';
import 'package:openstrap_edge/ui2/activity/catalogue.dart';
import 'package:openstrap_edge/ui2/ui2.dart';

// Read message arguments, treating the braces around ICU options as syntax.
Set<String> messageVariables(String text) {
  final result = <String>{};
  var i = 0;
  String word() {
    while (i < text.length && text[i].trim().isEmpty) {
      i++;
    }
    final start = i;
    while (i < text.length && RegExp(r'[A-Za-z0-9_=]').hasMatch(text[i])) {
      i++;
    }
    return text.substring(start, i);
  }

  void message({bool nested = false}) {
    while (i < text.length) {
      if (text[i] == '}' && nested) {
        i++;
        return;
      }
      if (text[i] != '{') {
        i++;
        continue;
      }
      i++;
      result.add(word());
      while (i < text.length && text[i].trim().isEmpty) {
        i++;
      }
      if (i < text.length && text[i] == '}') {
        i++;
        continue;
      }
      if (i >= text.length || text[i++] != ',') {
        throw FormatException(text);
      }
      final kind = word();
      if (kind != 'plural' && kind != 'select' && kind != 'selectordinal') {
        throw FormatException('Unsupported ICU message: $text');
      }
      while (i < text.length && text[i].trim().isEmpty) {
        i++;
      }
      if (i >= text.length || text[i++] != ',') {
        throw FormatException(text);
      }
      while (i < text.length) {
        while (i < text.length && text[i].trim().isEmpty) {
          i++;
        }
        if (text[i] == '}') {
          i++;
          break;
        }
        word();
        while (i < text.length && text[i].trim().isEmpty) {
          i++;
        }
        if (i >= text.length || text[i++] != '{') {
          throw FormatException(text);
        }
        message(nested: true);
      }
    }
  }

  message();
  return result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Russian ARB preserves every message and placeholder type', () {
    Map<String, dynamic> read(String code) =>
        jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
            as Map<String, dynamic>;
    final en = read('en');
    final ru = read('ru');
    Set<String> keys(Map<String, dynamic> data) =>
        data.keys.where((k) => !k.startsWith('@')).toSet();
    expect(ru['@@locale'], 'ru');
    expect(keys(ru), keys(en));
    for (final key in keys(en)) {
      expect((ru[key] as String).trim(), isNotEmpty, reason: key);
      expect(messageVariables(ru[key]), messageVariables(en[key]), reason: key);
      final ep = (en['@$key'] as Map?)?['placeholders'] as Map?;
      final rp = (ru['@$key'] as Map?)?['placeholders'] as Map?;
      for (final name in ep?.keys ?? <String>[]) {
        expect(rp?[name]?['type'], ep?[name]?['type'], reason: '$key.$name');
      }
    }
  });

  test('generated Russian plurals use one, few and many', () {
    final l = AppLocalizationsRu();
    expect(l.profileSourcesCount(1), '1 источник');
    expect(l.profileSourcesCount(2), '2 источника');
    expect(l.profileSourcesCount(5), '5 источников');
    expect(l.profileSourcesCount(21), '21 источник');
    expect(l.welcomeWorkoutsCount(22), '22 тренировки');
    expect(l.welcomeWorkoutsCount(25), '25 тренировок');
  });

  test(
    'Russian override survives bootstrap and system choice clears it',
    () async {
      SharedPreferences.setMockInitialValues({});
      final controller = await LocaleController.bootstrap();
      expect(controller.locale, isNull);
      await controller.setCode('ru');
      expect((await LocaleController.bootstrap()).locale, const Locale('ru'));
      await controller.setCode('en');
      expect((await LocaleController.bootstrap()).locale, const Locale('en'));
      await controller.setCode(null);
      expect((await LocaleController.bootstrap()).locale, isNull);
      controller.dispose();
    },
  );

  testWidgets('Russian tabs and activity names fit a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.light),
        home: AppShell(
          builder: (context, domain) =>
              Text(allActivities.first.displayName(context)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Бег'), findsOneWidget);
    for (final title in [
      'Главная',
      'Здоровье',
      'Питание',
      'Тренировка',
      'Самочувствие',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    expect(allActivities.first.typeKey, 'running');
  });
}
