import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'features/chat/data/chat_notifications.dart';
import 'features/settings/providers/settings_providers.dart';
import 'l10n/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.validate();

  // Idioma antes del primer frame (sin parpadeo) y nombres de días/meses
  // de intl para los formatos de fecha
  startupLanguage = await loadAppLanguage();
  setAppLocale(localeFor(startupLanguage) ?? deviceLocale);
  await initializeDateFormatting();

  // Persiste la sesión en el dispositivo y refresca el JWT automáticamente.
  // TODO: migrar a publishableKey cuando el proyecto de Supabase (y el web) usen
  // las keys nuevas; hoy usamos la anon key legacy, igual que haki-app.
  // ignore: deprecated_member_use
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  // Push (FCM). En Android lee android/app/google-services.json; sin config
  // (iOS sin GoogleService-Info.plist) la app anda igual, sin push.
  try {
    await Firebase.initializeApp();
    // Push del chat con la app en segundo plano o cerrada
    FirebaseMessaging.onBackgroundMessage(chatPushBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase no configurado: sin push ($e)');
  }

  runApp(const ProviderScope(child: HakiApp()));
}
