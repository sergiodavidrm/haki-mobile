import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.validate();

  // Persiste la sesión en el dispositivo y refresca el JWT automáticamente.
  // TODO: migrar a publishableKey cuando el proyecto de Supabase (y el web) usen
  // las keys nuevas; hoy usamos la anon key legacy, igual que haki-app.
  // ignore: deprecated_member_use
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  runApp(const ProviderScope(child: HakiApp()));
}
