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
| Chat | Stream Chat (pendiente) |
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
existente si el email coincide y está confirmado (la invitación lo confirma) →
mismo `userId` en haki-api.

**`AthleteGate`** (envuelve las rutas protegidas): con Google cualquiera crea
sesión en Supabase, así que se chequea `GET /auth/me`; si no es `Client`
(Google sin invitación, o un coach) muestra un mensaje + cerrar sesión. Queda
un usuario huérfano en `auth.users` en ese caso (aceptado).

**Auth/navegación:** el login no navega; `appRouterProvider` escucha
`onAuthStateChange` y el `redirect` manda a `/login` o `/` según haya sesión.
Para agregar rutas protegidas basta con sumarlas al `GoRouter`.

## Branding y tema

Paleta **Obsidian/Gold/Turquoise** (UI dark del atleta):
`#0D0D0D` obsidian · `#B8922A` gold · `#00C4B4` turquoise. Fuente: Inter
(pendiente de agregar como asset; hoy usa la default).

- Tokens en `core/theme/haki_colors.dart` (`HakiColors`, un `ThemeExtension`)
  y `ThemeData` en `core/theme/app_theme.dart`.
- En widgets: `context.colors.gold`. **Prohibido `Color(0x...)` fuera de
  `core/theme/`.** Cambiar de paleta = otro `HakiColors` en `app.dart`.
- Preferir estilos del tema (`inputDecorationTheme`, `filledButtonTheme`…)
  antes que estilos inline.

## Idioma

UI en español por defecto.

## Unidades de peso (switch kg/lb)

La API habla **siempre en kg** (ver `haki-api/CLAUDE.md` § Convenciones de BD).
En el gym las máquinas varían (prensa en lb, mancuernas en kg), así que el
atleta elige la unidad al registrar:

- **Switch por día** en el header de la sesión; arranca en
  `client_profiles.preferred_weight_unit`.
- **Override por ejercicio:** tap en la unidad de un ejercicio la invierte solo
  para ese ejercicio; sobrevive a cambios del switch del día. Si el override
  queda igual a la unidad del día (otro tap o cambio del switch) se borra y el
  ejercicio vuelve a seguir al switch. Sin setting de "dónde va el switch"
  (se descartó por complejidad).
- Unidad efectiva = `override ?? unidadDelDía` (dos providers Riverpod:
  unidad del día + `Map<exerciseLogId, WeightUnit>` de overrides).
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

## Feedback del coach (hilos)

El feedback por ejercicio vive en el **hilo** de la tarjeta de videos del
`ExerciseLog` en el chat general (mensaje raíz = `streamMessageId`). Las
respuestas del atleta van con `parent_id` = ese id. Si el coach tiene
`exerciseFeedbackEnabled` apagado, no hay hilo: responde citando la tarjeta
en el chat general (`quoted_message_id`).

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
`"CLIENT"`), login con el logo (`HakiLogo` en `core/widgets/`, isotipo dibujado
con `CustomPainter` igual al SVG del web, brillo que late).

Navegación: `StatefulShellRoute` con 4 tabs (`AppShell` en `core/widgets/`):
Hoy `/` · Programa `/programa` · Chat `/chat` · Perfil `/perfil`.
`AthleteGate` envuelve el shell. Chat es `ComingSoon`; Hoy tiene
cabecera + saludo (nombre de `user_metadata` de Supabase); Perfil tiene
cuenta + cerrar sesión.

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
Refresca con pull-to-refresh. **Falta:** caché por `blockUpdatedAt`, refresh
al volver a primer plano y modo offline del programa.

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
  "A1 → A2 → descanso ↻ repetir"), switch KG/LB del día + override por
  ejercicio, objetivo convertido a la unidad efectiva, series guardadas en su
  unidad original, aviso de series sin subir. Fila guardada = texto, pendiente
  = "–", la primera pendiente de la sesión (`workOrder`) queda con inputs
  abiertos (sin resaltar: a Sergio no lo convenció); tocar otra fila la abre
  para cargar/corregir. Sin check: se guarda sola al salir de la fila si tiene
  reps. Cámara en **todas** las series: dorada con punto = pedida por el
  coach, tachada = no pedida (al tocarla confirma "Tu entrenador no solicitó
  video…"), turquesa = `videoUrl` ya subido; hoy muestra "pronto" (videos sin
  integrar). Override de unidad por ejercicio: si queda igual a la del día se
  borra (vuelve a seguir al switch). Ejercicios sin series y sin la siguiente
  se muestran colapsados; tocar los abre.
  Falta del mockup: "Sem. pasada" + e1RM (necesita `LastPerformanceDto`) y
  tocar el nombre → Detalle de ejercicio.

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
  unidad en que se cargaron, objetivo, nota del atleta, cámara si hay video.
  Falta: hilo de feedback del coach y ver videos.
- Lógica pura: `currentWeekOf`, `dateOfDay`, `weekRows`, `durationOf`,
  `dayCountsOf` (`program_schedule.dart`) y `assign_dates.dart`; tests en
  `test/program_tab_test.dart` y `test/assign_dates_test.dart`.
- Providers: `programDetail(id)` (API) → `programWithLocal(id)` (pisa estados
  con las sesiones del teléfono, `mergeLocalSessions`); Hoy usa este último.

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
Activities, pendiente).

Entreno completado (`/completado/:assignmentId/:dayId`): Finalizar hace
`pushReplacement` acá; muestra duración (sesión local), series hechas/total y
volumen en la unidad del día. "Listo" refresca el programa y va a Hoy. Una
sesión ya completada muestra "ver resumen". `DayWeightUnit` y
`ExerciseUnitOverrides` son keepAlive (sobreviven a salir de la Sesión).

Unidad inicial: `DayWeightUnit` arranca en `preferredWeightUnit` de
`GET /auth/me` (kg si no viene).

BD local de un solo usuario: `LocalDataGuard` (`session/providers/`, se
arranca en `app.dart`) guarda el dueño en `shared_preferences`
(`local_db_owner`); al cerrar sesión o si entra otro usuario hace
`AppDatabase.wipe()` y resetea unidad/overrides/timer. Sin dueño guardado se
asume del usuario actual. Perfil → Cerrar sesión avisa si
`SessionStore.pendingCount()` > 0 ("Tenés entrenos sin subir").

**Pendiente de Sesión:** errores 4xx permanentes que traban la cola,
"última vez" (`LastPerformanceDto`), aviso "Tu coach actualizó este día",
Live Activity de iOS para el timer, videos y detalle de ejercicio. Del mockup de
Entreno completado faltan (necesitan backend): +XP, nuevo PR, subida de
videos, RPE de la sesión y nota al coach (`WorkoutSession` no tiene esos
campos).
Flujo de UI acordado: Sergio ajusta el mockup → se traduce a widgets con el kit
(no FlutterFlow ni generadores Figma/HTML → Flutter).

Pendiente de marca: fuente Raleway para el wordmark "haki" (el web la usa), el
dorado del logo del web es `#C9A84C` vs. `gold` `#B8922A` del tema, e ícono de
la app + splash nativo (necesita el logo en PNG 1024×1024;
`flutter_launcher_icons` + `flutter_native_splash`).
