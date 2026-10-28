import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get commonSaving;

  /// No description provided for @errorOfflineRetry.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Probá de nuevo.'**
  String get errorOfflineRetry;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get settingsAccount;

  /// No description provided for @settingsChangePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get settingsChangePassword;

  /// No description provided for @settingsTraining.
  ///
  /// In es, this message translates to:
  /// **'Entreno'**
  String get settingsTraining;

  /// No description provided for @settingsWeightUnit.
  ///
  /// In es, this message translates to:
  /// **'Unidad de peso'**
  String get settingsWeightUnit;

  /// No description provided for @settingsWeightUnitHint.
  ///
  /// In es, this message translates to:
  /// **'Con la que arranca cada sesión'**
  String get settingsWeightUnitHint;

  /// No description provided for @settingsRestVibration.
  ///
  /// In es, this message translates to:
  /// **'Vibrar al terminar el descanso'**
  String get settingsRestVibration;

  /// No description provided for @settingsAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get settingsSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get settingsSignOut;

  /// No description provided for @passwordMinLength.
  ///
  /// In es, this message translates to:
  /// **'Usá al menos 6 caracteres.'**
  String get passwordMinLength;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get passwordsDontMatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get passwordUpdated;

  /// No description provided for @passwordNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get passwordNew;

  /// No description provided for @passwordRepeat.
  ///
  /// In es, this message translates to:
  /// **'Repetí la contraseña'**
  String get passwordRepeat;

  /// No description provided for @passwordSame.
  ///
  /// In es, this message translates to:
  /// **'Tiene que ser distinta a la actual.'**
  String get passwordSame;

  /// No description provided for @passwordWeak.
  ///
  /// In es, this message translates to:
  /// **'Es muy débil. Probá con una más larga.'**
  String get passwordWeak;

  /// No description provided for @passwordReauth.
  ///
  /// In es, this message translates to:
  /// **'Por seguridad, cerrá sesión, volvé a entrar y probá de nuevo.'**
  String get passwordReauth;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cambiarla. Probá de nuevo.'**
  String get passwordChangeFailed;

  /// No description provided for @signOutPendingTitle.
  ///
  /// In es, this message translates to:
  /// **'Tenés entrenos sin subir'**
  String get signOutPendingTitle;

  /// No description provided for @signOutPendingBody.
  ///
  /// In es, this message translates to:
  /// **'Hay series guardadas en el teléfono que todavía no llegaron a tu coach. Si cerrás sesión ahora se pierden. Conectate a internet y esperá a que se suban.'**
  String get signOutPendingBody;

  /// No description provided for @signOutAnyway.
  ///
  /// In es, this message translates to:
  /// **'Cerrar igual'**
  String get signOutAnyway;

  /// No description provided for @commonOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get commonOffline;

  /// No description provided for @commonToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get commonToday;

  /// No description provided for @commonNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get commonBack;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Probá de nuevo.'**
  String get errorGeneric;

  /// No description provided for @slogan.
  ///
  /// In es, this message translates to:
  /// **'Voluntad sobre límites.'**
  String get slogan;

  /// No description provided for @loadingTitle.
  ///
  /// In es, this message translates to:
  /// **'Cargando tu semana…'**
  String get loadingTitle;

  /// No description provided for @loadingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando tu programa con tu coach'**
  String get loadingSubtitle;

  /// No description provided for @tabToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get tabToday;

  /// No description provided for @tabProgram.
  ///
  /// In es, this message translates to:
  /// **'Programa'**
  String get tabProgram;

  /// No description provided for @tabChat.
  ///
  /// In es, this message translates to:
  /// **'Chat'**
  String get tabChat;

  /// No description provided for @tabProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get tabProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeLoadErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu programa'**
  String get homeLoadErrorTitle;

  /// No description provided for @homeLoadErrorBody.
  ///
  /// In es, this message translates to:
  /// **'Revisá tu conexión y deslizá hacia abajo para reintentar.'**
  String get homeLoadErrorBody;

  /// No description provided for @homeYourProgram.
  ///
  /// In es, this message translates to:
  /// **'Tu programa'**
  String get homeYourProgram;

  /// No description provided for @homeNoProgramTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tenés un programa'**
  String get homeNoProgramTitle;

  /// No description provided for @homeNoProgramBody.
  ///
  /// In es, this message translates to:
  /// **'Cuando tu coach te asigne uno, aparece acá.'**
  String get homeNoProgramBody;

  /// No description provided for @homeUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximo'**
  String get homeUpcoming;

  /// No description provided for @homeStartsOn.
  ///
  /// In es, this message translates to:
  /// **'Empieza el {date}.'**
  String homeStartsOn(String date);

  /// No description provided for @homeRestLabel.
  ///
  /// In es, this message translates to:
  /// **'Hoy · Descanso'**
  String get homeRestLabel;

  /// No description provided for @homeRestTitle.
  ///
  /// In es, this message translates to:
  /// **'Día de descanso'**
  String get homeRestTitle;

  /// No description provided for @homeRestNext.
  ///
  /// In es, this message translates to:
  /// **'Próximo: {title} · {date}'**
  String homeRestNext(String title, String date);

  /// No description provided for @homeRestPreparing.
  ///
  /// In es, this message translates to:
  /// **'Tu coach está preparando lo que sigue.'**
  String get homeRestPreparing;

  /// No description provided for @weekOfTotal.
  ///
  /// In es, this message translates to:
  /// **'Semana {week} de {total}'**
  String weekOfTotal(int week, int total);

  /// No description provided for @weekOfProgram.
  ///
  /// In es, this message translates to:
  /// **'Semana {week} del programa'**
  String weekOfProgram(int week);

  /// No description provided for @homeWeekDoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Semana completa'**
  String get homeWeekDoneTitle;

  /// No description provided for @homeWeekDoneBody.
  ///
  /// In es, this message translates to:
  /// **'Hiciste todos los entrenos de esta semana. La que viene sigue el programa.'**
  String get homeWeekDoneBody;

  /// No description provided for @homeProgramDoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Programa terminado'**
  String get homeProgramDoneLabel;

  /// No description provided for @homeProgramDoneBody.
  ///
  /// In es, this message translates to:
  /// **'Completaste el bloque. Tu coach te va a asignar el próximo.'**
  String get homeProgramDoneBody;

  /// No description provided for @homeYourProfile.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil'**
  String get homeYourProfile;

  /// No description provided for @homeDayPreparing.
  ///
  /// In es, this message translates to:
  /// **'Tu coach lo está preparando.'**
  String get homeDayPreparing;

  /// No description provided for @stripDone.
  ///
  /// In es, this message translates to:
  /// **'entreno hecho'**
  String get stripDone;

  /// No description provided for @stripPlanned.
  ///
  /// In es, this message translates to:
  /// **'entreno'**
  String get stripPlanned;

  /// No description provided for @stripNone.
  ///
  /// In es, this message translates to:
  /// **'sin entreno'**
  String get stripNone;

  /// No description provided for @workoutsDoneOf.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total} entrenos'**
  String workoutsDoneOf(int done, int total);

  /// No description provided for @exercisesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 ejercicio} other{{count} ejercicios}}'**
  String exercisesCount(int count);

  /// No description provided for @supersetsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 superserie} other{{count} superseries}}'**
  String supersetsCount(int count);

  /// No description provided for @videosRequestedCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 video pedido} other{{count} videos pedidos}}'**
  String videosRequestedCount(int count);

  /// No description provided for @workoutCompleted.
  ///
  /// In es, this message translates to:
  /// **'Entreno completado'**
  String get workoutCompleted;

  /// No description provided for @workoutViewUploadVideos.
  ///
  /// In es, this message translates to:
  /// **'Ver entreno · subir videos'**
  String get workoutViewUploadVideos;

  /// No description provided for @workoutContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar entreno'**
  String get workoutContinue;

  /// No description provided for @workoutStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar entreno'**
  String get workoutStart;

  /// No description provided for @programsMine.
  ///
  /// In es, this message translates to:
  /// **'Mis programas'**
  String get programsMine;

  /// No description provided for @programsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus programas'**
  String get programsLoadError;

  /// No description provided for @programsYours.
  ///
  /// In es, this message translates to:
  /// **'Tus programas'**
  String get programsYours;

  /// No description provided for @programsNoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tenés programas'**
  String get programsNoneTitle;

  /// No description provided for @programInProgress.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get programInProgress;

  /// No description provided for @programsUpcoming.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Próximo} other{Próximos}}'**
  String programsUpcoming(int count);

  /// No description provided for @programsPast.
  ///
  /// In es, this message translates to:
  /// **'Anteriores'**
  String get programsPast;

  /// No description provided for @weeksCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 semana} other{{count} semanas}}'**
  String weeksCount(int count);

  /// No description provided for @weekN.
  ///
  /// In es, this message translates to:
  /// **'Semana {week}'**
  String weekN(int week);

  /// No description provided for @programSince.
  ///
  /// In es, this message translates to:
  /// **'Desde {date}'**
  String programSince(String date);

  /// No description provided for @commonNoDates.
  ///
  /// In es, this message translates to:
  /// **'sin fechas'**
  String get commonNoDates;

  /// No description provided for @commonNoDate.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha'**
  String get commonNoDate;

  /// No description provided for @programStartsOn.
  ///
  /// In es, this message translates to:
  /// **'empieza el {date}'**
  String programStartsOn(String date);

  /// No description provided for @assignDates.
  ///
  /// In es, this message translates to:
  /// **'Asignar fechas'**
  String get assignDates;

  /// No description provided for @changeDates.
  ///
  /// In es, this message translates to:
  /// **'Cambiar fechas'**
  String get changeDates;

  /// No description provided for @programAdherence.
  ///
  /// In es, this message translates to:
  /// **'adherencia'**
  String get programAdherence;

  /// No description provided for @programCurrentBlock.
  ///
  /// In es, this message translates to:
  /// **'Bloque actual'**
  String get programCurrentBlock;

  /// No description provided for @programFinished.
  ///
  /// In es, this message translates to:
  /// **'Terminado'**
  String get programFinished;

  /// No description provided for @programsAll.
  ///
  /// In es, this message translates to:
  /// **'Todos mis programas'**
  String get programsAll;

  /// No description provided for @programWeekPreparing.
  ///
  /// In es, this message translates to:
  /// **'Tu coach está preparando esta semana.'**
  String get programWeekPreparing;

  /// No description provided for @programDayPreparing.
  ///
  /// In es, this message translates to:
  /// **'Tu coach lo está preparando'**
  String get programDayPreparing;

  /// No description provided for @dayDone.
  ///
  /// In es, this message translates to:
  /// **'Hecho'**
  String get dayDone;

  /// No description provided for @minutesShort.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @commonOptional.
  ///
  /// In es, this message translates to:
  /// **'opcional'**
  String get commonOptional;

  /// No description provided for @programLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el programa. Revisá tu conexión.'**
  String get programLoadError;

  /// No description provided for @datesSaved.
  ///
  /// In es, this message translates to:
  /// **'Fechas guardadas'**
  String get datesSaved;

  /// No description provided for @datesSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar fechas'**
  String get datesSave;

  /// No description provided for @datesSkip.
  ///
  /// In es, this message translates to:
  /// **'Ahora no · entrenar sin fechas'**
  String get datesSkip;

  /// No description provided for @datesStepStart.
  ///
  /// In es, this message translates to:
  /// **'1 · ¿Cuándo empezás?'**
  String get datesStepStart;

  /// No description provided for @datesStartsOn.
  ///
  /// In es, this message translates to:
  /// **'Empieza el'**
  String get datesStartsOn;

  /// No description provided for @datesEndsOn.
  ///
  /// In es, this message translates to:
  /// **'termina el {date}'**
  String datesEndsOn(String date);

  /// No description provided for @datesMoveHint.
  ///
  /// In es, this message translates to:
  /// **'Cambiar el inicio mueve en qué semana del programa estás.'**
  String get datesMoveHint;

  /// No description provided for @datesStepDays.
  ///
  /// In es, this message translates to:
  /// **'2 · ¿Qué día hacés cada entreno?'**
  String get datesStepDays;

  /// No description provided for @datesRepeatHint.
  ///
  /// In es, this message translates to:
  /// **'Se repite igual todas las semanas del bloque.'**
  String get datesRepeatHint;

  /// No description provided for @datesNoWorkouts.
  ///
  /// In es, this message translates to:
  /// **'Tu coach todavía no armó los entrenos de este programa.'**
  String get datesNoWorkouts;

  /// No description provided for @datesTooMany.
  ///
  /// In es, this message translates to:
  /// **'Este programa tiene más de 7 entrenos por semana: pedile a tu coach que asigne las fechas.'**
  String get datesTooMany;

  /// No description provided for @monthPrev.
  ///
  /// In es, this message translates to:
  /// **'Mes anterior'**
  String get monthPrev;

  /// No description provided for @monthNext.
  ///
  /// In es, this message translates to:
  /// **'Mes siguiente'**
  String get monthNext;

  /// No description provided for @datesDayOn.
  ///
  /// In es, this message translates to:
  /// **'{title} el {weekday}'**
  String datesDayOn(String title, String weekday);

  /// No description provided for @datesFirstOccurrence.
  ///
  /// In es, this message translates to:
  /// **'1.º: '**
  String get datesFirstOccurrence;

  /// No description provided for @sessionTitle.
  ///
  /// In es, this message translates to:
  /// **'Sesión'**
  String get sessionTitle;

  /// No description provided for @sessionLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la sesión. Revisá tu conexión.'**
  String get sessionLoadError;

  /// No description provided for @sessionDayGone.
  ///
  /// In es, this message translates to:
  /// **'Este día ya no está en el programa.'**
  String get sessionDayGone;

  /// No description provided for @sessionCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get sessionCompleted;

  /// No description provided for @sessionNoSets.
  ///
  /// In es, this message translates to:
  /// **'Sin series registradas'**
  String get sessionNoSets;

  /// No description provided for @sessionYourNote.
  ///
  /// In es, this message translates to:
  /// **'Tu nota'**
  String get sessionYourNote;

  /// No description provided for @sessionViewSetVideo.
  ///
  /// In es, this message translates to:
  /// **'Ver video de la serie {set}'**
  String sessionViewSetVideo(int set);

  /// No description provided for @dayN.
  ///
  /// In es, this message translates to:
  /// **'Día {day}'**
  String dayN(int day);

  /// No description provided for @sessionOpenError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la sesión.'**
  String get sessionOpenError;

  /// No description provided for @sessionDoneSeeSummary.
  ///
  /// In es, this message translates to:
  /// **'Entreno completado · ver resumen'**
  String get sessionDoneSeeSummary;

  /// No description provided for @sessionFinish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar entreno'**
  String get sessionFinish;

  /// No description provided for @videoLogSetFirst.
  ///
  /// In es, this message translates to:
  /// **'Registrá la serie antes de subir el video.'**
  String get videoLogSetFirst;

  /// No description provided for @videoUploadingReplace.
  ///
  /// In es, this message translates to:
  /// **'El video se está subiendo. Si grabás otro, lo reemplaza.'**
  String get videoUploadingReplace;

  /// No description provided for @videoUploadQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Subir video?'**
  String get videoUploadQuestion;

  /// No description provided for @videoNotRequested.
  ///
  /// In es, this message translates to:
  /// **'Tu entrenador no solicitó video para esta serie. ¿Deseás subirlo?'**
  String get videoNotRequested;

  /// No description provided for @videoUpload.
  ///
  /// In es, this message translates to:
  /// **'Subir video'**
  String get videoUpload;

  /// No description provided for @videoAlreadySent.
  ///
  /// In es, this message translates to:
  /// **'Ya enviaste un video de esta serie'**
  String get videoAlreadySent;

  /// No description provided for @videoReplaces.
  ///
  /// In es, this message translates to:
  /// **'El nuevo lo reemplaza.'**
  String get videoReplaces;

  /// No description provided for @videoRecord.
  ///
  /// In es, this message translates to:
  /// **'Grabar'**
  String get videoRecord;

  /// No description provided for @videoPickGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get videoPickGallery;

  /// No description provided for @videoQueued.
  ///
  /// In es, this message translates to:
  /// **'Video en la cola: se sube solo, aunque cierres la app.'**
  String get videoQueued;

  /// No description provided for @restSetDone.
  ///
  /// In es, this message translates to:
  /// **'Serie {set} hecha'**
  String restSetDone(int set);

  /// No description provided for @supersetN.
  ///
  /// In es, this message translates to:
  /// **'Superserie {letter}'**
  String supersetN(String letter);

  /// No description provided for @restSupersetMid.
  ///
  /// In es, this message translates to:
  /// **'{badge} hecha · seguí sin pausa'**
  String restSupersetMid(String badge);

  /// No description provided for @restBadgesDone.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{badges} hecha} other{{badges} hechas}}'**
  String restBadgesDone(String badges, int count);

  /// No description provided for @restBeforeRepeat.
  ///
  /// In es, this message translates to:
  /// **'{done} · descansá antes de repetir'**
  String restBeforeRepeat(String done);

  /// No description provided for @finishQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Finalizar el entreno?'**
  String get finishQuestion;

  /// No description provided for @finishMissingSets.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Te falta registrar 1 serie.} other{Te faltan registrar {count} series.}}'**
  String finishMissingSets(int count);

  /// No description provided for @finishKeepTraining.
  ///
  /// In es, this message translates to:
  /// **'Seguir entrenando'**
  String get finishKeepTraining;

  /// No description provided for @finish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get finish;

  /// No description provided for @sessionJustStarted.
  ///
  /// In es, this message translates to:
  /// **'recién empezado'**
  String get sessionJustStarted;

  /// No description provided for @sessionTrainingFor.
  ///
  /// In es, this message translates to:
  /// **'entrenando hace {minutes} min'**
  String sessionTrainingFor(int minutes);

  /// No description provided for @sessionStartedOn.
  ///
  /// In es, this message translates to:
  /// **'empezado el {date}'**
  String sessionStartedOn(String date);

  /// No description provided for @countOf.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total}'**
  String countOf(int done, int total);

  /// No description provided for @sessionPendingSync.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 serie guardada en el teléfono · se sube al tener señal} other{{count} series guardadas en el teléfono · se suben al tener señal}}'**
  String sessionPendingSync(int count);

  /// No description provided for @sessionDayUnit.
  ///
  /// In es, this message translates to:
  /// **'Unidad de peso del día'**
  String get sessionDayUnit;

  /// No description provided for @supersetNoRest.
  ///
  /// In es, this message translates to:
  /// **'Sin pausa entre {items}'**
  String supersetNoRest(String items);

  /// No description provided for @tapToOpen.
  ///
  /// In es, this message translates to:
  /// **'Tocá para abrir'**
  String get tapToOpen;

  /// No description provided for @commonAnd.
  ///
  /// In es, this message translates to:
  /// **'y'**
  String get commonAnd;

  /// No description provided for @restAgain.
  ///
  /// In es, this message translates to:
  /// **'Otra vez'**
  String get restAgain;

  /// No description provided for @restPause.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get restPause;

  /// No description provided for @restResume.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get restResume;

  /// No description provided for @restStart.
  ///
  /// In es, this message translates to:
  /// **'Iniciar'**
  String get restStart;

  /// No description provided for @restMinimize.
  ///
  /// In es, this message translates to:
  /// **'Minimizar timer'**
  String get restMinimize;

  /// No description provided for @restTitle.
  ///
  /// In es, this message translates to:
  /// **'Descanso'**
  String get restTitle;

  /// No description provided for @restGo.
  ///
  /// In es, this message translates to:
  /// **'¡A darle!'**
  String get restGo;

  /// No description provided for @restPaused.
  ///
  /// In es, this message translates to:
  /// **'En pausa'**
  String get restPaused;

  /// No description provided for @restOf.
  ///
  /// In es, this message translates to:
  /// **'de {total}'**
  String restOf(String total);

  /// No description provided for @restDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get restDuration;

  /// No description provided for @restDurationHint.
  ///
  /// In es, this message translates to:
  /// **'Se recuerda la última que usaste'**
  String get restDurationHint;

  /// No description provided for @restMinus15.
  ///
  /// In es, this message translates to:
  /// **'Restar 15 segundos'**
  String get restMinus15;

  /// No description provided for @restPlus15.
  ///
  /// In es, this message translates to:
  /// **'Sumar 15 segundos'**
  String get restPlus15;

  /// No description provided for @restReset.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar'**
  String get restReset;

  /// No description provided for @restSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar descanso'**
  String get restSkip;

  /// No description provided for @restOfDuration.
  ///
  /// In es, this message translates to:
  /// **'Descanso de {time}'**
  String restOfDuration(String time);

  /// No description provided for @setN.
  ///
  /// In es, this message translates to:
  /// **'Serie {set}'**
  String setN(int set);

  /// No description provided for @restTimer.
  ///
  /// In es, this message translates to:
  /// **'Timer de descanso'**
  String get restTimer;

  /// No description provided for @restOpenTimer.
  ///
  /// In es, this message translates to:
  /// **'Abrir timer de descanso'**
  String get restOpenTimer;

  /// No description provided for @restThen.
  ///
  /// In es, this message translates to:
  /// **'Luego: {exercise} · serie {set}'**
  String restThen(String exercise, int set);

  /// No description provided for @restResetRest.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar descanso'**
  String get restResetRest;

  /// No description provided for @restPauseRest.
  ///
  /// In es, this message translates to:
  /// **'Pausar descanso'**
  String get restPauseRest;

  /// No description provided for @restResumeRest.
  ///
  /// In es, this message translates to:
  /// **'Seguir descanso'**
  String get restResumeRest;

  /// No description provided for @restCloseTimer.
  ///
  /// In es, this message translates to:
  /// **'Cerrar timer'**
  String get restCloseTimer;

  /// No description provided for @setHeader.
  ///
  /// In es, this message translates to:
  /// **'SERIE'**
  String get setHeader;

  /// No description provided for @targetHeaderShort.
  ///
  /// In es, this message translates to:
  /// **'OBJ.'**
  String get targetHeaderShort;

  /// No description provided for @targetHeader.
  ///
  /// In es, this message translates to:
  /// **'OBJETIVO'**
  String get targetHeader;

  /// No description provided for @repsHeader.
  ///
  /// In es, this message translates to:
  /// **'REPS'**
  String get repsHeader;

  /// No description provided for @setWeightLabel.
  ///
  /// In es, this message translates to:
  /// **'Peso de la serie {set} en {unit}'**
  String setWeightLabel(int set, String unit);

  /// No description provided for @setRepsLabel.
  ///
  /// In es, this message translates to:
  /// **'Repeticiones de la serie {set}'**
  String setRepsLabel(int set);

  /// No description provided for @setRirLabel.
  ///
  /// In es, this message translates to:
  /// **'RIR de la serie {set}'**
  String setRirLabel(int set);

  /// No description provided for @setLog.
  ///
  /// In es, this message translates to:
  /// **'Cargar serie {set}'**
  String setLog(int set);

  /// No description provided for @setEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar serie {set}'**
  String setEdit(int set);

  /// No description provided for @setVideoUploading.
  ///
  /// In es, this message translates to:
  /// **'Video de la serie {set} subiéndose'**
  String setVideoUploading(int set);

  /// No description provided for @setVideoSent.
  ///
  /// In es, this message translates to:
  /// **'Video de la serie {set} enviado, tocar para reemplazarlo'**
  String setVideoSent(int set);

  /// No description provided for @setVideoRequested.
  ///
  /// In es, this message translates to:
  /// **'Subir video de la serie {set}, pedido por tu coach'**
  String setVideoRequested(int set);

  /// No description provided for @setVideoNotRequested.
  ///
  /// In es, this message translates to:
  /// **'Subir video de la serie {set} (tu coach no lo pidió)'**
  String setVideoNotRequested(int set);

  /// No description provided for @summaryError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo calcular el resumen.'**
  String get summaryError;

  /// No description provided for @commonDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get commonDone;

  /// No description provided for @statSets.
  ///
  /// In es, this message translates to:
  /// **'Series'**
  String get statSets;

  /// No description provided for @statVolume.
  ///
  /// In es, this message translates to:
  /// **'Volumen'**
  String get statVolume;

  /// No description provided for @videoRequestedSets.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Tu coach pidió video de la serie {sets}. Tocá la cámara para grabar o subir.} other{Tu coach pidió video de las series {sets}. Tocá la cámara para grabar o subir.}}'**
  String videoRequestedSets(String sets, int count);

  /// No description provided for @exerciseComplete.
  ///
  /// In es, this message translates to:
  /// **'Ejercicio completo'**
  String get exerciseComplete;

  /// No description provided for @noSetsPrescribed.
  ///
  /// In es, this message translates to:
  /// **'Sin series prescritas'**
  String get noSetsPrescribed;

  /// No description provided for @setsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 serie} other{{count} series}}'**
  String setsCount(int count);

  /// No description provided for @repsShort.
  ///
  /// In es, this message translates to:
  /// **'reps'**
  String get repsShort;

  /// No description provided for @setsDoneOf.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total} series hechas'**
  String setsDoneOf(int done, int total);

  /// No description provided for @trimTitle.
  ///
  /// In es, this message translates to:
  /// **'Recortar video'**
  String get trimTitle;

  /// No description provided for @trimOpenError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el video.'**
  String get trimOpenError;

  /// No description provided for @trimMax.
  ///
  /// In es, this message translates to:
  /// **'Máximo {seconds} segundos'**
  String trimMax(int seconds);

  /// No description provided for @trimUse.
  ///
  /// In es, this message translates to:
  /// **'Usar video'**
  String get trimUse;

  /// No description provided for @notifRestDoneQuietChannel.
  ///
  /// In es, this message translates to:
  /// **'Fin del descanso (sin vibrar)'**
  String get notifRestDoneQuietChannel;

  /// No description provided for @notifRestDoneChannel.
  ///
  /// In es, this message translates to:
  /// **'Fin del descanso'**
  String get notifRestDoneChannel;

  /// No description provided for @notifRestDoneChannelDesc.
  ///
  /// In es, this message translates to:
  /// **'Aviso con sonido cuando termina el descanso'**
  String get notifRestDoneChannelDesc;

  /// No description provided for @notifBackToWorkout.
  ///
  /// In es, this message translates to:
  /// **'Tocá para volver al entreno'**
  String get notifBackToWorkout;

  /// No description provided for @notifRestRunningChannel.
  ///
  /// In es, this message translates to:
  /// **'Descanso en curso'**
  String get notifRestRunningChannel;

  /// No description provided for @notifRestRunningChannelDesc.
  ///
  /// In es, this message translates to:
  /// **'Cuenta regresiva del descanso entre series'**
  String get notifRestRunningChannelDesc;

  /// No description provided for @notifRestOver.
  ///
  /// In es, this message translates to:
  /// **'Terminó el descanso'**
  String get notifRestOver;

  /// No description provided for @notifRestPaused.
  ///
  /// In es, this message translates to:
  /// **'Descanso en pausa'**
  String get notifRestPaused;

  /// No description provided for @notifNextSet.
  ///
  /// In es, this message translates to:
  /// **'Sigue: {exercise} · serie {set}'**
  String notifNextSet(String exercise, int set);

  /// No description provided for @exerciseTitle.
  ///
  /// In es, this message translates to:
  /// **'Ejercicio'**
  String get exerciseTitle;

  /// No description provided for @exerciseGone.
  ///
  /// In es, this message translates to:
  /// **'Este ejercicio ya no está en el día.'**
  String get exerciseGone;

  /// No description provided for @exerciseVideoFeedback.
  ///
  /// In es, this message translates to:
  /// **'Feedback de tu video · {title}'**
  String exerciseVideoFeedback(String title);

  /// No description provided for @exerciseHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get exerciseHistory;

  /// No description provided for @commonLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get commonLoading;

  /// No description provided for @exerciseNeverDone.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hiciste este ejercicio.'**
  String get exerciseNeverDone;

  /// No description provided for @exerciseOfflineHistory.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: se muestra solo lo de este programa.'**
  String get exerciseOfflineHistory;

  /// No description provided for @exercisePlayTechnique.
  ///
  /// In es, this message translates to:
  /// **'Reproducir video técnico'**
  String get exercisePlayTechnique;

  /// No description provided for @exerciseTechniqueVideo.
  ///
  /// In es, this message translates to:
  /// **'Video técnico'**
  String get exerciseTechniqueVideo;

  /// No description provided for @exerciseHowTo.
  ///
  /// In es, this message translates to:
  /// **'Cómo se hace'**
  String get exerciseHowTo;

  /// No description provided for @seeLess.
  ///
  /// In es, this message translates to:
  /// **'Ver menos'**
  String get seeLess;

  /// No description provided for @seeMore.
  ///
  /// In es, this message translates to:
  /// **'Ver más'**
  String get seeMore;

  /// No description provided for @exerciseCoachNote.
  ///
  /// In es, this message translates to:
  /// **'NOTA DE TU COACH'**
  String get exerciseCoachNote;

  /// No description provided for @exerciseE1rmEstimated.
  ///
  /// In es, this message translates to:
  /// **'e1RM ESTIMADO'**
  String get exerciseE1rmEstimated;

  /// No description provided for @exerciseNewPr.
  ///
  /// In es, this message translates to:
  /// **'NUEVO PR'**
  String get exerciseNewPr;

  /// No description provided for @exerciseTrend.
  ///
  /// In es, this message translates to:
  /// **'Tendencia de e1RM: de {from} a {to} en {count} sesiones'**
  String exerciseTrend(String from, String to, int count);

  /// No description provided for @exerciseInBlock.
  ///
  /// In es, this message translates to:
  /// **'{delta} en el bloque'**
  String exerciseInBlock(String delta);

  /// No description provided for @exerciseVolumeToday.
  ///
  /// In es, this message translates to:
  /// **'Volumen hoy {volume}'**
  String exerciseVolumeToday(String volume);

  /// No description provided for @loadMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más ({count})'**
  String loadMore(int count);

  /// No description provided for @weekLastShort.
  ///
  /// In es, this message translates to:
  /// **'Sem. pasada'**
  String get weekLastShort;

  /// No description provided for @weekShortN.
  ///
  /// In es, this message translates to:
  /// **'Sem. {week}'**
  String weekShortN(int week);

  /// No description provided for @weekLetter.
  ///
  /// In es, this message translates to:
  /// **'S{week}'**
  String weekLetter(int week);

  /// No description provided for @lastTime.
  ///
  /// In es, this message translates to:
  /// **'Última vez'**
  String get lastTime;

  /// No description provided for @coachLabel.
  ///
  /// In es, this message translates to:
  /// **'Coach: {name}'**
  String coachLabel(String name);

  /// No description provided for @streakWeeksInARow.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 semana seguida} other{{count} semanas seguidas}}'**
  String streakWeeksInARow(int count);

  /// No description provided for @streakStart.
  ///
  /// In es, this message translates to:
  /// **'Arrancá tu racha'**
  String get streakStart;

  /// No description provided for @streakThisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana: {done} de {target}'**
  String streakThisWeek(int done, int target);

  /// No description provided for @streakBest.
  ///
  /// In es, this message translates to:
  /// **'Tu mejor racha: {weeks}'**
  String streakBest(String weeks);

  /// No description provided for @recordsTitle.
  ///
  /// In es, this message translates to:
  /// **'Récords'**
  String get recordsTitle;

  /// No description provided for @recordsBestMarks.
  ///
  /// In es, this message translates to:
  /// **'Tus mejores marcas'**
  String get recordsBestMarks;

  /// No description provided for @recordsInTotal.
  ///
  /// In es, this message translates to:
  /// **'en total'**
  String get recordsInTotal;

  /// No description provided for @recordsInBlock.
  ///
  /// In es, this message translates to:
  /// **'en este bloque'**
  String get recordsInBlock;

  /// No description provided for @recordsRecent.
  ///
  /// In es, this message translates to:
  /// **'PRs recientes'**
  String get recordsRecent;

  /// No description provided for @bodyWeight.
  ///
  /// In es, this message translates to:
  /// **'Peso corporal'**
  String get bodyWeight;

  /// No description provided for @bodyLogWeight.
  ///
  /// In es, this message translates to:
  /// **'Registrá tu peso'**
  String get bodyLogWeight;

  /// No description provided for @bodyIn4Weeks.
  ///
  /// In es, this message translates to:
  /// **'en 4 sem'**
  String get bodyIn4Weeks;

  /// No description provided for @measuresTitle.
  ///
  /// In es, this message translates to:
  /// **'Medidas'**
  String get measuresTitle;

  /// No description provided for @measuresCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 medida} other{{count} medidas}}'**
  String measuresCount(int count);

  /// No description provided for @measuresNoLogs.
  ///
  /// In es, this message translates to:
  /// **'sin registros'**
  String get measuresNoLogs;

  /// No description provided for @adherenceTitle.
  ///
  /// In es, this message translates to:
  /// **'Adherencia'**
  String get adherenceTitle;

  /// No description provided for @adherenceNoProgram.
  ///
  /// In es, this message translates to:
  /// **'Sin programa en curso'**
  String get adherenceNoProgram;

  /// No description provided for @adherenceDoneOf.
  ///
  /// In es, this message translates to:
  /// **'{done} de {due} entrenos en el programa'**
  String adherenceDoneOf(int done, int due);

  /// No description provided for @ofTotal.
  ///
  /// In es, this message translates to:
  /// **'de {total}'**
  String ofTotal(int total);

  /// No description provided for @adherenceWorkoutsDone.
  ///
  /// In es, this message translates to:
  /// **'entrenos hechos'**
  String get adherenceWorkoutsDone;

  /// No description provided for @recordsPersonal.
  ///
  /// In es, this message translates to:
  /// **'Récords personales'**
  String get recordsPersonal;

  /// No description provided for @recordsThisBlock.
  ///
  /// In es, this message translates to:
  /// **'Este bloque'**
  String get recordsThisBlock;

  /// No description provided for @recordsAllTime.
  ///
  /// In es, this message translates to:
  /// **'Histórico'**
  String get recordsAllTime;

  /// No description provided for @recordsHint.
  ///
  /// In es, this message translates to:
  /// **'Mejor e1RM estimado por ejercicio, calculado de tus series registradas.'**
  String get recordsHint;

  /// No description provided for @recordsThisWeek.
  ///
  /// In es, this message translates to:
  /// **'ESTA SEMANA'**
  String get recordsThisWeek;

  /// No description provided for @recordsInThisBlockUpper.
  ///
  /// In es, this message translates to:
  /// **'EN ESTE BLOQUE'**
  String get recordsInThisBlockUpper;

  /// No description provided for @recordsPreviousUpper.
  ///
  /// In es, this message translates to:
  /// **'ANTERIORES'**
  String get recordsPreviousUpper;

  /// No description provided for @recordsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Seguí registrando tus series: cada vez que superás tu mejor marca aparece acá.'**
  String get recordsEmpty;

  /// No description provided for @recordsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar tus récords. Revisá tu conexión.'**
  String get recordsLoadError;

  /// No description provided for @commonYesterday.
  ///
  /// In es, this message translates to:
  /// **'ayer'**
  String get commonYesterday;

  /// No description provided for @measureGroupTorso.
  ///
  /// In es, this message translates to:
  /// **'Tronco'**
  String get measureGroupTorso;

  /// No description provided for @measureGroupLimbs.
  ///
  /// In es, this message translates to:
  /// **'Brazos y piernas'**
  String get measureGroupLimbs;

  /// No description provided for @measureGroupComposition.
  ///
  /// In es, this message translates to:
  /// **'Composición'**
  String get measureGroupComposition;

  /// No description provided for @measureGroupOther.
  ///
  /// In es, this message translates to:
  /// **'Otras'**
  String get measureGroupOther;

  /// No description provided for @measureUnitLevel.
  ///
  /// In es, this message translates to:
  /// **'nivel'**
  String get measureUnitLevel;

  /// No description provided for @range4Weeks.
  ///
  /// In es, this message translates to:
  /// **'4 sem'**
  String get range4Weeks;

  /// No description provided for @range3Months.
  ///
  /// In es, this message translates to:
  /// **'3 meses'**
  String get range3Months;

  /// No description provided for @rangeAll.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get rangeAll;

  /// No description provided for @measureNeck.
  ///
  /// In es, this message translates to:
  /// **'Cuello'**
  String get measureNeck;

  /// No description provided for @measureChest.
  ///
  /// In es, this message translates to:
  /// **'Pecho'**
  String get measureChest;

  /// No description provided for @measureLeftArm.
  ///
  /// In es, this message translates to:
  /// **'Brazo izquierdo'**
  String get measureLeftArm;

  /// No description provided for @measureRightArm.
  ///
  /// In es, this message translates to:
  /// **'Brazo derecho'**
  String get measureRightArm;

  /// No description provided for @measureLeftForearm.
  ///
  /// In es, this message translates to:
  /// **'Antebrazo izquierdo'**
  String get measureLeftForearm;

  /// No description provided for @measureRightForearm.
  ///
  /// In es, this message translates to:
  /// **'Antebrazo derecho'**
  String get measureRightForearm;

  /// No description provided for @measureWaist.
  ///
  /// In es, this message translates to:
  /// **'Cintura'**
  String get measureWaist;

  /// No description provided for @measureAbdomen.
  ///
  /// In es, this message translates to:
  /// **'Abdomen'**
  String get measureAbdomen;

  /// No description provided for @measureHips.
  ///
  /// In es, this message translates to:
  /// **'Cadera'**
  String get measureHips;

  /// No description provided for @measureLeftThigh.
  ///
  /// In es, this message translates to:
  /// **'Muslo izquierdo'**
  String get measureLeftThigh;

  /// No description provided for @measureRightThigh.
  ///
  /// In es, this message translates to:
  /// **'Muslo derecho'**
  String get measureRightThigh;

  /// No description provided for @measureLeftCalf.
  ///
  /// In es, this message translates to:
  /// **'Pantorrilla izquierda'**
  String get measureLeftCalf;

  /// No description provided for @measureRightCalf.
  ///
  /// In es, this message translates to:
  /// **'Pantorrilla derecha'**
  String get measureRightCalf;

  /// No description provided for @measureBodyFat.
  ///
  /// In es, this message translates to:
  /// **'Grasa corporal'**
  String get measureBodyFat;

  /// No description provided for @measureMuscleMass.
  ///
  /// In es, this message translates to:
  /// **'Masa muscular'**
  String get measureMuscleMass;

  /// No description provided for @measureVisceralFat.
  ///
  /// In es, this message translates to:
  /// **'Grasa visceral'**
  String get measureVisceralFat;

  /// No description provided for @bodyNoWeightYet.
  ///
  /// In es, this message translates to:
  /// **'Todavía no registraste tu peso.'**
  String get bodyNoWeightYet;

  /// No description provided for @bodyNoMeasureYet.
  ///
  /// In es, this message translates to:
  /// **'Todavía no registraste esta medida.'**
  String get bodyNoMeasureYet;

  /// No description provided for @bodyWeightShort.
  ///
  /// In es, this message translates to:
  /// **'Peso'**
  String get bodyWeightShort;

  /// No description provided for @bodyLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus datos. Revisá tu conexión.'**
  String get bodyLoadError;

  /// No description provided for @bodyLogWeightButton.
  ///
  /// In es, this message translates to:
  /// **'Registrar peso'**
  String get bodyLogWeightButton;

  /// No description provided for @measuresLog.
  ///
  /// In es, this message translates to:
  /// **'Registrar medidas'**
  String get measuresLog;

  /// No description provided for @lastEntry.
  ///
  /// In es, this message translates to:
  /// **'Último registro · {date}'**
  String lastEntry(String date);

  /// No description provided for @rangeIn4Weeks.
  ///
  /// In es, this message translates to:
  /// **'en 4 semanas'**
  String get rangeIn4Weeks;

  /// No description provided for @rangeIn3Months.
  ///
  /// In es, this message translates to:
  /// **'en 3 meses'**
  String get rangeIn3Months;

  /// No description provided for @rangeSinceStart.
  ///
  /// In es, this message translates to:
  /// **'desde el inicio'**
  String get rangeSinceStart;

  /// No description provided for @bodyTwoEntriesHint.
  ///
  /// In es, this message translates to:
  /// **'Con dos registros en este rango vas a ver el gráfico.'**
  String get bodyTwoEntriesHint;

  /// No description provided for @bodyTrend.
  ///
  /// In es, this message translates to:
  /// **'{title} de {from} a {to}'**
  String bodyTrend(String title, String from, String to);

  /// No description provided for @bodyLast.
  ///
  /// In es, this message translates to:
  /// **'Último: {value}'**
  String bodyLast(String value);

  /// No description provided for @measuresNoneChosen.
  ///
  /// In es, this message translates to:
  /// **'Tu coach todavía no eligió medidas para tu seguimiento.'**
  String get measuresNoneChosen;

  /// No description provided for @measuresNoneYet.
  ///
  /// In es, this message translates to:
  /// **'Todavía no registraste medidas'**
  String get measuresNoneYet;

  /// No description provided for @measuresSeePrevious.
  ///
  /// In es, this message translates to:
  /// **'Ver registros anteriores'**
  String get measuresSeePrevious;

  /// No description provided for @measuresLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus medidas. Revisá tu conexión.'**
  String get measuresLoadError;

  /// No description provided for @measuresChosenBy.
  ///
  /// In es, this message translates to:
  /// **'{coach} eligió estas medidas para tu seguimiento.'**
  String measuresChosenBy(String coach);

  /// No description provided for @measuresBlankHint.
  ///
  /// In es, this message translates to:
  /// **'Podés dejar en blanco las que no midas hoy.'**
  String get measuresBlankHint;

  /// No description provided for @measuresPrevious.
  ///
  /// In es, this message translates to:
  /// **'Anterior: {value}'**
  String measuresPrevious(String value);

  /// No description provided for @measuresLogs.
  ///
  /// In es, this message translates to:
  /// **'Registros de medidas'**
  String get measuresLogs;

  /// No description provided for @measuresNoneYetDot.
  ///
  /// In es, this message translates to:
  /// **'Todavía no registraste medidas.'**
  String get measuresNoneYetDot;

  /// No description provided for @yourCoach.
  ///
  /// In es, this message translates to:
  /// **'Tu coach'**
  String get yourCoach;

  /// No description provided for @chatOpenError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el chat.\nRevisá tu conexión.'**
  String get chatOpenError;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @chatMessagesError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los mensajes.'**
  String get chatMessagesError;

  /// No description provided for @chatEmpty.
  ///
  /// In es, this message translates to:
  /// **'Escribile a {coach}. Los videos de tus series también aparecen acá.'**
  String chatEmpty(String coach);

  /// No description provided for @chatMessageHint.
  ///
  /// In es, this message translates to:
  /// **'Mensaje…'**
  String get chatMessageHint;

  /// No description provided for @feedbackWaiting.
  ///
  /// In es, this message translates to:
  /// **'Esperando feedback de {coach}'**
  String feedbackWaiting(String coach);

  /// No description provided for @you.
  ///
  /// In es, this message translates to:
  /// **'Vos'**
  String get you;

  /// No description provided for @repliesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 respuesta} other{{count} respuestas}}'**
  String repliesCount(int count);

  /// No description provided for @feedbackSee.
  ///
  /// In es, this message translates to:
  /// **'Ver feedback'**
  String get feedbackSee;

  /// No description provided for @feedbackYourVideosUpper.
  ///
  /// In es, this message translates to:
  /// **'TUS VIDEOS'**
  String get feedbackYourVideosUpper;

  /// No description provided for @feedbackRepliesError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las respuestas.'**
  String get feedbackRepliesError;

  /// No description provided for @feedbackNotReviewed.
  ///
  /// In es, this message translates to:
  /// **'Tu coach todavía no lo revisó'**
  String get feedbackNotReviewed;

  /// No description provided for @feedbackTellCoach.
  ///
  /// In es, this message translates to:
  /// **'Si querés contarle algo del ejercicio, escribilo acá.'**
  String get feedbackTellCoach;

  /// No description provided for @feedbackReplyTo.
  ///
  /// In es, this message translates to:
  /// **'Responder a {coach}…'**
  String feedbackReplyTo(String coach);

  /// No description provided for @feedbackYourVideos.
  ///
  /// In es, this message translates to:
  /// **'Feedback de tus videos'**
  String get feedbackYourVideos;

  /// No description provided for @videosCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 video} other{{count} videos}}'**
  String videosCount(int count);

  /// No description provided for @feedbackNoneYet.
  ///
  /// In es, this message translates to:
  /// **'sin feedback todavía'**
  String get feedbackNoneYet;

  /// No description provided for @feedbackMessagesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 mensaje de feedback} other{{count} mensajes de feedback}}'**
  String feedbackMessagesCount(int count);

  /// No description provided for @feedbackVideoNone.
  ///
  /// In es, this message translates to:
  /// **'Tu video todavía no tiene feedback'**
  String get feedbackVideoNone;

  /// No description provided for @messagesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 mensaje} other{{count} mensajes}}'**
  String messagesCount(int count);

  /// No description provided for @feedbackSeeThread.
  ///
  /// In es, this message translates to:
  /// **'Ver hilo'**
  String get feedbackSeeThread;

  /// No description provided for @see.
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get see;

  /// No description provided for @chatNotSent.
  ///
  /// In es, this message translates to:
  /// **'No se envió · Reintentar'**
  String get chatNotSent;

  /// No description provided for @chatSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get chatSend;

  /// No description provided for @notifChatChannel.
  ///
  /// In es, this message translates to:
  /// **'Mensajes de tu coach'**
  String get notifChatChannel;

  /// No description provided for @notifChatChannelDesc.
  ///
  /// In es, this message translates to:
  /// **'Chat y feedback de tu coach'**
  String get notifChatChannelDesc;

  /// No description provided for @notifVideosOf.
  ///
  /// In es, this message translates to:
  /// **'Videos de {exercise}'**
  String notifVideosOf(String exercise);

  /// No description provided for @notifSentMessage.
  ///
  /// In es, this message translates to:
  /// **'Te mandó un mensaje'**
  String get notifSentMessage;

  /// No description provided for @notifFeedbackFrom.
  ///
  /// In es, this message translates to:
  /// **'Feedback de {name}'**
  String notifFeedbackFrom(String name);

  /// No description provided for @videoLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el video.'**
  String get videoLoadError;

  /// No description provided for @authEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresá un email válido'**
  String get authInvalidEmail;

  /// No description provided for @authPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPassword;

  /// No description provided for @authEnterPassword.
  ///
  /// In es, this message translates to:
  /// **'Ingresá tu contraseña'**
  String get authEnterPassword;

  /// No description provided for @authSignIn.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get authSignIn;

  /// No description provided for @authContinueGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get authContinueGoogle;

  /// No description provided for @gateCoach.
  ///
  /// In es, this message translates to:
  /// **'Esta app es para atletas. Como coach, entrá desde hakifit.com.'**
  String get gateCoach;

  /// No description provided for @gateConnectError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar. Revisá tu conexión e intentá de nuevo.'**
  String get gateConnectError;

  /// No description provided for @authWrongCredentials.
  ///
  /// In es, this message translates to:
  /// **'Email o contraseña incorrectos'**
  String get authWrongCredentials;

  /// No description provided for @authConfirmEmail.
  ///
  /// In es, this message translates to:
  /// **'Confirmá tu email antes de entrar'**
  String get authConfirmEmail;

  /// No description provided for @authGoogleError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo entrar con Google. Intentá de nuevo.'**
  String get authGoogleError;

  /// No description provided for @authGenericError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar sesión. Revisá tu conexión e intentá de nuevo.'**
  String get authGenericError;

  /// No description provided for @sessionProgramNotCurrent.
  ///
  /// In es, this message translates to:
  /// **'El programa ya no está en curso.'**
  String get sessionProgramNotCurrent;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @commonYes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonSending.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get commonSending;

  /// No description provided for @questionnaireTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuestionario'**
  String get questionnaireTitle;

  /// No description provided for @questionnaireAnswer.
  ///
  /// In es, this message translates to:
  /// **'Responder'**
  String get questionnaireAnswer;

  /// No description provided for @questionnairePendingSince.
  ///
  /// In es, this message translates to:
  /// **'Pendiente desde {date} · 1 min'**
  String questionnairePendingSince(String date);

  /// No description provided for @questionnaireSentOn.
  ///
  /// In es, this message translates to:
  /// **'Enviado {date} · pendiente'**
  String questionnaireSentOn(String date);

  /// No description provided for @questionnaireIntro.
  ///
  /// In es, this message translates to:
  /// **'{coach} lo usa para ajustar tu próxima semana. Toma 1 minuto.'**
  String questionnaireIntro(String coach);

  /// No description provided for @questionnaireWorst.
  ///
  /// In es, this message translates to:
  /// **'Peor'**
  String get questionnaireWorst;

  /// No description provided for @questionnaireBest.
  ///
  /// In es, this message translates to:
  /// **'Mejor'**
  String get questionnaireBest;

  /// No description provided for @questionnaireDetailHint.
  ///
  /// In es, this message translates to:
  /// **'Contale más: dónde, cuándo, en qué ejercicio…'**
  String get questionnaireDetailHint;

  /// No description provided for @questionnaireTextHint.
  ///
  /// In es, this message translates to:
  /// **'Escribí tu respuesta'**
  String get questionnaireTextHint;

  /// No description provided for @questionnaireSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get questionnaireSend;

  /// No description provided for @questionnaireSendTo.
  ///
  /// In es, this message translates to:
  /// **'Enviar a {coach}'**
  String questionnaireSendTo(String coach);

  /// No description provided for @questionnaireSent.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Tu coach ya tiene tus respuestas.'**
  String get questionnaireSent;

  /// No description provided for @questionnaireNotFound.
  ///
  /// In es, this message translates to:
  /// **'Este cuestionario ya fue respondido o tu coach lo quitó.'**
  String get questionnaireNotFound;

  /// No description provided for @notifQuestionnaireChannel.
  ///
  /// In es, this message translates to:
  /// **'Cuestionarios'**
  String get notifQuestionnaireChannel;

  /// No description provided for @notifQuestionnaireChannelDesc.
  ///
  /// In es, this message translates to:
  /// **'Aviso cuando tu coach te envía un cuestionario'**
  String get notifQuestionnaireChannelDesc;

  /// No description provided for @notifQuestionnaireBody.
  ///
  /// In es, this message translates to:
  /// **'Tu coach te mandó el cuestionario de la semana. Toma 1 minuto.'**
  String get notifQuestionnaireBody;

  /// No description provided for @ofTotalShort.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total}'**
  String ofTotalShort(int done, int total);

  /// No description provided for @adherenceSets.
  ///
  /// In es, this message translates to:
  /// **'Series de tus entrenos'**
  String get adherenceSets;

  /// No description provided for @adherencePrevious.
  ///
  /// In es, this message translates to:
  /// **'Bloque anterior'**
  String get adherencePrevious;

  /// No description provided for @adherenceNoPrevious.
  ///
  /// In es, this message translates to:
  /// **'Es tu primer bloque'**
  String get adherenceNoPrevious;

  /// No description provided for @adherenceByWeek.
  ///
  /// In es, this message translates to:
  /// **'Por semana'**
  String get adherenceByWeek;

  /// No description provided for @adherenceProgramWorkouts.
  ///
  /// In es, this message translates to:
  /// **'Entrenos del programa'**
  String get adherenceProgramWorkouts;

  /// No description provided for @adherenceMissed.
  ///
  /// In es, this message translates to:
  /// **'Sin completar'**
  String get adherenceMissed;

  /// No description provided for @adherenceNotLogged.
  ///
  /// In es, this message translates to:
  /// **'no registrado'**
  String get adherenceNotLogged;

  /// No description provided for @adherenceCurrentBlock.
  ///
  /// In es, this message translates to:
  /// **'BLOQUE ACTUAL'**
  String get adherenceCurrentBlock;

  /// No description provided for @adherenceDoneUntilToday.
  ///
  /// In es, this message translates to:
  /// **'{done} de {due} entrenos hasta hoy'**
  String adherenceDoneUntilToday(int done, int due);

  /// No description provided for @adherenceDoneOfTotal.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total} entrenos hechos'**
  String adherenceDoneOfTotal(int done, int total);

  /// No description provided for @adherenceLegendDone.
  ///
  /// In es, this message translates to:
  /// **'Hecho'**
  String get adherenceLegendDone;

  /// No description provided for @adherenceLegendMissed.
  ///
  /// In es, this message translates to:
  /// **'No se hizo'**
  String get adherenceLegendMissed;

  /// No description provided for @adherenceLegendPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get adherenceLegendPending;

  /// No description provided for @adherenceSetsFooter.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total} · {workouts, plural, =0{sin entrenos todavía} =1{en el que hiciste} other{en los {workouts} que hiciste}}'**
  String adherenceSetsFooter(int done, int total, int workouts);

  /// No description provided for @gateAccessEnded.
  ///
  /// In es, this message translates to:
  /// **'Tu coach terminó tu plan y tu acceso a Haki venció. Si creés que es un error, escribile.'**
  String get gateAccessEnded;

  /// No description provided for @homeAccessEnds.
  ///
  /// In es, this message translates to:
  /// **'Tu coach terminó tu plan. Podés seguir usando Haki hasta el {date}.'**
  String homeAccessEnds(String date);

  /// No description provided for @coachExperience.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Menos de 1 año de experiencia} =1{1 año de experiencia} other{{count} años de experiencia}}'**
  String coachExperience(int count);

  /// No description provided for @coachAbout.
  ///
  /// In es, this message translates to:
  /// **'Sobre mí'**
  String get coachAbout;

  /// No description provided for @coachCertifications.
  ///
  /// In es, this message translates to:
  /// **'Certificaciones'**
  String get coachCertifications;

  /// No description provided for @coachWrite.
  ///
  /// In es, this message translates to:
  /// **'Escribirle a {name}'**
  String coachWrite(String name);

  /// No description provided for @coachProfileEmpty.
  ///
  /// In es, this message translates to:
  /// **'{name} todavía no completó su perfil.'**
  String coachProfileEmpty(String name);

  /// No description provided for @authFirstTime.
  ///
  /// In es, this message translates to:
  /// **'¿Primera vez?'**
  String get authFirstTime;

  /// No description provided for @authCreateAccount.
  ///
  /// In es, this message translates to:
  /// **'Creá tu cuenta'**
  String get authCreateAccount;

  /// No description provided for @authEnterCode.
  ///
  /// In es, this message translates to:
  /// **'Ingresar el código del email'**
  String get authEnterCode;

  /// No description provided for @signupTitle.
  ///
  /// In es, this message translates to:
  /// **'Creá tu cuenta'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Usá el mismo correo al que te llegó la invitación de tu coach.'**
  String get signupSubtitle;

  /// No description provided for @signupRepeatPassword.
  ///
  /// In es, this message translates to:
  /// **'Repetí la contraseña'**
  String get signupRepeatPassword;

  /// No description provided for @signupPasswordsDontMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get signupPasswordsDontMatch;

  /// No description provided for @signupRuleLength.
  ///
  /// In es, this message translates to:
  /// **'Al menos 8 caracteres'**
  String get signupRuleLength;

  /// No description provided for @signupRuleLetter.
  ///
  /// In es, this message translates to:
  /// **'Una letra'**
  String get signupRuleLetter;

  /// No description provided for @signupRuleDigit.
  ///
  /// In es, this message translates to:
  /// **'Un número'**
  String get signupRuleDigit;

  /// No description provided for @signupRuleNotEmail.
  ///
  /// In es, this message translates to:
  /// **'Que no sea tu correo'**
  String get signupRuleNotEmail;

  /// No description provided for @signupSubmit.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get signupSubmit;

  /// No description provided for @signupHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tenés cuenta?'**
  String get signupHaveAccount;

  /// No description provided for @signupSignIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciá sesión'**
  String get signupSignIn;

  /// No description provided for @signupWeakPassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña no cumple los requisitos'**
  String get signupWeakPassword;

  /// No description provided for @signupError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear la cuenta. Revisá tu conexión e intentá de nuevo.'**
  String get signupError;

  /// No description provided for @codeTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisá tu correo'**
  String get codeTitle;

  /// No description provided for @codeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Te mandamos un código de 6 dígitos a {email}. Escribilo acá para confirmar que el correo es tuyo.'**
  String codeSubtitle(String email);

  /// No description provided for @codeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get codeLabel;

  /// No description provided for @codeExpires.
  ///
  /// In es, this message translates to:
  /// **'El código vence en 1 hora.'**
  String get codeExpires;

  /// No description provided for @codeConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get codeConfirm;

  /// No description provided for @codeResend.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get codeResend;

  /// No description provided for @codeResendIn.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código en {seconds} s'**
  String codeResendIn(int seconds);

  /// No description provided for @codeResent.
  ///
  /// In es, this message translates to:
  /// **'Te mandamos un código nuevo.'**
  String get codeResent;

  /// No description provided for @codeInvalid.
  ///
  /// In es, this message translates to:
  /// **'El código no es válido o ya venció.'**
  String get codeInvalid;

  /// No description provided for @codeHelp.
  ///
  /// In es, this message translates to:
  /// **'¿No llegó? Revisá la carpeta de spam. Si escribiste mal el correo, volvé atrás y corregilo.'**
  String get codeHelp;

  /// No description provided for @inviteTitle.
  ///
  /// In es, this message translates to:
  /// **'Tenés una invitación'**
  String get inviteTitle;

  /// No description provided for @inviteSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Al aceptarla, tu coach te arma el programa y te acompaña desde acá.'**
  String get inviteSubtitle;

  /// No description provided for @inviteCoach.
  ///
  /// In es, this message translates to:
  /// **'Coach'**
  String get inviteCoach;

  /// No description provided for @inviteFor.
  ///
  /// In es, this message translates to:
  /// **'Invitación para'**
  String get inviteFor;

  /// No description provided for @inviteAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar invitación'**
  String get inviteAccept;

  /// No description provided for @inviteNotMine.
  ///
  /// In es, this message translates to:
  /// **'No es mi coach · Cerrar sesión'**
  String get inviteNotMine;

  /// No description provided for @inviteNoneTitle.
  ///
  /// In es, this message translates to:
  /// **'No encontramos tu invitación'**
  String get inviteNoneTitle;

  /// No description provided for @inviteNoneBody.
  ///
  /// In es, this message translates to:
  /// **'Entraste como {email} y no hay ninguna invitación para ese correo.'**
  String inviteNoneBody(String email);

  /// No description provided for @inviteNoneHint.
  ///
  /// In es, this message translates to:
  /// **'Haki es por invitación: entrá con el correo al que te escribió tu coach, o pedile que te invite con este.'**
  String get inviteNoneHint;

  /// No description provided for @inviteOtherAccount.
  ///
  /// In es, this message translates to:
  /// **'Entrar con otra cuenta'**
  String get inviteOtherAccount;

  /// No description provided for @inviteSearchAgain.
  ///
  /// In es, this message translates to:
  /// **'Ya me invitó · Volver a buscar'**
  String get inviteSearchAgain;

  /// No description provided for @personalTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis datos'**
  String get personalTitle;

  /// No description provided for @personalIntro.
  ///
  /// In es, this message translates to:
  /// **'{coach} los ve para armar tu programa.'**
  String personalIntro(String coach);

  /// No description provided for @personalIntroNoCoach.
  ///
  /// In es, this message translates to:
  /// **'Tu coach los ve para armar tu programa.'**
  String get personalIntroNoCoach;

  /// No description provided for @personalSection.
  ///
  /// In es, this message translates to:
  /// **'DATOS PERSONALES'**
  String get personalSection;

  /// No description provided for @personalName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get personalName;

  /// No description provided for @personalNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribí tu nombre'**
  String get personalNameRequired;

  /// No description provided for @personalEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get personalEmail;

  /// No description provided for @personalEmailHint.
  ///
  /// In es, this message translates to:
  /// **'Es tu usuario para entrar. No se cambia desde acá.'**
  String get personalEmailHint;

  /// No description provided for @personalGender.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get personalGender;

  /// No description provided for @genderMale.
  ///
  /// In es, this message translates to:
  /// **'Hombre'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In es, this message translates to:
  /// **'Mujer'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get genderOther;

  /// No description provided for @personalHeight.
  ///
  /// In es, this message translates to:
  /// **'Estatura'**
  String get personalHeight;

  /// No description provided for @personalHeightInvalid.
  ///
  /// In es, this message translates to:
  /// **'Revisá la estatura (50–260 cm)'**
  String get personalHeightInvalid;

  /// No description provided for @personalInjuriesSection.
  ///
  /// In es, this message translates to:
  /// **'LESIONES Y MOLESTIAS'**
  String get personalInjuriesSection;

  /// No description provided for @personalInjuries.
  ///
  /// In es, this message translates to:
  /// **'¿Algo que tu coach tenga que saber?'**
  String get personalInjuries;

  /// No description provided for @personalInjuriesHint.
  ///
  /// In es, this message translates to:
  /// **'Una lesión, una molestia o algo que no podés hacer. Lo ve en tu perfil.'**
  String get personalInjuriesHint;

  /// No description provided for @personalGoalSection.
  ///
  /// In es, this message translates to:
  /// **'OBJETIVO'**
  String get personalGoalSection;

  /// No description provided for @personalGoalNone.
  ///
  /// In es, this message translates to:
  /// **'Tu coach todavía no cargó tu objetivo.'**
  String get personalGoalNone;

  /// No description provided for @personalGoalHint.
  ///
  /// In es, this message translates to:
  /// **'Lo define tu coach. ¿Querés cambiarlo?'**
  String get personalGoalHint;

  /// No description provided for @personalGoalWrite.
  ///
  /// In es, this message translates to:
  /// **'Escribile'**
  String get personalGoalWrite;

  /// No description provided for @personalWeightSection.
  ///
  /// In es, this message translates to:
  /// **'PESO'**
  String get personalWeightSection;

  /// No description provided for @personalWeightHint.
  ///
  /// In es, this message translates to:
  /// **'Se registra en Peso corporal'**
  String get personalWeightHint;

  /// No description provided for @personalSaved.
  ///
  /// In es, this message translates to:
  /// **'Datos guardados'**
  String get personalSaved;

  /// No description provided for @goalFatLoss.
  ///
  /// In es, this message translates to:
  /// **'Pérdida de grasa'**
  String get goalFatLoss;

  /// No description provided for @goalMuscleGain.
  ///
  /// In es, this message translates to:
  /// **'Ganancia muscular'**
  String get goalMuscleGain;

  /// No description provided for @goalStrength.
  ///
  /// In es, this message translates to:
  /// **'Fuerza'**
  String get goalStrength;

  /// No description provided for @goalEndurance.
  ///
  /// In es, this message translates to:
  /// **'Resistencia'**
  String get goalEndurance;

  /// No description provided for @goalRecomposition.
  ///
  /// In es, this message translates to:
  /// **'Recomposición corporal'**
  String get goalRecomposition;

  /// No description provided for @goalGeneralHealth.
  ///
  /// In es, this message translates to:
  /// **'Salud general'**
  String get goalGeneralHealth;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
