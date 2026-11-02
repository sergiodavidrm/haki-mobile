import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'keyboard_guard.g.dart';

/// Bug (2026-11-02): si la app se iba a segundo plano con el teclado abierto
/// (p. ej. cargando una serie), al volver Flutter seguía con el espacio del
/// teclado (`viewInsets.bottom`) aunque ya no estuviera: cada pantalla achicaba
/// su contenido y quedaba un bloque negro abajo, en todos los tabs.
///
/// Al irse: se saca el foco (el teclado se cierra y la fila de la serie que se
/// estaba cargando se guarda sola, como al salir de ella). Al volver, si nada
/// tiene foco, se le pide al sistema que oculte el teclado para que vuelva a
/// informar el espacio en 0. Se arranca en app.dart.
@Riverpod(keepAlive: true)
void keyboardGuard(Ref ref) {
  final listener = AppLifecycleListener(
    onHide: () => FocusManager.instance.primaryFocus?.unfocus(),
    onResume: () {
      final focus = FocusManager.instance.primaryFocus;
      final editing = focus?.context?.widget is EditableText;
      if (!editing) {
        SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      }
    },
  );
  ref.onDispose(listener.dispose);
}
