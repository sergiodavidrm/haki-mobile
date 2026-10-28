# haki-mobile — App móvil del atleta (Flutter)

App cara al **atleta** (cliente del coach). El coach sigue usando `haki-app`
(Angular). Consume la misma API de `haki-api` (.NET, `api/v1/...`).

Leer también el `CLAUDE.md` de la raíz (`haki/`) para contexto de producto.

## Stack

| Capa | Tecnología |
|---|---|
| Framework | Flutter 3.47 / Dart 3.13 |
| Estado | Riverpod 3 con code generation (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`) |
| Codegen | `build_runner` |
| Auth | Supabase (`supabase_flutter`) — email/password o Google (`google_sign_in` nativo + `signInWithIdToken`) |
| HTTP | `dio` (cliente en `core/network/api_client.dart`) |
| Navegación | `go_router` |
| Chat | Stream Chat con `stream_chat_flutter_core` (sin la UI del SDK: pantallas propias con el kit) |
| Plataformas | Android + iOS (iOS solo compila en Mac) |

Bundle id: `com.hakifit.haki_mobile`.

## Comandos

```bash
flutter run --dart-define-from-file=env/dev.json    # correr en emulador/dispositivo
dart run build_runner watch -d                      # codegen de providers en vivo
dart run build_runner build -d                      # codegen una vez
flutter analyze
flutter test
```

Los archivos `*.g.dart` son generados: no editarlos a mano.

Para probar contra la API local: correr `haki-api` con el perfil `https` o
`http` (los dos escuchan en http 5073; en Development la API no redirige a
https). La app usa `http://10.0.2.2:5073` porque el emulador no confía en el
certificado https de desarrollo (`HandshakeException`). Desde el emulador de
Android la PC es `10.0.2.2`; desde un teléfono físico, la IP de la PC en la red
local.

## Config por ambiente

- `env/<ambiente>.json` (gitignored; versionado solo `env/example.json`) con
  `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `STREAM_API_KEY`, `API_URL` (incluye
  `/api/v1`). Se inyecta con `--dart-define-from-file` y se lee en
  `core/config/env.dart` (`Env.validate()` falla si falta algo).
- **Todo lo que va en la app es público** (se puede descompilar). Anon key de
  Supabase y API key de Stream son públicas por diseño; **nunca** secretos
  (secret de Stream, service key de Supabase, connection string). El token de
  usuario de Stream lo genera el backend.
- `android/app/src/debug/AndroidManifest.xml` permite cleartext (http) **solo
  en debug**.

## Convenciones de estado (Riverpod)

- Usar **siempre** la sintaxis con `@riverpod` (codegen), no providers manuales.
- La app está envuelta en `ProviderScope` en `main.dart`.
- Lógica de negocio y llamadas a la API van en providers/notifiers o
  repositorios, **no en los widgets** (equivalente a los Signal Stores de
  `haki-app`).
- Widgets que leen estado: `ConsumerWidget` / `ConsumerStatefulWidget`.
- `ref.watch` en `build`, `ref.read` en callbacks (onPressed, etc.).
- Datos async: `Future`/`Stream` en el provider y en la UI `AsyncValue.when(...)`
  (o `switch`) para loading/error/data.

```dart
@riverpod
class Workouts extends _$Workouts {
  @override
  Future<List<Workout>> build() => ref.read(workoutsRepositoryProvider).getAll();
}
```

## Estructura (feature-first)

```
lib/
├── main.dart      → Env.validate + Supabase.initialize + ProviderScope
├── app.dart       → MaterialApp.router (tema + router)
├── core/
│   ├── config/    → env.dart
│   ├── network/   → apiClientProvider (dio + JWT de Supabase)
│   ├── supabase/  → supabaseClientProvider
│   ├── router/    → appRouterProvider (rutas + redirect por sesión)
│   ├── theme/     → HakiColors (tokens) + buildAppTheme
│   ├── widgets/   → componentes reutilizables (HakiLogo / HakiLogoMark…)
│   └── db/        → (futuro) drift: sesión en curso + outbox
└── features/
    └── <feature>/
        ├── data/      → dtos + repository (llamadas a la API)
        ├── providers/ → providers/notifiers Riverpod
        └── ui/        → screens y widgets
```

Los DTOs de la API van en `data/` de cada feature (mismo criterio que
`dtos/` en `haki-app`).

**Flujo:** widget → provider/notifier → repository → API y/o BD local. Un
widget nunca llama a `dio` directo.

**Login con Google:** nativo (`google_sign_in` 7 → id token →
`auth.signInWithIdToken`), sin navegador ni deep links. Necesita
`GOOGLE_WEB_CLIENT_ID` (el Client ID *Web* configurado en Supabase → Google) y,
en iOS, `GOOGLE_IOS_CLIENT_ID`. En Google Cloud hay que crear un OAuth client
**Android** con el package `com.hakifit.haki_mobile` + SHA-1 de la firma (uno
por keystore: debug de cada PC y release). Supabase vincula Google al usuario
existente si el email coincide y está confirmado (con el código o con Google)
→ mismo `userId` en haki-api.

**Coach archivó o eliminó al atleta (2026-10-22):** `/auth/me` trae
`accessEndsAt` (7 días después). Mientras tanto Hoy muestra un aviso
(`_AccessEndingCard`); pasada la fecha `AthleteGate` muestra "Tu coach terminó
tu plan…" + cerrar sesión (compara con la hora del teléfono, sirve offline con
la caché de `/auth/me`).

**`AthleteGate`** (envuelve las rutas protegidas): cualquiera crea sesión en
Supabase (Google o Crear cuenta), así que se chequea `GET /auth/me`. Si no
existe en haki-api → `InvitationGate` (`auth/ui/invitation_screen.dart`):
`GET invitations/me` → "Tenés una invitación" (coach, años de experiencia,
email) + **Aceptar** (`POST invitations/{id}/accept`, después
`expire(wait: true)` + recarga `/auth/me` → entra a la app) o "No
encontramos tu invitación" (entrar con otra cuenta / volver a buscar). Un
coach ve un mensaje + cerrar sesión. Queda un usuario huérfano en
`auth.users` si nunca acepta (aceptado).

**Crear cuenta (2026-10-25):** Login → "¿Primera vez? Creá tu cuenta" →
`/registro` (email, contraseña con requisitos en vivo: `PasswordChecks` en
`auth/data/password_policy.dart`, misma regla que Supabase y el web; repetir)
→ `signUp` (sin sesión: Supabase tiene "Confirm email") → `/registro/codigo`
(6 dígitos del email, confirma solo al completarlos, `verifyOTP` tipo
`signup`, reenviar cada 60 s). Al confirmar aparece la sesión y el router
manda a Hoy → `AthleteGate` → invitación. Si en el Login da
`email_not_confirmed` (creó la cuenta y no puso el código): botón "Ingresar
el código del email" (reenvía y abre esa pantalla). Si el email ya tenía
cuenta, Supabase no avisa ni manda código (para no revelar emails): la
pantalla dice "¿Ya tenés cuenta? Iniciá sesión".

**Auth/navegación:** el login no navega; `appRouterProvider` escucha
`onAuthStateChange` y el `redirect` manda a `/login` o `/` según haya sesión.
Para agregar rutas protegidas basta con sumarlas al `GoRouter`.

## Branding y tema

Paleta **Obsidian/Gold/Turquoise** (UI dark del atleta):
`#0D0D0D` obsidian · `#B8922A` gold · `#00C4B4` turquoise. Fuente: Inter
(pendiente de agregar como asset; hoy usa la default).

- Tokens en `core/theme/haki_colors.dart` (`HakiColors`, un `ThemeExtension`)
  y `ThemeData` en `core/theme/app_theme.dart`.
- **Tema claro y oscuro (2026-10-20):** `HakiColors.obsidian` (oscuro) y
  `HakiColors.light` (mockup "Tema claro · propuesta": fondo `#F7F6F3`,
  dorado/turquesa de texto más oscuros `#7A5C0C` / `#00766C`, texto tenue
  `#575757`).
  `buildAppTheme(c, brightness:)`; en `app.dart` `theme` / `darkTheme` /
  `themeMode` = `AppThemeMode` (Ajustes → Apariencia → Sistema/Claro/Oscuro,
  `shared_preferences` `theme_mode`, default Sistema). Texto/íconos **sobre
  dorado o turquesa** usan `onAccent` (oscuro en los dos), nunca `background`.
  El splash queda siempre oscuro (marca, empalma con el nativo). Barra de
  estado con `AnnotatedRegion` según el tema.
- En widgets: `context.colors.gold`. **Prohibido `Color(0x...)` fuera de
  `core/theme/`.** Cambiar de paleta = otro `HakiColors` en `app.dart`.
- Preferir estilos del tema (`inputDecorationTheme`, `filledButtonTheme`…)
  antes que estilos inline.

## Idioma (es / en, 2026-10-21)

Flutter gen-l10n (`l10n.yaml`): textos en `lib/l10n/app_es.arb` (plantilla,
con los `@metadatos` de placeholders) y `app_en.arb` (~360 claves, mismas en
los dos; `flutter gen-l10n` falla si falta alguna). Los `app_localizations*.dart`
son generados (se regeneran al compilar; se commitean).

- **Idioma:** Ajustes → Apariencia → Idioma: Sistema / ES / EN
  (`AppLanguageSetting`, shared_preferences `app_language`). Sistema = inglés si
  el teléfono está en inglés, cualquier otro → español (`resolveLocale`). `main`
  lo lee antes del primer frame.
- **En widgets:** `context.l10n.clave` (se reconstruye al cambiar el idioma).
  `const Text('...')` → `Text(context.l10n.x)` (sin const).
- **Sin BuildContext** (formatos, mappers, notificaciones, errores): `l10n.clave`
  de `lib/l10n/l10n.dart`, que usa el idioma activo (`setAppLocale`, lo fija
  `MaterialApp.localeResolutionCallback`). El handler de push en segundo plano
  (otro isolate) lee la preferencia y llama `setAppLocale` antes de armar la
  notificación.
- **Plurales** con ICU: `{count, plural, =1{1 serie} other{{count} series}}`.
- **Fechas:** `core/format/dates.dart` con `intl` según el idioma (`main` y
  `test/flutter_test_config.dart` llaman `initializeDateFormatting`); en
  español sin punto y "sep" (no "sept").
- **No se traduce** lo que escribe el coach (ejercicios, programas, notas,
  chat, medidas personalizadas). Las 16 medidas estándar sí: `BodyMeasure.label`
  = `name` del coach o la traducción por clave.
- Tests de widgets: `MaterialApp` con `localizationsDelegates:
  AppLocalizations.localizationsDelegates` (ver `program_screen_test.dart`).

## Unidades de peso (switch kg/lb)

La API habla **siempre en kg** (ver `haki-api/CLAUDE.md` § Convenciones de BD).
En el gym las máquinas varían (prensa en lb, mancuernas en kg), así que el
atleta elige la unidad al registrar:

- **Switch por día** en el header de la sesión; arranca en
  `client_profiles.preferred_weight_unit`.
- **Sin override por ejercicio** (se sacó 2026-10-27, decisión de Sergio):
  antes tocar la unidad de un ejercicio la invertía solo para ese; ahora la
  unidad es una sola, la del switch del header (`DayWeightUnit`).
- Al tocar el switch **no** se convierte lo que se está escribiendo (si escribió
  45 y la máquina es en lb, quiso decir 45 lb). Sí se convierten prescripción y
  "última vez". **Sets ya guardados también se convierten** a la unidad
  efectiva (140 kg → 308.6 lb; decisión de Sergio 2026-10-16). Si se edita uno,
  se vuelve a guardar en la unidad efectiva.
- Mostrar la unidad junto a cada input (`[ 45 ] lb`) para evitar registros en
  la unidad equivocada.
- Guardar: mandar `{ weight, weightUnit }` tal cual lo escribió; el backend
  convierte a kg. Lo mismo para body logs.
- Futuro opcional: preseleccionar la unidad por ejercicio con la del último
  set (`LastPerformanceDto` en el detail del día — no implementado).

## Fuera de alcance por ahora

- **Cadencia (tempo) por ejercicio** (pills ECC/PAU/CON/PAU): feature para más
  adelante; se sacó del mockup de Sesión y Detalle de ejercicio. No construir
  hasta que se pida (ver roadmap en `../CLAUDE.md`).

## Programas y pantalla Hoy

Datos: `GET block-assignments/{clientId}/assignments` (ya viene sin borradores
ni cancelados) + `GET block-assignments/{id}/detail` del programa en curso
(cacheado por `blockUpdatedAt`; trae `dayMappings`). "Qué toca hoy" se calcula
en la app (funciona offline).

Clasificación de los programas `active`:

| Programa | Sección |
|---|---|
| Con fechas y hoy dentro del rango | **EN CURSO** |
| Sin fechas, si no hay uno en curso con fechas | **EN CURSO** (modo "SIGUIENTE"); si hay varios, el de `activatedAt` más antiguo |
| Fecha de inicio futura, o sin fechas cuando ya hay uno en curso | **PRÓXIMO**, ordenados por `activatedAt` (los sin fechas) / `startDate` |
| `endDate` pasada o `completed` | **ANTERIORES** |

Día de hoy: con fechas + `dayMappings` → semana `(hoy − startDate) / 7 + 1` y
día del mapping del día de la semana (sin mapping = descanso). Con fechas sin
mappings → primer día sin completar de la semana actual. Sin fechas → primer
día sin completar del programa.

Estados de Hoy: sin programas · solo próximo · toca entrenar · descanso · día
vacío ("Tu coach lo está preparando") · sesión empezada (Continuar) · sesión
completada · programa terminado · offline (caché).

Asignar fechas (atleta): `PUT block-assignments/{id}/schedule` con
`startDate` + `dayMappings` (`MON`…`SUN`). "Ahora no" = sigue sin fechas.

## Sincronización con cambios del coach

El coach sigue editando el programa activo (agrega semanas, días, ejercicios).
La app **no escucha en tiempo real**; refresca en momentos puntuales:

1. **Al abrir la app o volver a primer plano** (`AppLifecycleState.resumed`),
   al entrar a Hoy / Programa, y con **pull-to-refresh**.
2. Para no bajar todo el programa cada vez: comparar `blockUpdatedAt` de
   `GET block-assignments/{clientId}/assignments` con el que está en caché;
   solo si cambió, pedir `GET block-assignments/{id}/detail`. El backend
   actualiza `Block.UpdatedAt` con **cualquier** edición de la estructura.
3. **Durante un entreno en curso, nunca reemplazar el día en pantalla.** Si al
   refrescar cambió el día activo, mostrar un aviso "Tu coach actualizó este
   día · Actualizar" y aplicar solo cuando el atleta toque. Los logs ya
   cargados están a salvo: se guardan por `BlockDayExerciseId` + número de
   serie y el backend no deja borrar nada con registros (responde 409).
4. **Futuro:** push (FCM/OneSignal) cuando el coach guarda cambios → si la
   app está abierta, dispara el refresh del punto 1.

Descartado por ahora: Supabase Realtime (los datos viven en Neon, no en la
BD de Supabase) y polling periódico (batería/requests para algo que cambia
pocas veces por semana).

Un día sin ejercicios es válido (el coach lo está armando): mostrarlo como
"Tu coach lo está preparando", sin botón de empezar.

## Subida de videos de series (requisito: cola)

Los videos se suben con una **cola**, nunca en paralelo. Cada video son dos
pasos: upload a Cloudinary → `PATCH set-logs/{setLogId}/video` con la URL.

1. **Secuencial:** un video a la vez, `PATCH` incluido; el siguiente arranca
   cuando el anterior terminó. **Es obligatorio:** el `PATCH` publica (o
   actualiza) la tarjeta de videos del ejercicio en el chat general, y dos
   `PATCH` simultáneos del mismo ejercicio, cuando todavía no tiene tarjeta,
   crean **dos tarjetas** (ver `haki-api/CLAUDE.md` § Chat). El backend no se
   protege de esa carrera a propósito: la garantía es esta cola.
2. **Persistente:** sobrevive a cerrar la app y a quedarse sin señal; reintenta
   al volver la conexión. Puede ser la misma cola de reintentos de
   `workout-sessions` (esos endpoints ya son idempotentes para eso).
3. **Reintento por paso:** si el upload a Cloudinary terminó y falla el
   `PATCH`, reintentar solo el `PATCH` (guardar la URL en el item de la cola),
   sin volver a subir el archivo.
4. **Reemplazo:** si el atleta vuelve a grabar una serie cuyo video sigue
   pendiente, el nuevo reemplaza al pendiente en la cola (no se suben los dos).
   Una vez subido, un video nuevo de la misma serie lo pisa en el backend.

**Implementado (2026-10-20, probado en emulador):** tabla drift `LocalVideos`
(schema 3, una fila por serie) y paso 4 de `SessionSync._pushVideo`, un video
por vuelta: comprimir a 720p (`video_compress`) → `POST
set-logs/{id}/video/signature` + upload multipart directo a Cloudinary (Dio
sin JWT; `secure_url` queda en `uploadedUrl`) → `PATCH set-logs/{id}/video` →
`done` (el archivo se borra; la fila queda para mostrar la cámara como enviada
sin recargar). Archivos en `getApplicationSupportDirectory()/videos`
(`video_files.dart`). El set-log id sale de `LoggedSetDto.id` (serie que vino
de la API) o de `LocalSets.remoteId` (lo devuelve el upsert; una serie subida
antes de existir esa columna se reenvía para conseguirlo). La serie tiene que
estar registrada antes de grabar. 400/404/413 o archivo perdido = se descarta
el video (no traba la cola). Grabar: `image_picker` (cámara o galería; la
cámara corta a los 90 s) → **Recortar video** (`VideoTrimScreen`, como
WhatsApp: `video_player` en loop solo en el tramo, tocar = play/pausa, tira de
miniaturas con dos manijas de a 1 s, máx. 90 s, mín. 1 s) → la cola guarda
`trimStartMs/trimEndMs` (schema 4) y el recorte se hace al comprimir
(`video_compress` `startTime`/`duration` en segundos; **en Android `duration`
es cuánto cortar del final**, en iOS lo que dura: `compressTrimArgs` en
`video_trim.dart`, tests en `test/video_trim_test.dart`). `pendingCount` cuenta videos sin subir y el wipe borra los archivos.
Pendiente: verificar el borrado a los 30 días en Cloudinary.

## Chat (2026-10-20)

Tab `/chat` (`features/chat/`): canal general con el coach. Se usa
`stream_chat_flutter_core` (conexión + datos) y la UI es propia, igual al
mockup (`Chat.dc.html`); se descartó `stream_chat_flutter` (UI del SDK) por
pesado (grabación, galería, encuestas) y porque hay que pisar todo su diseño.
- `streamClient` (keepAlive, API key pública de `Env`) envuelto en
  `StreamChatCore` en `app.dart` (desconecta en background, reconecta al
  volver). `generalChannel` (keepAlive): `GET stream/token` → `connectUser` →
  `POST stream/channel/general` → `channel.watch()`. Al cerrar sesión
  `LocalDataGuard` hace `disconnectUser` e invalida el canal.
- `ChatScreen`: header con el coach (`coachName`), `MessageListCore`
  (lista invertida, pagina al llegar arriba), separadores Hoy/Ayer/"25 sep",
  burbujas propias doradas / del coach grises con su inicial, marcar leído al
  ver, "No se envió · Reintentar". Tarjetas de videos (`VideoCard.of`: mensaje
  con `exerciseName`) con miniaturas (`cloudinaryThumb`: misma URL en `.jpg`)
  → `VideoPlayerScreen`; respuesta del coach citando una tarjeta muestra
  "Ejercicio · Sem N · Día N". Pesos en `bodyWeightUnit`.
- Lógica pura en `chat/data/chat_message.dart` (tests en
  `test/chat_message_test.dart`).
- Feedback por ejercicio (solo si `exerciseFeedbackEnabled` del coach, que
  viene en `/auth/me`): la tarjeta suma `FeedbackRow` (última respuesta +
  "N respuestas · Ver feedback", o "Esperando feedback de X"; pide la última
  respuesta con `getReplies(limit: 1)`) → `FeedbackThreadScreen` (mockup
  "Hilo": tus videos + nota, respuestas, responder con `parentId`). La ruta
  se abre con `Navigator.push` envuelta en otro `StreamChannel` (no hereda el
  del tab). Las respuestas de hilo **no** salen en el chat general.
- Links al hilo fuera del chat (`chat/ui/feedback_links.dart`,
  `FeedbackLink`, mismo flag): Detalle de ejercicio (tarjeta turquesa arriba
  con el feedback más reciente + chip "2 videos · 3 mensajes de feedback" en
  cada tarjeta del historial), Sesión (cada ejercicio: `SessionFeedbackLink`;
  si la tarjeta se publicó durante el entreno el id sale de los mensajes del
  chat, `cardIdFor` por `blockDayExerciseId`) y Sesión pasada (por ejercicio; punteado "Tu
  video todavía no tiene feedback" si no hay respuestas). Ids:
  `DayExerciseDto.streamMessageId` (detalle del programa) y
  `ExerciseHistoryEntryDto.streamMessageId` (historial). Datos con
  `feedbackSummary(messageId)` (getMessage + última respuesta); sin red no
  muestran nada.
- El hilo pagina respuestas viejas al llegar arriba (de a 20).
- Badge de no leídos en el tab Chat (`AppShell` conecta el chat al entrar y
  escucha `unreadCountStream` del canal; las respuestas de hilo no suman).
- **Push del chat (2026-10-21, funciona en el emulador):** FCM + integración de push
  de Stream. Firebase: proyecto `haki-86a98`, `android/app/google-services.json`
  (versionado, no es secreto; plugin `com.google.gms.google-services` en
  Gradle). Stream: push provider **`firebase`** (dashboard → Push Providers)
  con la clave de cuenta de servicio de Firebase (secreta: no va al repo).
  `chat/providers/chat_push.dart` (`ChatPush`): `Firebase.initializeApp` en
  `main` (sin config, p. ej. iOS sin plist, no hay push y la app anda igual);
  al conectar el chat registra el token con `addDevice(..., pushProviderName:
  'firebase')` (usa `getToken`, deprecado en firebase_messaging 17: el
  `register()` nuevo da un FID que Stream no usa); al cerrar sesión
  `removeDevice`; permiso la primera vez que entra al Chat; tocar la
  notificación → Chat y, si es respuesta de un hilo, el hilo (`data.id` →
  `getMessage` → `parentId`). Canal Android `chat_messages` + color dorado
  (meta-data en el manifest). Stream manda push solo si el atleta no está
  conectado al chat (en segundo plano `StreamChatCore` corta a los 15 s).
  **Stream usa push v3: a Firebase manda solo datos** (`id` del mensaje,
  `cid`…), sin título ni texto, y los templates no cambian eso (probado con
  `testPushSettings`). La notificación la arma la app
  (`chat/data/chat_notifications.dart`): handler de fondo de FCM
  (`chatPushBackgroundHandler`, registrado en `main`) → `getMessage` con un
  cliente REST (`connectWebSocket: false`) y las credenciales de Stream del
  atleta guardadas en `flutter_secure_storage` (se borran al cerrar sesión) →
  notificación local "Juan Pérez · texto" / "Feedback de Juan Pérez" con el
  id del mensaje como payload. Con la app abierta **no** se muestra push
  (decisión de Sergio: el aviso es el badge del tab Chat). **Ojo:** en el
  dashboard nuevo de Stream cada tipo de evento viene con push apagado; hay
  que activar `message.new` para el provider (`POST /push_templates` con
  `enable_push: true`, o "Chat templates" en el menú de la tarjeta del
  provider). Sin eso Stream no manda nada y no reporta error (activado en
  `kojo-dev` 2026-10-21; repetirlo en la app de prod). Las notificaciones locales del timer y del chat comparten
  un solo `initialize` (`core/notifications/local_notifications.dart`), si
  no se pisa el callback del toque. Falta: iOS (clave APNs en Firebase,
  desde Mac) y push del backend (no-chat). Decidido 2026-10-20: **no** hay mensajes por ejercicio sin video
  (para eso está el chat general).

## Cuestionarios (2026-10-21)

Los arma el coach en el web; reglas y backend en `../haki-api/CLAUDE.md`
§ Cuestionarios. Mockup: "Hoy" (tarjeta, tweak `cuestionariosPendientes`) y
"Cuestionario" del canvas Haki Mobile.

- `GET questionnaires/me` (con `ApiCache`, se ve sin señal) → pendientes con
  sus preguntas + `schedule` de semanales. `myQuestionnairesProvider`;
  `questionnaireSyncProvider` (arranca en `app.dart`) recarga al volver a
  primer plano y reprograma los avisos.
- **Hoy:** una `PendingQuestionnaireCard` por pendiente, debajo de la tarjeta
  del entreno, el más viejo primero. Quedan hasta que se envían (no vencen).
- **Responder** (`/cuestionario/:responseId`, pantalla completa): Escala 1–5
  ("Peor"/"Mejor" fijos), Sí/No con detalle si la pregunta lo pide, Texto. El
  botón "Enviar a {coach}" se habilita con todas las obligatorias. Al enviar:
  `POST questionnaires/me/responses/{id}`, `expire(wait: true)` del caché y
  vuelve a Hoy sin la tarjeta.
- **Aviso de las 20:00** (`core/notifications/questionnaire_reminders.dart`):
  notificación local (el backend no manda push), las próximas 4 semanas de
  cada semanal, ids 3000+, reprogramadas cada vez que llegan los
  cuestionarios. Sin payload: tocarla abre la app en Hoy. El permiso se pide
  una vez (misma clave `push_permission_asked` que el chat). Usa la hora del
  teléfono; el backend crea el envío a las 20:00 de la zona del coach (iguales
  en Costa Rica).

## Feedback del coach (hilos)

El feedback por ejercicio vive en el **hilo** de la tarjeta de videos del
`ExerciseLog` en el chat general (mensaje raíz = `streamMessageId`). Las
respuestas del atleta van con `parent_id` = ese id. Si el coach tiene
`exerciseFeedbackEnabled` apagado, no hay hilo: responde citando la tarjeta
en el chat general (`quoted_message_id`).

## Tu coach (2026-10-23)

Pantalla `features/profile/ui/coach_screen.dart` (rutas `/perfil/coach` desde
la tarjeta al final del Perfil y `/chat/coach` tocando el header del Chat):
iniciales, nombre, "N años de experiencia" (año actual − `coachingSince`),
"Sobre mí", certificaciones (solo texto) y "Escribirle a …" → Chat. Sale de
`/auth/me` → `coach` (`CoachProfileDto`), así que anda offline con la caché.
Sin datos: "… todavía no completó su perfil." Sin foto del coach ni
especialidades (decisión de Sergio).

## Decisiones de arquitectura (para lo que viene)

- **Offline-first para el entreno:** registrar series tiene que funcionar sin
  señal. Sesión en curso + outbox en SQLite con **`drift`**; un sync worker
  manda la cola a la API (endpoints de `workout-sessions` ya idempotentes).
  Chat/progreso pueden requerir red. Meter drift **desde el primer feature de
  registro**, no después.
- Preferencias chicas → `shared_preferences`; datos sensibles →
  `flutter_secure_storage`. La sesión de Supabase la persiste el SDK.
- **Push:** FCM (`firebase_messaging`). El chat usa la integración de push de
  Stream (credenciales de Firebase en el dashboard de Stream); el resto lo
  manda haki-api. Tocar la notificación → deep link con `go_router`. Pedir el
  permiso en un momento con contexto, no al primer arranque.
- **Notificaciones locales** (`flutter_local_notifications`) para el fin del
  timer de descanso con el teléfono bloqueado.
- **Timers basados en timestamps** (`endsAt`), no contadores en memoria: el SO
  puede matar la app en background.
- **Compatibilidad hacia atrás de la API:** versiones viejas de la app conviven
  meses. Agregar campos sí; renombrar/quitar no (→ `api/v2`). Agregar chequeo
  de versión mínima ("Actualizá la app").
- Pendiente: flavors dev/prod con bundle id distinto, Sentry/Crashlytics,
  i18n con `gen-l10n`, fuente Inter como asset.

## Estado actual

Esqueleto base: env por ambiente, tema con tokens, router con guard de auth,
cliente `dio` con JWT, login email/password y Google con Supabase,
`AthleteGate` (compara `role` sin distinguir mayúsculas: la API devuelve
`"CLIENT"`), login con el logo (`HakiLogo` en `core/widgets/`).

**Logo J2 (2026-10-25):** `HakiLogoMark` (`core/widgets/haki_logo.dart`) dibuja
el isotipo con `HakiMarkPainter` (anillos atravesados por una pesa, viewBox
100, misma geometría que el web y `branding/make_logo.py`). Colores fijos en
`core/theme/haki_logo_colors.dart` (`HakiLogoColors.dark` / `.light` según el
brillo del tema). Los anillos van en una capa (`saveLayer`) que los discos y
el núcleo recortan con `BlendMode.clear`: se separan de la pesa sobre
cualquier fondo; la barra solo se recorta alrededor del núcleo. `pulse` =
brillo suave + núcleo que late; `draw` = los anillos se dibujan al aparecer
(splash). `HakiLoader` = el isotipo sin el anillo exterior + arco dorado que
gira + tres ondas desde el núcleo + núcleo con halo que late.

Navegación: `StatefulShellRoute` con 4 tabs (`AppShell` en `core/widgets/`):
Hoy `/` · Programa `/programa` · Chat `/chat` · Perfil `/perfil`.
`AthleteGate` envuelve el shell. Chat: ver § Chat; Hoy tiene
cabecera + saludo (nombre de `user_metadata` de Supabase); Perfil ver abajo.

Kit en `core/widgets/`: `HakiCard` (tone neutral/gold/turquoise, tocable),
`SectionLabel`, `PillChip`, `SegmentedProgress`, `UserAvatar`. El botón
primario es `FilledButton` con el tema (52 px, radio 16). Tokens del mockup
en `HakiColors` (`goldBright` para texto dorado, `goldSurface`/`goldBorder`,
`turquoiseSurface`/`turquoiseBorder`, `textSecondary`, `navBar`).
`ExerciseTile` y `SetRow` se hacen con la pantalla de Sesión.

Hoy con datos reales: `features/program/data/` (DTOs de block-assignments +
`ProgramRepository`) y `program_schedule.dart` con la lógica pura
(`classifyPrograms`, `resolveToday`, `weekStrip`; tests en
`test/program_schedule_test.dart`). Providers: `programSections` →
`currentProgramDetail` → `today` (`TodayState`). Estados cubiertos: sin
programa, solo próximo, toca entrenar (Empezar/Continuar/completado), día vacío,
descanso (con próximo día), semana completa, programa terminado, error.
Refresca con pull-to-refresh y al volver a primer plano (ver Offline abajo).

Offline (2026-10-18): `core/cache/api_cache.dart` (`ApiCache`) = GET con
respaldo en la tabla drift `CachedResponses` (schema 2): primero la red y se
guarda el JSON; sin respuesta del servidor se usa lo último guardado (un 4xx/5xx
no cae al caché). Lo usan `/auth/me` (si no, `AthleteGate` bloqueaba la app sin
señal), la lista de programas y el detalle → Hoy, Programa y la Sesión abren sin
señal. `wipe()` también lo borra. `programRefresher` (arrancado en `app.dart`)
invalida programas y detalle al volver a primer plano, **salvo en pantallas de
entreno** (`/sesion`, `/descanso`, `/ejercicio`, `/completado`). Se descartó
"bajar el detalle solo si cambió `blockUpdatedAt`": el detalle también trae
sesiones, series y "última vez", que cambian sin tocar el bloque. Pendiente:
aviso "sin conexión · datos de tal hora" y "Tu coach actualizó este día".

**Abrir con la caché primero (2026-10-21):** `ApiCache.get(..., onUpdated:)`
es *stale-while-revalidate* para `/auth/me`, programas y detalle: con copia la
devuelve al instante y pide a la API en segundo plano; si cambió la guarda y
`onUpdated` recarga el provider (`ref.invalidateSelf`). No repide lo pedido
hace menos de 30 s (evita el pedido doble al recargar). Sin copia espera la
red. Durante un entreno (`isTraining`) el programa no se recarga: lo nuevo
queda guardado y se ve al salir. `expire()` al volver a primer plano (copia +
actualiza); `expire(wait: true)` en los pull-to-refresh (espera la red). La
copia es por usuario (clave `userId:path`). Tests en
`test/api_cache_test.dart`.

Sesión (`/sesion/:assignmentId/:dayId`, fuera del shell): registro de series
offline-first. Sincroniza contra `workout-sessions`; la sesión se crea con
status `pending` (la BD no acepta `in_progress`, ver `haki-api/CLAUDE.md`).
- `core/db/app_database.dart` (drift, `haki.sqlite`): `LocalSessions`,
  `LocalSets` (peso tal cual se escribió + unidad), `LocalExerciseLogs` (caché
  de ids). Claves naturales = las de los upserts de la API.
- `SessionStore` escribe local y patea `SessionSync`, que sube en orden
  (crear sesión → exercise-log → series → complete) con backoff 15 s…5 min y
  al volver a primer plano. Una serie editada mientras se subía queda
  pendiente (se marca subida solo si `updatedAt` no cambió). Tests en
  `test/session_sync_test.dart`.
- **riverpod_generator no ve las clases que genera drift**: el store expone
  `LocalSessionInfo` / `LocalSetEntry`, nunca `LocalSession` / `LocalSet`.
- Hoy pisa el estado del día con las sesiones locales (empezada/completada
  aunque no haya subido).
- UI (igual al mockup): superseries agrupadas (A1/A2, carril + flujo
  "A1 → A2 → descanso ↻ repetir"), switch KG/LB del día (sin override por
  ejercicio), objetivo convertido a la unidad del día, series guardadas en su
  unidad original, aviso de series sin subir. Fila guardada = texto, pendiente
  = "–", la primera pendiente de la sesión (`workOrder`) queda con inputs
  abiertos (sin resaltar: a Sergio no lo convenció); tocar otra fila la abre
  para cargar/corregir. Sin check: se guarda sola al salir de la fila si
  cambió peso, reps o RIR (2026-10-26), tal cual: lo que no escribió queda
  vacío, reps incluidas (decisión de Sergio; antes exigía reps escritas y un
  atleta que solo cargaba el peso no guardaba nada). Una serie sin reps no
  cuenta para adherencia, récords, e1RM ni volumen. Idea para más adelante
  (no hecha): precargar las reps del objetivo como texto real al abrir la
  fila (visible y corregible; peso y RIR no), nunca completarlas en silencio. Inputs **sin placeholder** (el hint parecía un
  valor cargado); el objetivo va con unidad en dos líneas (2026-10-27:
  "110 kg × 12" se cortaba): arriba el peso ("60 kg", o "12 reps" sin peso) y
  abajo "12 reps · RIR 2" (se achica si no entra), y lo que el coach no puso no aparece. Cámara en **todas** las series: dorada con punto = pedida por el
  coach, tachada = no pedida (al tocarla confirma "Tu entrenador no solicitó
  video…"), nube turquesa = en la cola, turquesa con check = subido (tocar
  = grabar otro que lo reemplaza). Ver § Subida de videos. Ejercicios sin series y sin la siguiente
  se muestran colapsados; tocar los abre.
  Debajo de cada ejercicio: "Sem. pasada: 116 lb × 12·12·12·12 · e1RM 163.8 lb"
  (`lastPerformance` del detalle; "Sem. N" si es otra semana del programa, la
  fecha si es de otro programa), en la unidad efectiva del ejercicio. Tocar el
  nombre → Detalle de ejercicio.

Detalle de ejercicio (`/ejercicio/:assignmentId/:dayId/:dayExerciseId`, sin
tabs, `features/exercise/`): video técnico (`videoUrl` del coach o
`exerciseVideoUrl` del catálogo, se abre afuera con `url_launcher`), "Cómo se
hace" (`exerciseDescription`, 3 líneas + Ver más), nota del coach, e1RM (último,
NUEVO PR si supera a todos los anteriores, tendencia con `BodyLineChart`,
"+X en el bloque", volumen de hoy) e historial (hoy con borde dorado + `GET
progress/{clientId}/exercises/{exerciseId}/history`, chips "116 lb × 12 @1" con el
peso y la unidad de cada serie; arranca con 2 tarjetas y
"Cargar más" suma de a 5 — decidido 2026-10-20: el historial sirve para elegir
la carga de hoy). Sin red:
hoy + "última vez". Lógica pura en `exercise/data/exercise_stats.dart` (tests en
`test/exercise_stats_test.dart`). Falta: feedback del coach (hilo, con Chat).

Tab Programa (`features/program/ui/`, 2026-10-17):
- `/programa` (`ProgramScreen`): tarjeta del bloque (rótulo + "Asignar/Cambiar
  fechas", semana X de N, entrenos hechos/total, barra por semanas), selector
  S1…SN (abre en la semana actual) y días de la semana elegida: hecho (check
  turquesa → Sesión pasada), el que toca (dorado → Sesión), en curso,
  pendiente, sin ejercicios (punteado "Tu coach lo está preparando"). Solo el
  programa en curso entra a la Sesión. `/programa/p/:id` = mismo, para
  terminados/próximos (solo lectura).
- Sin programa en curso, el tab muestra directo Mis programas
  (`ProgramsListScreen(asTab: true)`, sin volver).
- `/programa/todos` (`ProgramsListScreen`): EN CURSO / PRÓXIMO (sin fechas →
  Asignar fechas) / ANTERIORES (línea de tiempo, adherencia =
  `completedDays/totalDays`).
- `/fechas/:id` (`AssignDatesScreen`, sin tabs): calendario (desde hoy, o el
  inicio que ya tenía) + día de la semana por entreno (elegir uno ocupado
  intercambia); `PUT schedule` vía `ScheduleSaver`, error = `detail` de la API
  (`apiErrorMessage`).
- `/programa/sesion/:a/:d` (`PastSessionScreen`): series registradas en la
  unidad en que se cargaron, objetivo, nota del atleta y **cámara en cada
  serie registrada** (2026-10-22: se pueden subir videos después del gym;
  mismo flujo y cola que la Sesión, `queueSetVideo` en
  `session/ui/set_video_flow.dart`, botón `SetCameraButton`). En Hoy, un día
  completado muestra "Ver entreno · subir videos" → esta pantalla. Falta ver
  (reproducir) los videos.
- Lógica pura: `currentWeekOf`, `dateOfDay`, `weekRows`, `durationOf`,
  `dayCountsOf` (`program_schedule.dart`) y `assign_dates.dart`; tests en
  `test/program_tab_test.dart` y `test/assign_dates_test.dart`.
- Providers: `programDetail(id)` (API) → `programWithLocal(id)` (pisa estados
  con las sesiones del teléfono, `mergeLocalSessions`); Hoy usa este último.

Perfil (`features/profile/` + `features/body/`, 2026-10-18):
- `/perfil`: avatar, nombre, "Coach: X" (`coachName` de `/auth/me`) y
  tarjetas Peso (último + sparkline + cambio en 4 sem), Medidas (cintura o la
  primera pedida, cantidad y fecha) y Adherencia (`currentAdherence`: hechos /
  días que ya tocaban del programa en curso, `adherenceOf`; sin calendario
  muestra hechos / total; tocarla abre **Adherencia**, `/perfil/adherencia`:
  anillo con el % (cumplir el programa), "Series de tus entrenos" (solo de
  los entrenos hechos, "85 de 85 · en los 5 que hiciste"), % del bloque anterior, una fila por
  semana — hecho / no se hizo / hoy / pendiente — y "Sin completar" → Sesión
  pasada; todo de `adherenceReport` sobre el detalle con las sesiones del
  teléfono, sin red). Arriba, tarjeta de **racha de semanas**
  (`_StreakCard`: llama, "5 semanas seguidas" o "Arrancá tu racha", "Esta
  semana: 2 de 4 · Tu mejor racha: 8 semanas", una barrita por semana dorada
  si se cumplió; `GET progress/{id}/streak` vía `streakProvider`, sin red no
  se muestra; pull-to-refresh la recarga). Tarjeta **Récords** ("3 PRs en este
  bloque", o "en total" sin programa) + **PRs recientes** (los 3 últimos) →
  `/perfil/records` (`RecordsScreen`, mockup "Récords personales": Este
  bloque / Histórico, "Esta semana" en dorado con la mejora, e1RM y la serie
  en la unidad en que se cargó). `GET progress/{id}/records` vía
  `recordsProvider`; lógica pura en `profile/data/records.dart` (tests en
  `test/records_test.dart`). Niveles del mockup **oculto** hasta que tenga
  backend. Engranaje → Ajustes.
- `/perfil/ajustes/datos` (`PersonalInfoScreen`, 2026-10-26, mockup "Mis datos"): se entra tocando el nombre en Ajustes → Cuenta (no desde el Perfil, decisión de Sergio). Nombre, género (`M`/`F`/`Other`), estatura en cm o ft+in (se guarda en cm, `personal_info.dart`), lesiones; email y objetivo solo lectura ("Escribile" → Chat); peso = último `body_log` → Peso corporal. `PATCH auth/me/personal` vía `PersonalInfoSaver` (expira la caché y recarga `/auth/me`).
- `/perfil/ajustes` (`SettingsScreen`, `features/settings/`): cuenta (nombre,
  email, Cambiar contraseña con Supabase `updateUser` — solo si tiene identidad
  `email`, no con solo Google), unidad de peso (`PATCH auth/me/weight-unit` →
  invalida `/auth/me`), Vibrar al terminar el descanso (`RestVibration`,
  `shared_preferences` `rest_vibrate`; apaga el háptico y usa el canal Android
  `rest_timer_done_quiet`, porque la vibración es fija por canal) y Cerrar
  sesión (avisa si hay series sin subir). Del mockup faltan: videos solo con
  Wi-Fi, notificaciones, Google Fit, idioma, ayuda, términos y versión.
- `DayWeightUnit` escucha `bodyWeightUnit` (no `authMe` directo): refrescar
  `/auth/me` no pisa el switch del día; cambiar la unidad en Ajustes sí.
- `/perfil/peso` y `/perfil/medidas/m/:key` (`BodySeriesScreen`, misma
  pantalla para el peso y cada medida): último valor, cambio en el rango
  (4 sem / 3 meses / Todo), gráfico (`BodyLineChart`, `CustomPainter`, sin
  librería), historial con diferencia y botón Registrar peso (hoja, hoy) o
  Registrar medidas.
- `/perfil/medidas` (`MeasuresScreen`): solo las que pidió el coach
  (`bodyMeasurements` de `/auth/me`), último valor de cada una y diferencia con
  su registro anterior; tocar una → su historial. Pull-to-refresh vuelve a
  pedir `/auth/me` (el coach puede cambiar las medidas).
- `/perfil/medidas/registros` (`MeasureLogsScreen`, "Ver registros
  anteriores"): un registro por día con medidas pedidas (`measureLogsOf`);
  tocar uno → Registrar medidas en esa fecha.
- `/medidas/registrar?fecha=YYYY-MM-DD` (`LogMeasuresScreen`, sin tabs): fecha
  (hoy por defecto, editable hasta 3 años atrás), medidas agrupadas (Tronco / Brazos y piernas /
  Composición / Otras) con "Anterior"; si el día ya tiene registro arranca cargado. Se
  mandan solo las que tienen valor (la API mergea).
- Datos: `GET body-logs/{clientId}` (`bodyLogs`) y `POST body-logs/me`
  (`BodyLogSaver`). Necesitan red. Las medidas van y vienen en `values`
  (clave → valor). Peso y medidas de unidad `kg` en `preferredWeightUnit`
  (`bodyWeightUnit`); el resto en su unidad (cm, mm, %, nivel).
  Diferencias: turquesa si bajó, dorado si subió.
- Medidas personalizadas (2026-10-20): el coach crea las suyas en el web; la
  app no puede crear. `/auth/me` trae `bodyMeasurements` como objetos `{ key,
  name, unit, category }` → `BodyMeasure.fromJson` (name null = estándar, el
  nombre sale de `bodyMeasures`; un String suelto = caché vieja de `/auth/me`).
- Lógica pura en `body/data/body_measures.dart` (`bodyMeasures` = las 16
  estándar con su nombre, `seriesOf`, `lastTwo`, `inRange`,
  `changeOf`, `previousBefore`, `measureLogsOf`); tests en `test/body_measures_test.dart`.

Lógica pura de la sesión en `features/session/data/session_plan.dart`
(`groupSupersets`, `setCountOf`, `savedSetFor`, `workOrder` por rondas en
superseries, `afterSave`, `summarize`; tests en `test/session_plan_test.dart`).

Timer de descanso (`providers/rest_timer.dart`, keepAlive, basado en `endsAt`):
**manual** (decisión de Sergio 2026-10-16): no arranca al guardar una serie;
el atleta lo abre desde el botón del header y toca Iniciar (cierra la
pantalla y vuelve a la Sesión). Mientras está
activo queda la barra flotante. Cada serie guardada le pasa al timer
(`prepare`) qué se terminó y qué viene (tarjeta "Siguiente"); en superserie a
mitad de ronda dice "seguí sin pausa". Presets 1:00/1:30/2:00/3:00, ±15 s;
la última duración elegida se guarda en `shared_preferences`. UI: botón en el
header de la Sesión, `RestTimerBar` flotante abajo y `RestTimerScreen`
(`/descanso`) con anillo + tarjeta "Siguiente". Al terminar vibra (app
abierta).

Notificaciones del timer (`core/notifications/rest_notifications.dart`,
`flutter_local_notifications` + `timezone`): mientras corre, notificación
fija con cuenta regresiva nativa (Android: `usesChronometer` +
`chronometerCountDown`, canal `rest_timer_running`, sin sonido, se va sola al
terminar); al terminar, notificación programada (`zonedSchedule` en UTC)
con sonido (canal `rest_timer_done`), aunque la app esté cerrada. En pausa
queda la notificación fija "Descanso en pausa · 0:45" (sin aviso de fin). 
Cerrar las cancela. El permiso se pide al iniciar el primer descanso. Exacta
si `canScheduleExactNotifications()` (manifest: `SCHEDULE_EXACT_ALARM`; en
Android 14 viene apagado y no se pide), si no inexacta. Android necesita
desugaring en `build.gradle.kts` y el `ScheduledNotificationReceiver` en el
manifest. iOS: solo la de fin (la cuenta regresiva en bloqueo necesita Live
Activities, pendiente). Llevan payload `rest` (`restNotificationPayload`): tocarlas abre Descanso si
el timer sigue activo (si no, la app queda donde estaba).

**Toque en notificaciones (2026-10-27):** lo reparte `NotificationTaps`
(`core/notifications/notification_taps.dart`, keepAlive, arranca en
`app.dart`): `rest` → Descanso, id de mensaje → `ChatPush.openMessage`
(Chat o hilo), sin payload (cuestionarios) → nada. Si la app arrancó por una
notificación, el payload se guarda en `shared_preferences`
(`last_launch_notification`) y no se repite: en Android, si el sistema mató
el proceso, la app vuelve con el intent de la notificación que la abrió antes
(p. ej. una del chat) aunque se toque otra, y tocar la del timer abría el
chat.

Entreno completado (`/completado/:assignmentId/:dayId`): Finalizar hace
`pushReplacement` acá; muestra duración, series hechas/total y volumen en la
unidad del día. **Duración (2026-10-27, `workoutDuration` en
`session_plan.dart`):** de la primera a la última serie guardada en el
teléfono (`LocalSets.updatedAt`), sumando el arranque de la sesión y el
Finalizar solo si están a ≤ 30 min; series separadas más de 4 h = sin
duración ("—"). Antes era `startedAt → completedAt` y un día tocado el
domingo y entrenado el martes daba "1234 min". El header de la Sesión
muestra "empezado el dom 25 oct" si la sesión tiene más de 4 h. "Listo" refresca el programa y va a Hoy. Una
sesión ya completada muestra "ver resumen". `DayWeightUnit` es
keepAlive (sobrevive a salir de la Sesión).

Unidad inicial: `DayWeightUnit` arranca en `preferredWeightUnit` de
`GET /auth/me` (kg si no viene).

BD local de un solo usuario: `LocalDataGuard` (`session/providers/`, se
arranca en `app.dart`) guarda el dueño en `shared_preferences`
(`local_db_owner`); al cerrar sesión o si entra otro usuario hace
`AppDatabase.wipe()` y resetea unidad y timer. Sin dueño guardado se
asume del usuario actual. Ajustes → Cerrar sesión avisa si
`SessionStore.pendingCount()` > 0 ("Tenés entrenos sin subir").

**Pendiente de Sesión:** errores 4xx permanentes que traban la cola,
aviso "Tu coach actualizó este día", Live Activity de iOS para el timer y
videos. Del mockup de
Entreno completado faltan (necesitan backend): +XP, nuevo PR, subida de
videos, RPE de la sesión y nota al coach (`WorkoutSession` no tiene esos
campos).
Flujo de UI acordado: Sergio ajusta el mockup → se traduce a widgets con el kit
(no FlutterFlow ni generadores Figma/HTML → Flutter).

Splash y Cargando (2026-10-20, mockup "Splash" y "Cargando"):
`core/widgets/splash_screen.dart` (`SplashScreen`: isotipo de 136 con el
brillo que late, "haki" + "FITNESS COACHING" subiendo, slogan abajo) va como
`SplashOverlay` en el `builder` de `app.dart`: tapa la app 1.6 s mientras
arranca abajo y se desvanece. Splash nativo de Android = solo fondo `#0D0D0D`
(`res/values/colors.xml` `splash_background`, `launch_background.xml`,
`values-v31/styles.xml` con ícono vacío para el splash del sistema de
Android 12+), así no hay flash blanco ni ícono antes del de Flutter.
`core/widgets/haki_loader.dart`: `HakiLoader` (arco que gira, ondas, núcleo
que late; un solo `AnimationController` de 2.4 s) y `LoadingView` ("Cargando
tu semana…"), en `AthleteGate` (mientras baja `/auth/me`) y en Hoy (mientras
carga el programa). iOS: falta el fondo del `LaunchScreen.storyboard` (Mac).

**Ícono de la app (2026-10-25, logo J2):** isotipo sobre obsidiana, PNG
generados con `../branding/make_logo.py` (`assets/icon/icon.png` completo e
`icon-foreground.png` transparente para el adaptativo de Android, ya con el
margen de la zona segura) → `dart run flutter_launcher_icons` (config en
`flutter_launcher_icons.yaml`, inset 0). **Ojo:** la herramienta pisa
`ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` con `AppIcon`
en `ios/Runner.xcodeproj/project.pbxproj` (bug): descartar ese cambio con
`git checkout` después de correrla.

Pendiente de marca: fuente Raleway para el wordmark "haki" (el web la usa) y
el dorado del logo del web es `#C9A84C` vs. `gold` `#B8922A` del tema.
