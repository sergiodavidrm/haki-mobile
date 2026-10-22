import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';

// Config global de los tests: los formatos de fecha usan intl (como main).
// El idioma queda en español (default de lib/l10n/l10n.dart).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await initializeDateFormatting();
  await testMain();
}
