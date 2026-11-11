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

  /// No description provided for @homeRestLabelOn.
  ///
  /// In es, this message translates to:
  /// **'{date} · Descanso'**
  String homeRestLabelOn(String date);

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

  /// No description provided for @stripSkipped.
  ///
  /// In es, this message translates to:
  /// **'día marcado como no hecho'**
  String get stripSkipped;

  /// No description provided for @stripPartial.
  ///
  /// In es, this message translates to:
  /// **'entreno hecho en parte'**
  String get stripPartial;

  /// No description provided for @daySetsOf.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total} series'**
  String daySetsOf(int done, int total);

  /// No description provided for @pastSessionUnlogged.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 ejercicio sin registrar} other{{count} ejercicios sin registrar}}'**
  String pastSessionUnlogged(int count);

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

  /// No description provided for @datesApplyFrom.
  ///
  /// In es, this message translates to:
  /// **'Aplicar desde'**
  String get datesApplyFrom;

  /// No description provided for @datesApplyFromAll.
  ///
  /// In es, this message translates to:
  /// **'S1 cambia todo el programa, también el día de inicio.'**
  String get datesApplyFromAll;

  /// No description provided for @datesApplyFromWeek.
  ///
  /// In es, this message translates to:
  /// **'Las semanas antes de la {week} quedan como estaban.'**
  String datesApplyFromWeek(int week);

  /// No description provided for @datesStartOnlyFromS1.
  ///
  /// In es, this message translates to:
  /// **'El inicio solo se cambia aplicando desde S1.'**
  String get datesStartOnlyFromS1;

  /// No description provided for @datesRepeatFromWeek.
  ///
  /// In es, this message translates to:
  /// **'Se repite igual desde la semana {week} hasta el final del bloque.'**
  String datesRepeatFromWeek(int week);

  /// No description provided for @datesResetsLater.
  ///
  /// In es, this message translates to:
  /// **'Reemplaza también los cambios que hiciste desde otras semanas.'**
  String get datesResetsLater;

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

  /// No description provided for @weekPrev.
  ///
  /// In es, this message translates to:
  /// **'Semana anterior'**
  String get weekPrev;

  /// No description provided for @weekNext.
  ///
  /// In es, this message translates to:
  /// **'Semana siguiente'**
  String get weekNext;

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

  /// No description provided for @datesDoneThisWeek.
  ///
  /// In es, this message translates to:
  /// **'Ya lo hiciste esta semana'**
  String get datesDoneThisWeek;

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

  /// No description provided for @noteAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar nota para tu coach'**
  String get noteAdd;

  /// No description provided for @noteLabel.
  ///
  /// In es, this message translates to:
  /// **'Nota para tu coach'**
  String get noteLabel;

  /// No description provided for @noteHint.
  ///
  /// In es, this message translates to:
  /// **'¿Algo que tu coach deba saber? Molestias, técnica, la carga…'**
  String get noteHint;

  /// No description provided for @noteSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar nota'**
  String get noteSave;

  /// No description provided for @noteEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get noteEdit;

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

  /// No description provided for @collapse.
  ///
  /// In es, this message translates to:
  /// **'Colapsar'**
  String get collapse;

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

  /// No description provided for @exerciseUnitToggle.
  ///
  /// In es, this message translates to:
  /// **'Unidad de este ejercicio: {unit}. Cambiar a {other}'**
  String exerciseUnitToggle(String unit, String other);

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

  /// No description provided for @exerciseOpenYoutube.
  ///
  /// In es, this message translates to:
  /// **'Abrir en YouTube'**
  String get exerciseOpenYoutube;

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

  /// No description provided for @measureGroupSkinfolds.
  ///
  /// In es, this message translates to:
  /// **'Pliegues'**
  String get measureGroupSkinfolds;

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

  /// No description provided for @measureLeftBicep.
  ///
  /// In es, this message translates to:
  /// **'Bíceps izquierdo'**
  String get measureLeftBicep;

  /// No description provided for @measureRightBicep.
  ///
  /// In es, this message translates to:
  /// **'Bíceps derecho'**
  String get measureRightBicep;

  /// No description provided for @measureShoulders.
  ///
  /// In es, this message translates to:
  /// **'Hombros'**
  String get measureShoulders;

  /// No description provided for @measureFatMass.
  ///
  /// In es, this message translates to:
  /// **'Masa grasa'**
  String get measureFatMass;

  /// No description provided for @measureBodyWater.
  ///
  /// In es, this message translates to:
  /// **'Agua corporal'**
  String get measureBodyWater;

  /// No description provided for @measureTricepsSkinfold.
  ///
  /// In es, this message translates to:
  /// **'Pliegue tricipital'**
  String get measureTricepsSkinfold;

  /// No description provided for @measureBicepsSkinfold.
  ///
  /// In es, this message translates to:
  /// **'Pliegue bicipital'**
  String get measureBicepsSkinfold;

  /// No description provided for @measureSubscapularSkinfold.
  ///
  /// In es, this message translates to:
  /// **'Pliegue subescapular'**
  String get measureSubscapularSkinfold;

  /// No description provided for @measureIliacCrestSkinfold.
  ///
  /// In es, this message translates to:
  /// **'Pliegue cresta ilíaca'**
  String get measureIliacCrestSkinfold;

  /// No description provided for @measureSupraspinaleSkinfold.
  ///
  /// In es, this message translates to:
  /// **'Pliegue supraespinal'**
  String get measureSupraspinaleSkinfold;

  /// No description provided for @measureAbdominalSkinfold.
  ///
  /// In es, this message translates to:
  /// **'Pliegue abdominal'**
  String get measureAbdominalSkinfold;

  /// No description provided for @measureThighSkinfold.
  ///
  /// In es, this message translates to:
  /// **'Pliegue del muslo'**
  String get measureThighSkinfold;

  /// No description provided for @measureCalfSkinfold.
  ///
  /// In es, this message translates to:
  /// **'Pliegue de la pantorrilla'**
  String get measureCalfSkinfold;

  /// No description provided for @measureChestSkinfold.
  ///
  /// In es, this message translates to:
  /// **'Pliegue pectoral'**
  String get measureChestSkinfold;

  /// No description provided for @measureMidaxillarySkinfold.
  ///
  /// In es, this message translates to:
  /// **'Pliegue axilar medio'**
  String get measureMidaxillarySkinfold;

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

  /// No description provided for @inviteExpiredTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu invitación venció'**
  String get inviteExpiredTitle;

  /// No description provided for @inviteExpiredBody.
  ///
  /// In es, this message translates to:
  /// **'La invitación de {coach} venció (dura 7 días). Pedile que te la reenvíe desde Haki.'**
  String inviteExpiredBody(String coach);

  /// No description provided for @inviteExpiredSearchAgain.
  ///
  /// In es, this message translates to:
  /// **'Ya me la reenvió · Volver a buscar'**
  String get inviteExpiredSearchAgain;

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

  /// No description provided for @chatGroupsSection.
  ///
  /// In es, this message translates to:
  /// **'Grupos'**
  String get chatGroupsSection;

  /// No description provided for @chatGroupMembers.
  ///
  /// In es, this message translates to:
  /// **'{count} integrantes'**
  String chatGroupMembers(int count);

  /// No description provided for @chatGroupOnlyCoachWrites.
  ///
  /// In es, this message translates to:
  /// **'Solo {coach} escribe'**
  String chatGroupOnlyCoachWrites(String coach);

  /// No description provided for @chatGroupEveryoneWrites.
  ///
  /// In es, this message translates to:
  /// **'Todos pueden escribir'**
  String get chatGroupEveryoneWrites;

  /// No description provided for @chatGroupLocked.
  ///
  /// In es, this message translates to:
  /// **'Solo {coach} escribe en este grupo. Mantené presionado un mensaje para reaccionar.'**
  String chatGroupLocked(String coach);

  /// No description provided for @chatGroupHint.
  ///
  /// In es, this message translates to:
  /// **'Escribí al grupo…'**
  String get chatGroupHint;

  /// No description provided for @chatGroupEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay mensajes en el grupo.'**
  String get chatGroupEmpty;

  /// No description provided for @chatGroupInfo.
  ///
  /// In es, this message translates to:
  /// **'Info del grupo'**
  String get chatGroupInfo;

  /// No description provided for @chatGroupOf.
  ///
  /// In es, this message translates to:
  /// **'Grupo de {coach} · {count} integrantes'**
  String chatGroupOf(String coach, int count);

  /// No description provided for @chatGroupMembersTitle.
  ///
  /// In es, this message translates to:
  /// **'Integrantes · {count}'**
  String chatGroupMembersTitle(int count);

  /// No description provided for @chatGroupCoachTag.
  ///
  /// In es, this message translates to:
  /// **'Coach'**
  String get chatGroupCoachTag;

  /// No description provided for @chatGroupYou.
  ///
  /// In es, this message translates to:
  /// **'Vos'**
  String get chatGroupYou;

  /// No description provided for @chatGroupLeave.
  ///
  /// In es, this message translates to:
  /// **'Salir del grupo'**
  String get chatGroupLeave;

  /// No description provided for @chatGroupLeaveTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Salir de \"{name}\"?'**
  String chatGroupLeaveTitle(String name);

  /// No description provided for @chatGroupLeaveBody.
  ///
  /// In es, this message translates to:
  /// **'Dejás de ver los mensajes del grupo. El grupo ve que saliste y para volver te tiene que agregar {coach}.'**
  String chatGroupLeaveBody(String coach);

  /// No description provided for @chatGroupLeaveKeep.
  ///
  /// In es, this message translates to:
  /// **'Tu chat con {coach} sigue igual.'**
  String chatGroupLeaveKeep(String coach);

  /// No description provided for @chatGroupLeaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo salir del grupo. Revisá tu conexión.'**
  String get chatGroupLeaveError;

  /// No description provided for @chatGroupGone.
  ///
  /// In es, this message translates to:
  /// **'Ya no estás en este grupo.'**
  String get chatGroupGone;

  /// No description provided for @chatReact.
  ///
  /// In es, this message translates to:
  /// **'Reaccionar'**
  String get chatReact;

  /// No description provided for @chatNoMessagesYet.
  ///
  /// In es, this message translates to:
  /// **'Sin mensajes'**
  String get chatNoMessagesYet;

  /// No description provided for @notifGroupBody.
  ///
  /// In es, this message translates to:
  /// **'{name}: {text}'**
  String notifGroupBody(String name, String text);

  /// No description provided for @chatReactError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reaccionar. Revisá tu conexión.'**
  String get chatReactError;

  /// No description provided for @rxMin.
  ///
  /// In es, this message translates to:
  /// **'min'**
  String get rxMin;

  /// No description provided for @rxSec.
  ///
  /// In es, this message translates to:
  /// **'s'**
  String get rxSec;

  /// No description provided for @rxPerSide.
  ///
  /// In es, this message translates to:
  /// **'por lado'**
  String get rxPerSide;

  /// No description provided for @kindCardio.
  ///
  /// In es, this message translates to:
  /// **'Cardio'**
  String get kindCardio;

  /// No description provided for @kindMobility.
  ///
  /// In es, this message translates to:
  /// **'Movilidad'**
  String get kindMobility;

  /// No description provided for @rxMarkDone.
  ///
  /// In es, this message translates to:
  /// **'Marcar hecho'**
  String get rxMarkDone;

  /// No description provided for @rxMarkUndone.
  ///
  /// In es, this message translates to:
  /// **'Desmarcar'**
  String get rxMarkUndone;

  /// No description provided for @rxDoneCount.
  ///
  /// In es, this message translates to:
  /// **'{done}/{total}'**
  String rxDoneCount(int done, int total);

  /// No description provided for @todayChipMobility.
  ///
  /// In es, this message translates to:
  /// **'{count} movilidad'**
  String todayChipMobility(int count);

  /// No description provided for @todayChipCardios.
  ///
  /// In es, this message translates to:
  /// **'{count} cardio · {minutes} min'**
  String todayChipCardios(int count, int minutes);

  /// No description provided for @progressTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu progreso'**
  String get progressTitle;

  /// No description provided for @progressCardFooter.
  ///
  /// In es, this message translates to:
  /// **'Ejercicios, constancia, récords y peso'**
  String get progressCardFooter;

  /// No description provided for @progressPeriodBlock.
  ///
  /// In es, this message translates to:
  /// **'Este bloque'**
  String get progressPeriodBlock;

  /// No description provided for @progressPeriodPrevious.
  ///
  /// In es, this message translates to:
  /// **'Bloque anterior'**
  String get progressPeriodPrevious;

  /// No description provided for @progressPeriodWeeks.
  ///
  /// In es, this message translates to:
  /// **'Últimas {n} semanas'**
  String progressPeriodWeeks(int n);

  /// No description provided for @progressKickerWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana {week} de {total}'**
  String progressKickerWeek(int week, int total);

  /// No description provided for @progressKickerEnded.
  ///
  /// In es, this message translates to:
  /// **'Terminó el {date}'**
  String progressKickerEnded(String date);

  /// No description provided for @progressKickerRange.
  ///
  /// In es, this message translates to:
  /// **'Últimas {n} semanas'**
  String progressKickerRange(int n);

  /// No description provided for @progressNoteBlock.
  ///
  /// In es, this message translates to:
  /// **'Cuenta las semanas terminadas y lo que llevás de esta'**
  String get progressNoteBlock;

  /// No description provided for @progressNoteEnded.
  ///
  /// In es, this message translates to:
  /// **'Las {n} semanas del bloque'**
  String progressNoteEnded(int n);

  /// No description provided for @progressConstancy.
  ///
  /// In es, this message translates to:
  /// **'TU CONSTANCIA'**
  String get progressConstancy;

  /// No description provided for @progressWorkoutsOf.
  ///
  /// In es, this message translates to:
  /// **'entrenos de {due} que tocaban'**
  String progressWorkoutsOf(int due);

  /// No description provided for @progressStreak.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{semana seguida} other{semanas seguidas}}'**
  String progressStreak(int count);

  /// No description provided for @progressWeekShort.
  ///
  /// In es, this message translates to:
  /// **'S{n}'**
  String progressWeekShort(int n);

  /// No description provided for @progressExercises.
  ///
  /// In es, this message translates to:
  /// **'TUS EJERCICIOS'**
  String get progressExercises;

  /// No description provided for @progressE1rmRange.
  ///
  /// In es, this message translates to:
  /// **'e1RM {from} → {to} {unit}'**
  String progressE1rmRange(String from, String to, String unit);

  /// No description provided for @progressRepsRange.
  ///
  /// In es, this message translates to:
  /// **'{from} → {to} reps'**
  String progressRepsRange(String from, String to);

  /// No description provided for @progressOneWeek.
  ///
  /// In es, this message translates to:
  /// **'Una semana con datos'**
  String get progressOneWeek;

  /// No description provided for @progressOpenChart.
  ///
  /// In es, this message translates to:
  /// **'Ver gráfico de {name}'**
  String progressOpenChart(String name);

  /// No description provided for @progressHide.
  ///
  /// In es, this message translates to:
  /// **'Ocultar {name}'**
  String progressHide(String name);

  /// No description provided for @progressShow.
  ///
  /// In es, this message translates to:
  /// **'Mostrar {name}'**
  String progressShow(String name);

  /// No description provided for @progressHidden.
  ///
  /// In es, this message translates to:
  /// **'Ocultos ({count})'**
  String progressHidden(int count);

  /// No description provided for @progressRecords.
  ///
  /// In es, this message translates to:
  /// **'RÉCORDS DEL PERÍODO'**
  String get progressRecords;

  /// No description provided for @progressNoRecords.
  ///
  /// In es, this message translates to:
  /// **'Sin récords nuevos en este período'**
  String get progressNoRecords;

  /// No description provided for @progressWeight.
  ///
  /// In es, this message translates to:
  /// **'PESO CORPORAL'**
  String get progressWeight;

  /// No description provided for @progressWeightDelta.
  ///
  /// In es, this message translates to:
  /// **'{delta} en el período'**
  String progressWeightDelta(String delta);

  /// No description provided for @progressEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay entrenos registrados en este período.'**
  String get progressEmpty;

  /// No description provided for @progressError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar. Revisá tu conexión.'**
  String get progressError;

  /// No description provided for @progressNoDataExercise.
  ///
  /// In es, this message translates to:
  /// **'Este ejercicio no tiene datos en el período.'**
  String get progressNoDataExercise;

  /// No description provided for @progressDetailKicker.
  ///
  /// In es, this message translates to:
  /// **'e1RM · {period}'**
  String progressDetailKicker(String period);

  /// No description provided for @progressDetailRepsKicker.
  ///
  /// In es, this message translates to:
  /// **'Reps · {period}'**
  String progressDetailRepsKicker(String period);

  /// No description provided for @progressDetailSub.
  ///
  /// In es, this message translates to:
  /// **'Mejor serie de cada semana, en la unidad en que la cargaste'**
  String get progressDetailSub;

  /// No description provided for @progressRepsValue.
  ///
  /// In es, this message translates to:
  /// **'{n} reps'**
  String progressRepsValue(String n);

  /// No description provided for @progressWeekByWeek.
  ///
  /// In es, this message translates to:
  /// **'SEMANA A SEMANA'**
  String get progressWeekByWeek;

  /// No description provided for @progressBestSet.
  ///
  /// In es, this message translates to:
  /// **'{weight} × {reps} · e1RM {e1rm}'**
  String progressBestSet(String weight, int reps, String e1rm);

  /// No description provided for @progressBestBw.
  ///
  /// In es, this message translates to:
  /// **'{reps} reps'**
  String progressBestBw(int reps);

  /// No description provided for @progressPrLegend.
  ///
  /// In es, this message translates to:
  /// **'Récord (nuevo PR)'**
  String get progressPrLegend;

  /// No description provided for @streakComplete.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Racha: 1 semana completa} other{Racha: {count} semanas completas}}'**
  String streakComplete(int count);

  /// No description provided for @streakNext.
  ///
  /// In es, this message translates to:
  /// **'Completá esta y van {n}'**
  String streakNext(int n);

  /// No description provided for @streakThisWeekDone.
  ///
  /// In es, this message translates to:
  /// **'Semana completa ✓'**
  String get streakThisWeekDone;

  /// No description provided for @streakCompleteThisWeek.
  ///
  /// In es, this message translates to:
  /// **'Completá esta semana'**
  String get streakCompleteThisWeek;

  /// No description provided for @streakRemaining.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Te falta 1 entreno para sumar la semana {week}} other{Te faltan {count} entrenos para sumar la semana {week}}}'**
  String streakRemaining(int count, int week);

  /// No description provided for @streakRemainingStart.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Te falta 1 entreno para arrancar tu racha} other{Te faltan {count} entrenos para arrancar tu racha}}'**
  String streakRemainingStart(int count);

  /// No description provided for @streakStartWeek.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Hacé 1 entreno esta semana para arrancar tu racha} other{Hacé {count} entrenos esta semana para arrancar tu racha}}'**
  String streakStartWeek(int count);

  /// No description provided for @streakSecured.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Semana asegurada · te queda 1 entreno} other{Semana asegurada · te quedan {count} entrenos}}'**
  String streakSecured(int count);

  /// No description provided for @progressLastPr.
  ///
  /// In es, this message translates to:
  /// **'Último PR: {name}'**
  String progressLastPr(String name);

  /// No description provided for @progressAdherencePct.
  ///
  /// In es, this message translates to:
  /// **'{pct} %'**
  String progressAdherencePct(int pct);

  /// No description provided for @progressWorkoutsUntilToday.
  ///
  /// In es, this message translates to:
  /// **'de adherencia · {done} de {due} entrenos hasta hoy'**
  String progressWorkoutsUntilToday(int done, int due);

  /// No description provided for @workoutNewPr.
  ///
  /// In es, this message translates to:
  /// **'NUEVO PR'**
  String get workoutNewPr;

  /// No description provided for @workoutPrDiff.
  ///
  /// In es, this message translates to:
  /// **'e1RM · +{diff}'**
  String workoutPrDiff(String diff);

  /// No description provided for @workoutPrSemantics.
  ///
  /// In es, this message translates to:
  /// **'Nuevo PR en {exercise}: e1RM {value}. Abrir el ejercicio'**
  String workoutPrSemantics(String exercise, String value);

  /// No description provided for @workoutVideosUploading.
  ///
  /// In es, this message translates to:
  /// **'Subiendo videos'**
  String get workoutVideosUploading;

  /// No description provided for @workoutVideosUploadingFor.
  ///
  /// In es, this message translates to:
  /// **'Subiendo videos para {coach}'**
  String workoutVideosUploadingFor(String coach);

  /// No description provided for @workoutVideosSent.
  ///
  /// In es, this message translates to:
  /// **'Videos enviados'**
  String get workoutVideosSent;

  /// No description provided for @workoutVideosSentTo.
  ///
  /// In es, this message translates to:
  /// **'Videos enviados a {coach}'**
  String workoutVideosSentTo(String coach);

  /// No description provided for @workoutVideosCount.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total}'**
  String workoutVideosCount(int done, int total);

  /// No description provided for @workoutVideosHint.
  ///
  /// In es, this message translates to:
  /// **'Podés cerrar la app: se terminan de subir cuando vuelvas a tener señal.'**
  String get workoutVideosHint;

  /// No description provided for @placeSlot.
  ///
  /// In es, this message translates to:
  /// **'{n}.ª'**
  String placeSlot(int n);

  /// No description provided for @progressPlaceWhy.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué {name} va en dos filas?'**
  String progressPlaceWhy(String name);

  /// No description provided for @progressPlaceTip.
  ///
  /// In es, this message translates to:
  /// **'Tu coach lo puso en más de un lugar de tu semana. Cada uno se compara con el mismo día de la semana anterior, así un día más liviano no queda tapado por el otro.'**
  String get progressPlaceTip;

  /// No description provided for @progressPlaceOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo tus series de {place}. Los otros días tienen su propia fila en Tu progreso.'**
  String progressPlaceOnly(String place);

  /// No description provided for @lastFromDay.
  ///
  /// In es, this message translates to:
  /// **'{day}, sem. {week}'**
  String lastFromDay(String day, int week);

  /// No description provided for @exerciseE1rmOf.
  ///
  /// In es, this message translates to:
  /// **'e1RM · {place}'**
  String exerciseE1rmOf(String place);

  /// No description provided for @exerciseHistoryOf.
  ///
  /// In es, this message translates to:
  /// **'Historial · {place}'**
  String exerciseHistoryOf(String place);

  /// No description provided for @exerciseSeeAllDays.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los días'**
  String get exerciseSeeAllDays;

  /// No description provided for @exerciseSeeProgress.
  ///
  /// In es, this message translates to:
  /// **'Ver tu progreso'**
  String get exerciseSeeProgress;

  /// No description provided for @exerciseVolumeThatDay.
  ///
  /// In es, this message translates to:
  /// **'Volumen ese día {volume}'**
  String exerciseVolumeThatDay(String volume);

  /// No description provided for @skipMarkedToday.
  ///
  /// In es, this message translates to:
  /// **'Marcaste que no lo hacés'**
  String get skipMarkedToday;

  /// No description provided for @skipUndoTrain.
  ///
  /// In es, this message translates to:
  /// **'Deshacer · lo voy a entrenar'**
  String get skipUndoTrain;

  /// No description provided for @skipSwipeAction.
  ///
  /// In es, this message translates to:
  /// **'No lo haré'**
  String get skipSwipeAction;

  /// No description provided for @skipUndo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get skipUndo;

  /// No description provided for @skipSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'¿No vas a hacer el {day}?'**
  String skipSheetTitle(String day);

  /// No description provided for @skipSheetCounts.
  ///
  /// In es, this message translates to:
  /// **'Cuenta como no hecho en tu constancia.'**
  String get skipSheetCounts;

  /// No description provided for @skipSheetNext.
  ///
  /// In es, this message translates to:
  /// **'Pasás al siguiente día del programa.'**
  String get skipSheetNext;

  /// No description provided for @skipSheetUndo.
  ///
  /// In es, this message translates to:
  /// **'Podés deshacerlo deslizando el día otra vez, o entrenarlo igual: al registrar una serie vuelve a ser un entreno normal.'**
  String get skipSheetUndo;

  /// No description provided for @skipNoteLabel.
  ///
  /// In es, this message translates to:
  /// **'Contale a {coach} por qué (opcional)'**
  String skipNoteLabel(String coach);

  /// No description provided for @skipNoteLabelNoCoach.
  ///
  /// In es, this message translates to:
  /// **'Contale a tu coach por qué (opcional)'**
  String get skipNoteLabelNoCoach;

  /// No description provided for @skipConfirm.
  ///
  /// In es, this message translates to:
  /// **'Marcar como no hecho'**
  String get skipConfirm;

  /// No description provided for @skipSessionButton.
  ///
  /// In es, this message translates to:
  /// **'No voy a hacer este día'**
  String get skipSessionButton;

  /// No description provided for @skipSessionHint.
  ///
  /// In es, this message translates to:
  /// **'Cuando registres una serie, acá aparece Finalizar entreno'**
  String get skipSessionHint;

  /// No description provided for @skipDayRowSub.
  ///
  /// In es, this message translates to:
  /// **'No lo hiciste'**
  String get skipDayRowSub;

  /// No description provided for @progressSame.
  ///
  /// In es, this message translates to:
  /// **'igual'**
  String get progressSame;

  /// No description provided for @voicePlay.
  ///
  /// In es, this message translates to:
  /// **'Reproducir audio'**
  String get voicePlay;

  /// No description provided for @voicePause.
  ///
  /// In es, this message translates to:
  /// **'Pausar audio'**
  String get voicePause;

  /// No description provided for @voiceUnheard.
  ///
  /// In es, this message translates to:
  /// **'Sin escuchar'**
  String get voiceUnheard;

  /// No description provided for @voiceRecord.
  ///
  /// In es, this message translates to:
  /// **'Grabar audio'**
  String get voiceRecord;

  /// No description provided for @voiceDiscard.
  ///
  /// In es, this message translates to:
  /// **'Descartar audio'**
  String get voiceDiscard;

  /// No description provided for @voiceStopToListen.
  ///
  /// In es, this message translates to:
  /// **'Terminar y escucharlo'**
  String get voiceStopToListen;

  /// No description provided for @voiceSend.
  ///
  /// In es, this message translates to:
  /// **'Mandar audio'**
  String get voiceSend;

  /// No description provided for @voiceHint.
  ///
  /// In es, this message translates to:
  /// **'Máximo 2:00 · tocá ⏸ para escucharlo antes de mandar'**
  String get voiceHint;

  /// No description provided for @voiceMicDenied.
  ///
  /// In es, this message translates to:
  /// **'Para mandar audios, dale permiso al micrófono en los ajustes del teléfono.'**
  String get voiceMicDenied;

  /// No description provided for @voicePreview.
  ///
  /// In es, this message translates to:
  /// **'Audio · {duration}'**
  String voicePreview(String duration);

  /// No description provided for @settingsAutoRest.
  ///
  /// In es, this message translates to:
  /// **'Descanso automático'**
  String get settingsAutoRest;

  /// No description provided for @settingsAutoRestHint.
  ///
  /// In es, this message translates to:
  /// **'El timer arranca solo entre series del mismo ejercicio'**
  String get settingsAutoRestHint;

  /// No description provided for @notifRemindersChannel.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios'**
  String get notifRemindersChannel;

  /// No description provided for @notifRemindersChannelDesc.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de pagos y avisos de tu coach'**
  String get notifRemindersChannelDesc;

  /// No description provided for @notifPaymentDueTodayTitle.
  ///
  /// In es, this message translates to:
  /// **'Hoy vence tu pago'**
  String get notifPaymentDueTodayTitle;

  /// No description provided for @notifPaymentDueInTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu pago vence {days, plural, =1{mañana} other{en {days} días}}'**
  String notifPaymentDueInTitle(int days);

  /// No description provided for @notifPaymentDueTodayBody.
  ///
  /// In es, this message translates to:
  /// **'Pago a {coach} de {amount}.'**
  String notifPaymentDueTodayBody(String coach, String amount);

  /// No description provided for @notifPaymentDueInBody.
  ///
  /// In es, this message translates to:
  /// **'Pago a {coach} de {amount} el {date}.'**
  String notifPaymentDueInBody(String coach, String amount, String date);

  /// No description provided for @notifTestTitle.
  ///
  /// In es, this message translates to:
  /// **'Haki'**
  String get notifTestTitle;

  /// No description provided for @notifTestBody.
  ///
  /// In es, this message translates to:
  /// **'Las notificaciones funcionan ✓'**
  String get notifTestBody;

  /// No description provided for @agendaInPerson.
  ///
  /// In es, this message translates to:
  /// **'Sesión presencial'**
  String get agendaInPerson;

  /// No description provided for @agendaVirtual.
  ///
  /// In es, this message translates to:
  /// **'Sesión virtual'**
  String get agendaVirtual;

  /// No description provided for @agendaToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get agendaToday;

  /// No description provided for @agendaCancelledLabel.
  ///
  /// In es, this message translates to:
  /// **'Cancelada · {when}'**
  String agendaCancelledLabel(String when);

  /// No description provided for @agendaCancelledBody.
  ///
  /// In es, this message translates to:
  /// **'{coach} canceló esta sesión.'**
  String agendaCancelledBody(String coach);

  /// No description provided for @agendaDirections.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get agendaDirections;

  /// No description provided for @agendaJoin.
  ///
  /// In es, this message translates to:
  /// **'Unirme'**
  String get agendaJoin;

  /// No description provided for @agendaMessage.
  ///
  /// In es, this message translates to:
  /// **'Escribirle'**
  String get agendaMessage;

  /// No description provided for @agendaCantGo.
  ///
  /// In es, this message translates to:
  /// **'No puedo ir'**
  String get agendaCantGo;

  /// No description provided for @agendaDeclined.
  ///
  /// In es, this message translates to:
  /// **'Le avisaste a {coach} que no podés ir.'**
  String agendaDeclined(String coach);

  /// No description provided for @agendaUndoDecline.
  ///
  /// In es, this message translates to:
  /// **'Deshacer · sí voy'**
  String get agendaUndoDecline;

  /// No description provided for @agendaDeclineTitle.
  ///
  /// In es, this message translates to:
  /// **'¿No podés ir?'**
  String get agendaDeclineTitle;

  /// No description provided for @agendaDeclineInfo.
  ///
  /// In es, this message translates to:
  /// **'{coach} va a ver el aviso en su agenda. La sesión no se cancela: si quieren otro horario, escribile.'**
  String agendaDeclineInfo(String coach);

  /// No description provided for @agendaDeclineReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo (opcional)'**
  String get agendaDeclineReason;

  /// No description provided for @agendaDeclineConfirm.
  ///
  /// In es, this message translates to:
  /// **'Avisar a {coach}'**
  String agendaDeclineConfirm(String coach);

  /// No description provided for @agendaOpenError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el link'**
  String get agendaOpenError;

  /// No description provided for @notifEventInvitedTitle.
  ///
  /// In es, this message translates to:
  /// **'{coach} te invitó a una sesión'**
  String notifEventInvitedTitle(String coach);

  /// No description provided for @notifEventInvitedSeriesTitle.
  ///
  /// In es, this message translates to:
  /// **'{coach} te invitó a sesiones semanales'**
  String notifEventInvitedSeriesTitle(String coach);

  /// No description provided for @notifEventChangedTitle.
  ///
  /// In es, this message translates to:
  /// **'{coach} cambió tu sesión'**
  String notifEventChangedTitle(String coach);

  /// No description provided for @notifEventTimeChangedTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambió la hora de tu sesión'**
  String get notifEventTimeChangedTitle;

  /// No description provided for @notifEventPlaceChangedTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambió el lugar de tu sesión'**
  String get notifEventPlaceChangedTitle;

  /// No description provided for @notifEventLinkChangedTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambió el link de tu sesión'**
  String get notifEventLinkChangedTitle;

  /// No description provided for @notifEventCancelledTitle.
  ///
  /// In es, this message translates to:
  /// **'Se canceló tu sesión'**
  String get notifEventCancelledTitle;

  /// No description provided for @notifEventCancelledSeriesTitle.
  ///
  /// In es, this message translates to:
  /// **'Se cancelaron tus sesiones semanales'**
  String get notifEventCancelledSeriesTitle;

  /// No description provided for @notifEventEvery.
  ///
  /// In es, this message translates to:
  /// **'Los {days}'**
  String notifEventEvery(String days);

  /// No description provided for @notifEventUntil.
  ///
  /// In es, this message translates to:
  /// **'hasta el {date}'**
  String notifEventUntil(String date);

  /// No description provided for @notifEventFrom.
  ///
  /// In es, this message translates to:
  /// **'desde el {date}'**
  String notifEventFrom(String date);

  /// No description provided for @agendaKindInPerson.
  ///
  /// In es, this message translates to:
  /// **'Presencial'**
  String get agendaKindInPerson;

  /// No description provided for @agendaKindVirtual.
  ///
  /// In es, this message translates to:
  /// **'Virtual'**
  String get agendaKindVirtual;

  /// No description provided for @inboxTitle.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get inboxTitle;

  /// No description provided for @inboxMarkRead.
  ///
  /// In es, this message translates to:
  /// **'Marcar leídos'**
  String get inboxMarkRead;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No tenés avisos'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Acá te avisamos cuando tu coach te invite a una sesión, la cambie o la cancele, y de tus pagos.'**
  String get inboxEmptyBody;

  /// No description provided for @inboxButton.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Avisos} =1{Avisos, 1 sin leer} other{Avisos, {count} sin leer}}'**
  String inboxButton(int count);

  /// No description provided for @agoNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get agoNow;

  /// No description provided for @agoMinutes.
  ///
  /// In es, this message translates to:
  /// **'Hace {n} min'**
  String agoMinutes(int n);

  /// No description provided for @agoHours.
  ///
  /// In es, this message translates to:
  /// **'Hace {n} h'**
  String agoHours(int n);

  /// No description provided for @notifEventReminderTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión con {coach} es a las {time}'**
  String notifEventReminderTitle(String coach, String time);

  /// No description provided for @notifEventReminderTomorrowTitle.
  ///
  /// In es, this message translates to:
  /// **'Mañana tenés sesión con {coach}'**
  String notifEventReminderTomorrowTitle(String coach);

  /// No description provided for @agendaGoing.
  ///
  /// In es, this message translates to:
  /// **'Voy'**
  String get agendaGoing;

  /// No description provided for @agendaConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Le confirmaste a {coach} que vas.'**
  String agendaConfirmed(String coach);
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
