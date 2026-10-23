// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonSaving => 'Guardando…';

  @override
  String get errorOfflineRetry => 'Sin conexión. Probá de nuevo.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsTraining => 'Entreno';

  @override
  String get settingsWeightUnit => 'Unidad de peso';

  @override
  String get settingsWeightUnitHint => 'Con la que arranca cada sesión';

  @override
  String get settingsRestVibration => 'Vibrar al terminar el descanso';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get passwordMinLength => 'Usá al menos 6 caracteres.';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden.';

  @override
  String get passwordUpdated => 'Contraseña actualizada';

  @override
  String get passwordNew => 'Nueva contraseña';

  @override
  String get passwordRepeat => 'Repetí la contraseña';

  @override
  String get passwordSame => 'Tiene que ser distinta a la actual.';

  @override
  String get passwordWeak => 'Es muy débil. Probá con una más larga.';

  @override
  String get passwordReauth =>
      'Por seguridad, cerrá sesión, volvé a entrar y probá de nuevo.';

  @override
  String get passwordChangeFailed => 'No pudimos cambiarla. Probá de nuevo.';

  @override
  String get signOutPendingTitle => 'Tenés entrenos sin subir';

  @override
  String get signOutPendingBody =>
      'Hay series guardadas en el teléfono que todavía no llegaron a tu coach. Si cerrás sesión ahora se pierden. Conectate a internet y esperá a que se suban.';

  @override
  String get signOutAnyway => 'Cerrar igual';

  @override
  String get commonOffline => 'Sin conexión';

  @override
  String get commonToday => 'Hoy';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonBack => 'Volver';

  @override
  String get errorGeneric => 'Algo salió mal. Probá de nuevo.';

  @override
  String get slogan => 'Voluntad sobre límites.';

  @override
  String get loadingTitle => 'Cargando tu semana…';

  @override
  String get loadingSubtitle => 'Sincronizando tu programa con tu coach';

  @override
  String get tabToday => 'Hoy';

  @override
  String get tabProgram => 'Programa';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabProfile => 'Perfil';

  @override
  String homeGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get homeLoadErrorTitle => 'No pudimos cargar tu programa';

  @override
  String get homeLoadErrorBody =>
      'Revisá tu conexión y deslizá hacia abajo para reintentar.';

  @override
  String get homeYourProgram => 'Tu programa';

  @override
  String get homeNoProgramTitle => 'Todavía no tenés un programa';

  @override
  String get homeNoProgramBody => 'Cuando tu coach te asigne uno, aparece acá.';

  @override
  String get homeUpcoming => 'Próximo';

  @override
  String homeStartsOn(String date) {
    return 'Empieza el $date.';
  }

  @override
  String get homeRestLabel => 'Hoy · Descanso';

  @override
  String get homeRestTitle => 'Día de descanso';

  @override
  String homeRestNext(String title, String date) {
    return 'Próximo: $title · $date';
  }

  @override
  String get homeRestPreparing => 'Tu coach está preparando lo que sigue.';

  @override
  String weekOfTotal(int week, int total) {
    return 'Semana $week de $total';
  }

  @override
  String weekOfProgram(int week) {
    return 'Semana $week del programa';
  }

  @override
  String get homeWeekDoneTitle => 'Semana completa';

  @override
  String get homeWeekDoneBody =>
      'Hiciste todos los entrenos de esta semana. La que viene sigue el programa.';

  @override
  String get homeProgramDoneLabel => 'Programa terminado';

  @override
  String get homeProgramDoneBody =>
      'Completaste el bloque. Tu coach te va a asignar el próximo.';

  @override
  String get homeYourProfile => 'Tu perfil';

  @override
  String get homeDayPreparing => 'Tu coach lo está preparando.';

  @override
  String get stripDone => 'entreno hecho';

  @override
  String get stripPlanned => 'entreno';

  @override
  String get stripNone => 'sin entreno';

  @override
  String workoutsDoneOf(int done, int total) {
    return '$done de $total entrenos';
  }

  @override
  String exercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios',
      one: '1 ejercicio',
    );
    return '$_temp0';
  }

  @override
  String supersetsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count superseries',
      one: '1 superserie',
    );
    return '$_temp0';
  }

  @override
  String videosRequestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos pedidos',
      one: '1 video pedido',
    );
    return '$_temp0';
  }

  @override
  String get workoutCompleted => 'Entreno completado';

  @override
  String get workoutViewUploadVideos => 'Ver entreno · subir videos';

  @override
  String get workoutContinue => 'Continuar entreno';

  @override
  String get workoutStart => 'Empezar entreno';

  @override
  String get programsMine => 'Mis programas';

  @override
  String get programsLoadError => 'No pudimos cargar tus programas';

  @override
  String get programsYours => 'Tus programas';

  @override
  String get programsNoneTitle => 'Todavía no tenés programas';

  @override
  String get programInProgress => 'En curso';

  @override
  String programsUpcoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Próximos',
      one: 'Próximo',
    );
    return '$_temp0';
  }

  @override
  String get programsPast => 'Anteriores';

  @override
  String weeksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas',
      one: '1 semana',
    );
    return '$_temp0';
  }

  @override
  String weekN(int week) {
    return 'Semana $week';
  }

  @override
  String programSince(String date) {
    return 'Desde $date';
  }

  @override
  String get commonNoDates => 'sin fechas';

  @override
  String get commonNoDate => 'Sin fecha';

  @override
  String programStartsOn(String date) {
    return 'empieza el $date';
  }

  @override
  String get assignDates => 'Asignar fechas';

  @override
  String get changeDates => 'Cambiar fechas';

  @override
  String get programAdherence => 'adherencia';

  @override
  String get programCurrentBlock => 'Bloque actual';

  @override
  String get programFinished => 'Terminado';

  @override
  String get programsAll => 'Todos mis programas';

  @override
  String get programWeekPreparing => 'Tu coach está preparando esta semana.';

  @override
  String get programDayPreparing => 'Tu coach lo está preparando';

  @override
  String get dayDone => 'Hecho';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get commonOptional => 'opcional';

  @override
  String get programLoadError =>
      'No pudimos cargar el programa. Revisá tu conexión.';

  @override
  String get datesSaved => 'Fechas guardadas';

  @override
  String get datesSave => 'Guardar fechas';

  @override
  String get datesSkip => 'Ahora no · entrenar sin fechas';

  @override
  String get datesStepStart => '1 · ¿Cuándo empezás?';

  @override
  String get datesStartsOn => 'Empieza el';

  @override
  String datesEndsOn(String date) {
    return 'termina el $date';
  }

  @override
  String get datesMoveHint =>
      'Cambiar el inicio mueve en qué semana del programa estás.';

  @override
  String get datesStepDays => '2 · ¿Qué día hacés cada entreno?';

  @override
  String get datesRepeatHint => 'Se repite igual todas las semanas del bloque.';

  @override
  String get datesNoWorkouts =>
      'Tu coach todavía no armó los entrenos de este programa.';

  @override
  String get datesTooMany =>
      'Este programa tiene más de 7 entrenos por semana: pedile a tu coach que asigne las fechas.';

  @override
  String get monthPrev => 'Mes anterior';

  @override
  String get monthNext => 'Mes siguiente';

  @override
  String datesDayOn(String title, String weekday) {
    return '$title el $weekday';
  }

  @override
  String get datesFirstOccurrence => '1.º: ';

  @override
  String get sessionTitle => 'Sesión';

  @override
  String get sessionLoadError =>
      'No pudimos cargar la sesión. Revisá tu conexión.';

  @override
  String get sessionDayGone => 'Este día ya no está en el programa.';

  @override
  String get sessionCompleted => 'Completada';

  @override
  String get sessionNoSets => 'Sin series registradas';

  @override
  String get sessionYourNote => 'Tu nota';

  @override
  String sessionViewSetVideo(int set) {
    return 'Ver video de la serie $set';
  }

  @override
  String dayN(int day) {
    return 'Día $day';
  }

  @override
  String get sessionOpenError => 'No se pudo abrir la sesión.';

  @override
  String get sessionDoneSeeSummary => 'Entreno completado · ver resumen';

  @override
  String get sessionFinish => 'Finalizar entreno';

  @override
  String get videoLogSetFirst => 'Registrá la serie antes de subir el video.';

  @override
  String get videoUploadingReplace =>
      'El video se está subiendo. Si grabás otro, lo reemplaza.';

  @override
  String get videoUploadQuestion => '¿Subir video?';

  @override
  String get videoNotRequested =>
      'Tu entrenador no solicitó video para esta serie. ¿Deseás subirlo?';

  @override
  String get videoUpload => 'Subir video';

  @override
  String get videoAlreadySent => 'Ya enviaste un video de esta serie';

  @override
  String get videoReplaces => 'El nuevo lo reemplaza.';

  @override
  String get videoRecord => 'Grabar';

  @override
  String get videoPickGallery => 'Elegir de la galería';

  @override
  String get videoQueued =>
      'Video en la cola: se sube solo, aunque cierres la app.';

  @override
  String restSetDone(int set) {
    return 'Serie $set hecha';
  }

  @override
  String supersetN(String letter) {
    return 'Superserie $letter';
  }

  @override
  String restSupersetMid(String badge) {
    return '$badge hecha · seguí sin pausa';
  }

  @override
  String restBadgesDone(String badges, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$badges hechas',
      one: '$badges hecha',
    );
    return '$_temp0';
  }

  @override
  String restBeforeRepeat(String done) {
    return '$done · descansá antes de repetir';
  }

  @override
  String get finishQuestion => '¿Finalizar el entreno?';

  @override
  String finishMissingSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Te faltan registrar $count series.',
      one: 'Te falta registrar 1 serie.',
    );
    return '$_temp0';
  }

  @override
  String get finishKeepTraining => 'Seguir entrenando';

  @override
  String get finish => 'Finalizar';

  @override
  String get sessionJustStarted => 'recién empezado';

  @override
  String sessionTrainingFor(int minutes) {
    return 'entrenando hace $minutes min';
  }

  @override
  String countOf(int done, int total) {
    return '$done de $total';
  }

  @override
  String sessionPendingSync(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count series guardadas en el teléfono · se suben al tener señal',
      one: '1 serie guardada en el teléfono · se sube al tener señal',
    );
    return '$_temp0';
  }

  @override
  String get sessionUnitHint =>
      'Tocá la unidad de un ejercicio para cambiarla solo en ese.';

  @override
  String get sessionDayUnit => 'Unidad de peso del día';

  @override
  String supersetNoRest(String items) {
    return 'Sin pausa entre $items';
  }

  @override
  String get tapToOpen => 'Tocá para abrir';

  @override
  String get commonAnd => 'y';

  @override
  String get restAgain => 'Otra vez';

  @override
  String get restPause => 'Pausar';

  @override
  String get restResume => 'Seguir';

  @override
  String get restStart => 'Iniciar';

  @override
  String get restMinimize => 'Minimizar timer';

  @override
  String get restTitle => 'Descanso';

  @override
  String get restGo => '¡A darle!';

  @override
  String get restPaused => 'En pausa';

  @override
  String restOf(String total) {
    return 'de $total';
  }

  @override
  String get restDuration => 'Duración';

  @override
  String get restDurationHint => 'Se recuerda la última que usaste';

  @override
  String get restMinus15 => 'Restar 15 segundos';

  @override
  String get restPlus15 => 'Sumar 15 segundos';

  @override
  String get restReset => 'Reiniciar';

  @override
  String get restSkip => 'Saltar descanso';

  @override
  String restOfDuration(String time) {
    return 'Descanso de $time';
  }

  @override
  String setN(int set) {
    return 'Serie $set';
  }

  @override
  String get restTimer => 'Timer de descanso';

  @override
  String get restOpenTimer => 'Abrir timer de descanso';

  @override
  String restThen(String exercise, int set) {
    return 'Luego: $exercise · serie $set';
  }

  @override
  String get restResetRest => 'Reiniciar descanso';

  @override
  String get restPauseRest => 'Pausar descanso';

  @override
  String get restResumeRest => 'Seguir descanso';

  @override
  String get restCloseTimer => 'Cerrar timer';

  @override
  String get setHeader => 'SERIE';

  @override
  String get targetHeaderShort => 'OBJ.';

  @override
  String get targetHeader => 'OBJETIVO';

  @override
  String get repsHeader => 'REPS';

  @override
  String setWeightLabel(int set, String unit) {
    return 'Peso de la serie $set en $unit';
  }

  @override
  String setRepsLabel(int set) {
    return 'Repeticiones de la serie $set';
  }

  @override
  String setRirLabel(int set) {
    return 'RIR de la serie $set';
  }

  @override
  String setLog(int set) {
    return 'Cargar serie $set';
  }

  @override
  String setEdit(int set) {
    return 'Editar serie $set';
  }

  @override
  String setVideoUploading(int set) {
    return 'Video de la serie $set subiéndose';
  }

  @override
  String setVideoSent(int set) {
    return 'Video de la serie $set enviado, tocar para reemplazarlo';
  }

  @override
  String setVideoRequested(int set) {
    return 'Subir video de la serie $set, pedido por tu coach';
  }

  @override
  String setVideoNotRequested(int set) {
    return 'Subir video de la serie $set (tu coach no lo pidió)';
  }

  @override
  String get summaryError => 'No se pudo calcular el resumen.';

  @override
  String get commonDone => 'Listo';

  @override
  String get statSets => 'Series';

  @override
  String get statVolume => 'Volumen';

  @override
  String videoRequestedSets(String sets, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tu coach pidió video de las series $sets. Tocá la cámara para grabar o subir.',
      one:
          'Tu coach pidió video de la serie $sets. Tocá la cámara para grabar o subir.',
    );
    return '$_temp0';
  }

  @override
  String get exerciseComplete => 'Ejercicio completo';

  @override
  String get noSetsPrescribed => 'Sin series prescritas';

  @override
  String setsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count series',
      one: '1 serie',
    );
    return '$_temp0';
  }

  @override
  String get repsShort => 'reps';

  @override
  String setsDoneOf(int done, int total) {
    return '$done de $total series hechas';
  }

  @override
  String exerciseUnitLabel(String unit, String other) {
    return 'Unidad de este ejercicio: $unit. Tocá para cambiar a $other';
  }

  @override
  String get trimTitle => 'Recortar video';

  @override
  String get trimOpenError => 'No se pudo abrir el video.';

  @override
  String trimMax(int seconds) {
    return 'Máximo $seconds segundos';
  }

  @override
  String get trimUse => 'Usar video';

  @override
  String get notifRestDoneQuietChannel => 'Fin del descanso (sin vibrar)';

  @override
  String get notifRestDoneChannel => 'Fin del descanso';

  @override
  String get notifRestDoneChannelDesc =>
      'Aviso con sonido cuando termina el descanso';

  @override
  String get notifBackToWorkout => 'Tocá para volver al entreno';

  @override
  String get notifRestRunningChannel => 'Descanso en curso';

  @override
  String get notifRestRunningChannelDesc =>
      'Cuenta regresiva del descanso entre series';

  @override
  String get notifRestOver => 'Terminó el descanso';

  @override
  String get notifRestPaused => 'Descanso en pausa';

  @override
  String notifNextSet(String exercise, int set) {
    return 'Sigue: $exercise · serie $set';
  }

  @override
  String get exerciseTitle => 'Ejercicio';

  @override
  String get exerciseGone => 'Este ejercicio ya no está en el día.';

  @override
  String exerciseVideoFeedback(String title) {
    return 'Feedback de tu video · $title';
  }

  @override
  String get exerciseHistory => 'Historial';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String get exerciseNeverDone => 'Todavía no hiciste este ejercicio.';

  @override
  String get exerciseOfflineHistory =>
      'Sin conexión: se muestra solo lo de este programa.';

  @override
  String get exercisePlayTechnique => 'Reproducir video técnico';

  @override
  String get exerciseTechniqueVideo => 'Video técnico';

  @override
  String get exerciseHowTo => 'Cómo se hace';

  @override
  String get seeLess => 'Ver menos';

  @override
  String get seeMore => 'Ver más';

  @override
  String get exerciseCoachNote => 'NOTA DE TU COACH';

  @override
  String get exerciseE1rmEstimated => 'e1RM ESTIMADO';

  @override
  String get exerciseNewPr => 'NUEVO PR';

  @override
  String exerciseTrend(String from, String to, int count) {
    return 'Tendencia de e1RM: de $from a $to en $count sesiones';
  }

  @override
  String exerciseInBlock(String delta) {
    return '$delta en el bloque';
  }

  @override
  String exerciseVolumeToday(String volume) {
    return 'Volumen hoy $volume';
  }

  @override
  String loadMore(int count) {
    return 'Cargar más ($count)';
  }

  @override
  String get weekLastShort => 'Sem. pasada';

  @override
  String weekShortN(int week) {
    return 'Sem. $week';
  }

  @override
  String weekLetter(int week) {
    return 'S$week';
  }

  @override
  String get lastTime => 'Última vez';

  @override
  String coachLabel(String name) {
    return 'Coach: $name';
  }

  @override
  String streakWeeksInARow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas seguidas',
      one: '1 semana seguida',
    );
    return '$_temp0';
  }

  @override
  String get streakStart => 'Arrancá tu racha';

  @override
  String streakThisWeek(int done, int target) {
    return 'Esta semana: $done de $target';
  }

  @override
  String streakBest(String weeks) {
    return 'Tu mejor racha: $weeks';
  }

  @override
  String get recordsTitle => 'Récords';

  @override
  String get recordsBestMarks => 'Tus mejores marcas';

  @override
  String get recordsInTotal => 'en total';

  @override
  String get recordsInBlock => 'en este bloque';

  @override
  String get recordsRecent => 'PRs recientes';

  @override
  String get bodyWeight => 'Peso corporal';

  @override
  String get bodyLogWeight => 'Registrá tu peso';

  @override
  String get bodyIn4Weeks => 'en 4 sem';

  @override
  String get measuresTitle => 'Medidas';

  @override
  String measuresCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medidas',
      one: '1 medida',
    );
    return '$_temp0';
  }

  @override
  String get measuresNoLogs => 'sin registros';

  @override
  String get adherenceTitle => 'Adherencia';

  @override
  String get adherenceNoProgram => 'Sin programa en curso';

  @override
  String adherenceDoneOf(int done, int due) {
    return '$done de $due entrenos en el programa';
  }

  @override
  String ofTotal(int total) {
    return 'de $total';
  }

  @override
  String get adherenceWorkoutsDone => 'entrenos hechos';

  @override
  String get recordsPersonal => 'Récords personales';

  @override
  String get recordsThisBlock => 'Este bloque';

  @override
  String get recordsAllTime => 'Histórico';

  @override
  String get recordsHint =>
      'Mejor e1RM estimado por ejercicio, calculado de tus series registradas.';

  @override
  String get recordsThisWeek => 'ESTA SEMANA';

  @override
  String get recordsInThisBlockUpper => 'EN ESTE BLOQUE';

  @override
  String get recordsPreviousUpper => 'ANTERIORES';

  @override
  String get recordsEmpty =>
      'Seguí registrando tus series: cada vez que superás tu mejor marca aparece acá.';

  @override
  String get recordsLoadError =>
      'No se pudieron cargar tus récords. Revisá tu conexión.';

  @override
  String get commonYesterday => 'ayer';

  @override
  String get measureGroupTorso => 'Tronco';

  @override
  String get measureGroupLimbs => 'Brazos y piernas';

  @override
  String get measureGroupComposition => 'Composición';

  @override
  String get measureGroupOther => 'Otras';

  @override
  String get measureUnitLevel => 'nivel';

  @override
  String get range4Weeks => '4 sem';

  @override
  String get range3Months => '3 meses';

  @override
  String get rangeAll => 'Todo';

  @override
  String get measureNeck => 'Cuello';

  @override
  String get measureChest => 'Pecho';

  @override
  String get measureLeftArm => 'Brazo izquierdo';

  @override
  String get measureRightArm => 'Brazo derecho';

  @override
  String get measureLeftForearm => 'Antebrazo izquierdo';

  @override
  String get measureRightForearm => 'Antebrazo derecho';

  @override
  String get measureWaist => 'Cintura';

  @override
  String get measureAbdomen => 'Abdomen';

  @override
  String get measureHips => 'Cadera';

  @override
  String get measureLeftThigh => 'Muslo izquierdo';

  @override
  String get measureRightThigh => 'Muslo derecho';

  @override
  String get measureLeftCalf => 'Pantorrilla izquierda';

  @override
  String get measureRightCalf => 'Pantorrilla derecha';

  @override
  String get measureBodyFat => 'Grasa corporal';

  @override
  String get measureMuscleMass => 'Masa muscular';

  @override
  String get measureVisceralFat => 'Grasa visceral';

  @override
  String get bodyNoWeightYet => 'Todavía no registraste tu peso.';

  @override
  String get bodyNoMeasureYet => 'Todavía no registraste esta medida.';

  @override
  String get bodyWeightShort => 'Peso';

  @override
  String get bodyLoadError =>
      'No pudimos cargar tus datos. Revisá tu conexión.';

  @override
  String get bodyLogWeightButton => 'Registrar peso';

  @override
  String get measuresLog => 'Registrar medidas';

  @override
  String lastEntry(String date) {
    return 'Último registro · $date';
  }

  @override
  String get rangeIn4Weeks => 'en 4 semanas';

  @override
  String get rangeIn3Months => 'en 3 meses';

  @override
  String get rangeSinceStart => 'desde el inicio';

  @override
  String get bodyTwoEntriesHint =>
      'Con dos registros en este rango vas a ver el gráfico.';

  @override
  String bodyTrend(String title, String from, String to) {
    return '$title de $from a $to';
  }

  @override
  String bodyLast(String value) {
    return 'Último: $value';
  }

  @override
  String get measuresNoneChosen =>
      'Tu coach todavía no eligió medidas para tu seguimiento.';

  @override
  String get measuresNoneYet => 'Todavía no registraste medidas';

  @override
  String get measuresSeePrevious => 'Ver registros anteriores';

  @override
  String get measuresLoadError =>
      'No pudimos cargar tus medidas. Revisá tu conexión.';

  @override
  String measuresChosenBy(String coach) {
    return '$coach eligió estas medidas para tu seguimiento.';
  }

  @override
  String get measuresBlankHint => 'Podés dejar en blanco las que no midas hoy.';

  @override
  String measuresPrevious(String value) {
    return 'Anterior: $value';
  }

  @override
  String get measuresLogs => 'Registros de medidas';

  @override
  String get measuresNoneYetDot => 'Todavía no registraste medidas.';

  @override
  String get yourCoach => 'Tu coach';

  @override
  String get chatOpenError => 'No se pudo abrir el chat.\nRevisá tu conexión.';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get chatMessagesError => 'No se pudieron cargar los mensajes.';

  @override
  String chatEmpty(String coach) {
    return 'Escribile a $coach. Los videos de tus series también aparecen acá.';
  }

  @override
  String get chatMessageHint => 'Mensaje…';

  @override
  String feedbackWaiting(String coach) {
    return 'Esperando feedback de $coach';
  }

  @override
  String get you => 'Vos';

  @override
  String repliesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas',
      one: '1 respuesta',
    );
    return '$_temp0';
  }

  @override
  String get feedbackSee => 'Ver feedback';

  @override
  String get feedbackYourVideosUpper => 'TUS VIDEOS';

  @override
  String get feedbackRepliesError => 'No se pudieron cargar las respuestas.';

  @override
  String get feedbackNotReviewed => 'Tu coach todavía no lo revisó';

  @override
  String get feedbackTellCoach =>
      'Si querés contarle algo del ejercicio, escribilo acá.';

  @override
  String feedbackReplyTo(String coach) {
    return 'Responder a $coach…';
  }

  @override
  String get feedbackYourVideos => 'Feedback de tus videos';

  @override
  String videosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos',
      one: '1 video',
    );
    return '$_temp0';
  }

  @override
  String get feedbackNoneYet => 'sin feedback todavía';

  @override
  String feedbackMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes de feedback',
      one: '1 mensaje de feedback',
    );
    return '$_temp0';
  }

  @override
  String get feedbackVideoNone => 'Tu video todavía no tiene feedback';

  @override
  String messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes',
      one: '1 mensaje',
    );
    return '$_temp0';
  }

  @override
  String get feedbackSeeThread => 'Ver hilo';

  @override
  String get see => 'Ver';

  @override
  String get chatNotSent => 'No se envió · Reintentar';

  @override
  String get chatSend => 'Enviar';

  @override
  String get notifChatChannel => 'Mensajes de tu coach';

  @override
  String get notifChatChannelDesc => 'Chat y feedback de tu coach';

  @override
  String notifVideosOf(String exercise) {
    return 'Videos de $exercise';
  }

  @override
  String get notifSentMessage => 'Te mandó un mensaje';

  @override
  String notifFeedbackFrom(String name) {
    return 'Feedback de $name';
  }

  @override
  String get videoLoadError => 'No se pudo cargar el video.';

  @override
  String get authEmail => 'Email';

  @override
  String get authInvalidEmail => 'Ingresá un email válido';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authEnterPassword => 'Ingresá tu contraseña';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authContinueGoogle => 'Continuar con Google';

  @override
  String get gateCoach =>
      'Esta app es para atletas. Como coach, entrá desde hakifit.com.';

  @override
  String get gateNoCoach =>
      'Tu cuenta no está asociada a ningún coach. Pedile a tu coach que te invite y entrá con el mismo email de la invitación.';

  @override
  String get gateConnectError =>
      'No se pudo conectar. Revisá tu conexión e intentá de nuevo.';

  @override
  String get authWrongCredentials => 'Email o contraseña incorrectos';

  @override
  String get authConfirmEmail => 'Confirmá tu email antes de entrar';

  @override
  String get authGoogleError =>
      'No se pudo entrar con Google. Intentá de nuevo.';

  @override
  String get authGenericError =>
      'No se pudo iniciar sesión. Revisá tu conexión e intentá de nuevo.';

  @override
  String get sessionProgramNotCurrent => 'El programa ya no está en curso.';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonYes => 'Sí';

  @override
  String get commonNo => 'No';

  @override
  String get commonSending => 'Enviando…';

  @override
  String get questionnaireTitle => 'Cuestionario';

  @override
  String get questionnaireAnswer => 'Responder';

  @override
  String questionnairePendingSince(String date) {
    return 'Pendiente desde $date · 1 min';
  }

  @override
  String questionnaireSentOn(String date) {
    return 'Enviado $date · pendiente';
  }

  @override
  String questionnaireIntro(String coach) {
    return '$coach lo usa para ajustar tu próxima semana. Toma 1 minuto.';
  }

  @override
  String get questionnaireWorst => 'Peor';

  @override
  String get questionnaireBest => 'Mejor';

  @override
  String get questionnaireDetailHint =>
      'Contale más: dónde, cuándo, en qué ejercicio…';

  @override
  String get questionnaireTextHint => 'Escribí tu respuesta';

  @override
  String get questionnaireSend => 'Enviar';

  @override
  String questionnaireSendTo(String coach) {
    return 'Enviar a $coach';
  }

  @override
  String get questionnaireSent => '¡Listo! Tu coach ya tiene tus respuestas.';

  @override
  String get questionnaireNotFound =>
      'Este cuestionario ya fue respondido o tu coach lo quitó.';

  @override
  String get notifQuestionnaireChannel => 'Cuestionarios';

  @override
  String get notifQuestionnaireChannelDesc =>
      'Aviso cuando tu coach te envía un cuestionario';

  @override
  String get notifQuestionnaireBody =>
      'Tu coach te mandó el cuestionario de la semana. Toma 1 minuto.';

  @override
  String ofTotalShort(int done, int total) {
    return '$done de $total';
  }

  @override
  String get adherenceSets => 'Series de tus entrenos';

  @override
  String get adherencePrevious => 'Bloque anterior';

  @override
  String get adherenceNoPrevious => 'Es tu primer bloque';

  @override
  String get adherenceByWeek => 'Por semana';

  @override
  String get adherenceProgramWorkouts => 'Entrenos del programa';

  @override
  String get adherenceMissed => 'Sin completar';

  @override
  String get adherenceNotLogged => 'no registrado';

  @override
  String get adherenceCurrentBlock => 'BLOQUE ACTUAL';

  @override
  String adherenceDoneUntilToday(int done, int due) {
    return '$done de $due entrenos hasta hoy';
  }

  @override
  String adherenceDoneOfTotal(int done, int total) {
    return '$done de $total entrenos hechos';
  }

  @override
  String get adherenceLegendDone => 'Hecho';

  @override
  String get adherenceLegendMissed => 'No se hizo';

  @override
  String get adherenceLegendPending => 'Pendiente';

  @override
  String adherenceSetsFooter(int done, int total, int workouts) {
    String _temp0 = intl.Intl.pluralLogic(
      workouts,
      locale: localeName,
      other: 'en los $workouts que hiciste',
      one: 'en el que hiciste',
      zero: 'sin entrenos todavía',
    );
    return '$done de $total · $_temp0';
  }

  @override
  String get gateAccessEnded =>
      'Tu coach terminó tu plan y tu acceso a Haki venció. Si creés que es un error, escribile.';

  @override
  String homeAccessEnds(String date) {
    return 'Tu coach terminó tu plan. Podés seguir usando Haki hasta el $date.';
  }

  @override
  String coachExperience(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años de experiencia',
      one: '1 año de experiencia',
      zero: 'Menos de 1 año de experiencia',
    );
    return '$_temp0';
  }

  @override
  String get coachAbout => 'Sobre mí';

  @override
  String get coachCertifications => 'Certificaciones';

  @override
  String coachWrite(String name) {
    return 'Escribirle a $name';
  }

  @override
  String coachProfileEmpty(String name) {
    return '$name todavía no completó su perfil.';
  }
}
