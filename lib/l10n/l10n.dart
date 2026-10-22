import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

// Textos de la app (gen-l10n): lib/l10n/app_es.arb (plantilla) y app_en.arb.
// En widgets: `context.l10n.clave` (se reconstruye al cambiar de idioma).
// Sin BuildContext (formatos, mappers, notificaciones): `l10n.clave`, que usa
// el idioma activo que fija HakiApp con setAppLocale.

/// Idiomas soportados: inglés si el teléfono está en inglés, si no español.
const supportedLocales = [Locale('es'), Locale('en')];

Locale _current = const Locale('es');

/// Idioma activo (el elegido en Ajustes o el del teléfono).
Locale get appLocale => _current;

/// Textos del idioma activo, para código sin BuildContext.
AppLocalizations get l10n => lookupAppLocalizations(_current);

/// Lo llama HakiApp cada vez que cambia el idioma.
void setAppLocale(Locale locale) {
  _current = locale;
  Intl.defaultLocale = locale.languageCode;
}

/// Inglés si [locale] es inglés; cualquier otro idioma → español.
Locale resolveLocale(Locale? locale) =>
    locale?.languageCode == 'en' ? const Locale('en') : const Locale('es');

/// El del teléfono, resuelto a uno soportado.
Locale get deviceLocale => resolveLocale(PlatformDispatcher.instance.locale);

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Ajustes → Idioma: Sistema (el del teléfono), Español o English.
enum AppLanguage { system, es, en }

const _languageKey = 'app_language';

/// Preferencia guardada en el teléfono (main la lee antes de arrancar; el
/// handler de push en segundo plano también).
Future<AppLanguage> loadAppLanguage() async =>
    AppLanguage.values.asNameMap()[await SharedPreferencesAsync().getString(
      _languageKey,
    )] ??
    AppLanguage.system;

Future<void> saveAppLanguage(AppLanguage language) =>
    SharedPreferencesAsync().setString(_languageKey, language.name);

/// null = el del teléfono (MaterialApp lo resuelve con resolveLocale).
Locale? localeFor(AppLanguage language) => switch (language) {
  AppLanguage.system => null,
  AppLanguage.es => const Locale('es'),
  AppLanguage.en => const Locale('en'),
};
