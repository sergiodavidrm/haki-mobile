// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaving => 'Saving…';

  @override
  String get errorOfflineRetry => 'No connection. Try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsTraining => 'Training';

  @override
  String get settingsWeightUnit => 'Weight unit';

  @override
  String get settingsWeightUnitHint => 'Each session starts with it';

  @override
  String get settingsRestVibration => 'Vibrate when rest ends';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get passwordMinLength => 'Use at least 6 characters.';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match.';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String get passwordNew => 'New password';

  @override
  String get passwordRepeat => 'Repeat the password';

  @override
  String get passwordSame => 'It must be different from the current one.';

  @override
  String get passwordWeak => 'It\'s too weak. Try a longer one.';

  @override
  String get passwordReauth =>
      'For security, sign out, sign back in and try again.';

  @override
  String get passwordChangeFailed => 'We couldn\'t change it. Try again.';

  @override
  String get signOutPendingTitle => 'You have workouts not uploaded';

  @override
  String get signOutPendingBody =>
      'There are sets saved on your phone that haven\'t reached your coach yet. If you sign out now they\'ll be lost. Connect to the internet and wait for them to upload.';

  @override
  String get signOutAnyway => 'Sign out anyway';

  @override
  String get commonOffline => 'Offline';

  @override
  String get commonToday => 'Today';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get slogan => 'Will over limits.';

  @override
  String get loadingTitle => 'Loading your week…';

  @override
  String get loadingSubtitle => 'Syncing your program with your coach';

  @override
  String get tabToday => 'Today';

  @override
  String get tabProgram => 'Program';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabProfile => 'Profile';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeLoadErrorTitle => 'We couldn\'t load your program';

  @override
  String get homeLoadErrorBody =>
      'Check your connection and pull down to retry.';

  @override
  String get homeYourProgram => 'Your program';

  @override
  String get homeNoProgramTitle => 'You don\'t have a program yet';

  @override
  String get homeNoProgramBody =>
      'When your coach assigns one, it shows up here.';

  @override
  String get homeUpcoming => 'Upcoming';

  @override
  String homeStartsOn(String date) {
    return 'Starts on $date.';
  }

  @override
  String get homeRestLabel => 'Today · Rest';

  @override
  String get homeRestTitle => 'Rest day';

  @override
  String homeRestNext(String title, String date) {
    return 'Next: $title · $date';
  }

  @override
  String get homeRestPreparing => 'Your coach is preparing what\'s next.';

  @override
  String weekOfTotal(int week, int total) {
    return 'Week $week of $total';
  }

  @override
  String weekOfProgram(int week) {
    return 'Week $week of the program';
  }

  @override
  String get homeWeekDoneTitle => 'Week complete';

  @override
  String get homeWeekDoneBody =>
      'You did every workout this week. Next week follows the program.';

  @override
  String get homeProgramDoneLabel => 'Program finished';

  @override
  String get homeProgramDoneBody =>
      'You completed the block. Your coach will assign the next one.';

  @override
  String get homeYourProfile => 'Your profile';

  @override
  String get homeDayPreparing => 'Your coach is preparing it.';

  @override
  String get stripDone => 'workout done';

  @override
  String get stripPlanned => 'workout';

  @override
  String get stripNone => 'no workout';

  @override
  String workoutsDoneOf(int done, int total) {
    return '$done of $total workouts';
  }

  @override
  String exercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String supersetsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count supersets',
      one: '1 superset',
    );
    return '$_temp0';
  }

  @override
  String videosRequestedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos requested',
      one: '1 video requested',
    );
    return '$_temp0';
  }

  @override
  String get workoutCompleted => 'Workout completed';

  @override
  String get workoutViewUploadVideos => 'View workout · upload videos';

  @override
  String get workoutContinue => 'Continue workout';

  @override
  String get workoutStart => 'Start workout';

  @override
  String get programsMine => 'My programs';

  @override
  String get programsLoadError => 'We couldn\'t load your programs';

  @override
  String get programsYours => 'Your programs';

  @override
  String get programsNoneTitle => 'You don\'t have any programs yet';

  @override
  String get programInProgress => 'In progress';

  @override
  String programsUpcoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Upcoming',
      one: 'Upcoming',
    );
    return '$_temp0';
  }

  @override
  String get programsPast => 'Past';

  @override
  String weeksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String weekN(int week) {
    return 'Week $week';
  }

  @override
  String programSince(String date) {
    return 'Since $date';
  }

  @override
  String get commonNoDates => 'no dates';

  @override
  String get commonNoDate => 'No date';

  @override
  String programStartsOn(String date) {
    return 'starts $date';
  }

  @override
  String get assignDates => 'Assign dates';

  @override
  String get changeDates => 'Change dates';

  @override
  String get programAdherence => 'adherence';

  @override
  String get programCurrentBlock => 'Current block';

  @override
  String get programFinished => 'Finished';

  @override
  String get programsAll => 'All my programs';

  @override
  String get programWeekPreparing => 'Your coach is preparing this week.';

  @override
  String get programDayPreparing => 'Your coach is preparing it';

  @override
  String get dayDone => 'Done';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get commonOptional => 'optional';

  @override
  String get programLoadError =>
      'We couldn\'t load the program. Check your connection.';

  @override
  String get datesSaved => 'Dates saved';

  @override
  String get datesSave => 'Save dates';

  @override
  String get datesSkip => 'Not now · train without dates';

  @override
  String get datesStepStart => '1 · When do you start?';

  @override
  String get datesStartsOn => 'Starts';

  @override
  String datesEndsOn(String date) {
    return 'ends $date';
  }

  @override
  String get datesMoveHint =>
      'Changing the start moves which week of the program you\'re in.';

  @override
  String get datesStepDays => '2 · Which day do you do each workout?';

  @override
  String get datesRepeatHint => 'It repeats the same every week of the block.';

  @override
  String get datesNoWorkouts =>
      'Your coach hasn\'t built this program\'s workouts yet.';

  @override
  String get datesTooMany =>
      'This program has more than 7 workouts per week: ask your coach to assign the dates.';

  @override
  String get monthPrev => 'Previous month';

  @override
  String get monthNext => 'Next month';

  @override
  String datesDayOn(String title, String weekday) {
    return '$title on $weekday';
  }

  @override
  String get datesFirstOccurrence => '1st: ';

  @override
  String get sessionTitle => 'Session';

  @override
  String get sessionLoadError =>
      'We couldn\'t load the session. Check your connection.';

  @override
  String get sessionDayGone => 'This day is no longer in the program.';

  @override
  String get sessionCompleted => 'Completed';

  @override
  String get sessionNoSets => 'No sets logged';

  @override
  String get sessionYourNote => 'Your note';

  @override
  String sessionViewSetVideo(int set) {
    return 'View video of set $set';
  }

  @override
  String dayN(int day) {
    return 'Day $day';
  }

  @override
  String get sessionOpenError => 'Couldn\'t open the session.';

  @override
  String get sessionDoneSeeSummary => 'Workout completed · see summary';

  @override
  String get sessionFinish => 'Finish workout';

  @override
  String get videoLogSetFirst => 'Log the set before uploading the video.';

  @override
  String get videoUploadingReplace =>
      'The video is uploading. If you record another, it replaces it.';

  @override
  String get videoUploadQuestion => 'Upload video?';

  @override
  String get videoNotRequested =>
      'Your coach didn\'t request a video for this set. Upload it anyway?';

  @override
  String get videoUpload => 'Upload video';

  @override
  String get videoAlreadySent => 'You already sent a video for this set';

  @override
  String get videoReplaces => 'The new one replaces it.';

  @override
  String get videoRecord => 'Record';

  @override
  String get videoPickGallery => 'Choose from gallery';

  @override
  String get videoQueued =>
      'Video queued: it uploads on its own, even if you close the app.';

  @override
  String restSetDone(int set) {
    return 'Set $set done';
  }

  @override
  String supersetN(String letter) {
    return 'Superset $letter';
  }

  @override
  String restSupersetMid(String badge) {
    return '$badge done · keep going without rest';
  }

  @override
  String restBadgesDone(String badges, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$badges done',
      one: '$badges done',
    );
    return '$_temp0';
  }

  @override
  String restBeforeRepeat(String done) {
    return '$done · rest before repeating';
  }

  @override
  String get finishQuestion => 'Finish the workout?';

  @override
  String finishMissingSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You still have $count sets to log.',
      one: 'You still have 1 set to log.',
    );
    return '$_temp0';
  }

  @override
  String get finishKeepTraining => 'Keep training';

  @override
  String get finish => 'Finish';

  @override
  String get sessionJustStarted => 'just started';

  @override
  String sessionTrainingFor(int minutes) {
    return 'training for $minutes min';
  }

  @override
  String sessionStartedOn(String date) {
    return 'started $date';
  }

  @override
  String countOf(int done, int total) {
    return '$done of $total';
  }

  @override
  String sessionPendingSync(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets saved on your phone · upload when you have signal',
      one: '1 set saved on your phone · uploads when you have signal',
    );
    return '$_temp0';
  }

  @override
  String get sessionDayUnit => 'Today\'s weight unit';

  @override
  String supersetNoRest(String items) {
    return 'No rest between $items';
  }

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get commonAnd => 'and';

  @override
  String get restAgain => 'Again';

  @override
  String get restPause => 'Pause';

  @override
  String get restResume => 'Resume';

  @override
  String get restStart => 'Start';

  @override
  String get restMinimize => 'Minimize timer';

  @override
  String get restTitle => 'Rest';

  @override
  String get restGo => 'Let\'s go!';

  @override
  String get restPaused => 'Paused';

  @override
  String restOf(String total) {
    return 'of $total';
  }

  @override
  String get restDuration => 'Duration';

  @override
  String get restDurationHint => 'Remembers the last one you used';

  @override
  String get restMinus15 => 'Subtract 15 seconds';

  @override
  String get restPlus15 => 'Add 15 seconds';

  @override
  String get restReset => 'Reset';

  @override
  String get restSkip => 'Skip rest';

  @override
  String restOfDuration(String time) {
    return '$time rest';
  }

  @override
  String setN(int set) {
    return 'Set $set';
  }

  @override
  String get restTimer => 'Rest timer';

  @override
  String get restOpenTimer => 'Open rest timer';

  @override
  String restThen(String exercise, int set) {
    return 'Then: $exercise · set $set';
  }

  @override
  String get restResetRest => 'Reset rest';

  @override
  String get restPauseRest => 'Pause rest';

  @override
  String get restResumeRest => 'Resume rest';

  @override
  String get restCloseTimer => 'Close timer';

  @override
  String get setHeader => 'SET';

  @override
  String get targetHeaderShort => 'TGT.';

  @override
  String get targetHeader => 'TARGET';

  @override
  String get repsHeader => 'REPS';

  @override
  String setWeightLabel(int set, String unit) {
    return 'Weight of set $set in $unit';
  }

  @override
  String setRepsLabel(int set) {
    return 'Reps of set $set';
  }

  @override
  String setRirLabel(int set) {
    return 'RIR of set $set';
  }

  @override
  String setLog(int set) {
    return 'Log set $set';
  }

  @override
  String setEdit(int set) {
    return 'Edit set $set';
  }

  @override
  String setVideoUploading(int set) {
    return 'Video of set $set uploading';
  }

  @override
  String setVideoSent(int set) {
    return 'Video of set $set sent, tap to replace it';
  }

  @override
  String setVideoRequested(int set) {
    return 'Upload video of set $set, requested by your coach';
  }

  @override
  String setVideoNotRequested(int set) {
    return 'Upload video of set $set (your coach didn\'t ask for it)';
  }

  @override
  String get summaryError => 'Couldn\'t calculate the summary.';

  @override
  String get commonDone => 'Done';

  @override
  String get statSets => 'Sets';

  @override
  String get statVolume => 'Volume';

  @override
  String videoRequestedSets(String sets, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Your coach asked for a video of sets $sets. Tap the camera to record or upload.',
      one:
          'Your coach asked for a video of set $sets. Tap the camera to record or upload.',
    );
    return '$_temp0';
  }

  @override
  String get exerciseComplete => 'Exercise complete';

  @override
  String get noSetsPrescribed => 'No sets prescribed';

  @override
  String setsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
    );
    return '$_temp0';
  }

  @override
  String get repsShort => 'reps';

  @override
  String setsDoneOf(int done, int total) {
    return '$done of $total sets done';
  }

  @override
  String get trimTitle => 'Trim video';

  @override
  String get trimOpenError => 'Couldn\'t open the video.';

  @override
  String trimMax(int seconds) {
    return 'Maximum $seconds seconds';
  }

  @override
  String get trimUse => 'Use video';

  @override
  String get notifRestDoneQuietChannel => 'Rest finished (no vibration)';

  @override
  String get notifRestDoneChannel => 'Rest finished';

  @override
  String get notifRestDoneChannelDesc => 'Sound alert when the rest ends';

  @override
  String get notifBackToWorkout => 'Tap to go back to your workout';

  @override
  String get notifRestRunningChannel => 'Rest in progress';

  @override
  String get notifRestRunningChannelDesc =>
      'Countdown of the rest between sets';

  @override
  String get notifRestOver => 'Rest is over';

  @override
  String get notifRestPaused => 'Rest paused';

  @override
  String notifNextSet(String exercise, int set) {
    return 'Next: $exercise · set $set';
  }

  @override
  String get exerciseTitle => 'Exercise';

  @override
  String get exerciseGone => 'This exercise is no longer in the day.';

  @override
  String exerciseVideoFeedback(String title) {
    return 'Feedback on your video · $title';
  }

  @override
  String get exerciseHistory => 'History';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get exerciseNeverDone => 'You haven\'t done this exercise yet.';

  @override
  String get exerciseOfflineHistory =>
      'Offline: only this program\'s history is shown.';

  @override
  String get exercisePlayTechnique => 'Play technique video';

  @override
  String get exerciseTechniqueVideo => 'Technique video';

  @override
  String get exerciseHowTo => 'How to do it';

  @override
  String get seeLess => 'See less';

  @override
  String get seeMore => 'See more';

  @override
  String get exerciseCoachNote => 'NOTE FROM YOUR COACH';

  @override
  String get exerciseE1rmEstimated => 'ESTIMATED e1RM';

  @override
  String get exerciseNewPr => 'NEW PR';

  @override
  String exerciseTrend(String from, String to, int count) {
    return 'e1RM trend: from $from to $to over $count sessions';
  }

  @override
  String exerciseInBlock(String delta) {
    return '$delta this block';
  }

  @override
  String exerciseVolumeToday(String volume) {
    return 'Volume today $volume';
  }

  @override
  String loadMore(int count) {
    return 'Load more ($count)';
  }

  @override
  String get weekLastShort => 'Last wk';

  @override
  String weekShortN(int week) {
    return 'Wk $week';
  }

  @override
  String weekLetter(int week) {
    return 'W$week';
  }

  @override
  String get lastTime => 'Last time';

  @override
  String coachLabel(String name) {
    return 'Coach: $name';
  }

  @override
  String streakWeeksInARow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks in a row',
      one: '1 week in a row',
    );
    return '$_temp0';
  }

  @override
  String get streakStart => 'Start your streak';

  @override
  String streakThisWeek(int done, int target) {
    return 'This week: $done of $target';
  }

  @override
  String streakBest(String weeks) {
    return 'Your best streak: $weeks';
  }

  @override
  String get recordsTitle => 'Records';

  @override
  String get recordsBestMarks => 'Your best marks';

  @override
  String get recordsInTotal => 'in total';

  @override
  String get recordsInBlock => 'this block';

  @override
  String get recordsRecent => 'Recent PRs';

  @override
  String get bodyWeight => 'Body weight';

  @override
  String get bodyLogWeight => 'Log your weight';

  @override
  String get bodyIn4Weeks => 'in 4 wks';

  @override
  String get measuresTitle => 'Measurements';

  @override
  String measuresCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count measurements',
      one: '1 measurement',
    );
    return '$_temp0';
  }

  @override
  String get measuresNoLogs => 'no entries';

  @override
  String get adherenceTitle => 'Adherence';

  @override
  String get adherenceNoProgram => 'No program in progress';

  @override
  String adherenceDoneOf(int done, int due) {
    return '$done of $due workouts in the program';
  }

  @override
  String ofTotal(int total) {
    return 'of $total';
  }

  @override
  String get adherenceWorkoutsDone => 'workouts done';

  @override
  String get recordsPersonal => 'Personal records';

  @override
  String get recordsThisBlock => 'This block';

  @override
  String get recordsAllTime => 'All time';

  @override
  String get recordsHint =>
      'Best estimated e1RM per exercise, calculated from your logged sets.';

  @override
  String get recordsThisWeek => 'THIS WEEK';

  @override
  String get recordsInThisBlockUpper => 'THIS BLOCK';

  @override
  String get recordsPreviousUpper => 'EARLIER';

  @override
  String get recordsEmpty =>
      'Keep logging your sets: every time you beat your best mark it shows up here.';

  @override
  String get recordsLoadError =>
      'Couldn\'t load your records. Check your connection.';

  @override
  String get commonYesterday => 'yesterday';

  @override
  String get measureGroupTorso => 'Torso';

  @override
  String get measureGroupLimbs => 'Arms and legs';

  @override
  String get measureGroupComposition => 'Composition';

  @override
  String get measureGroupOther => 'Other';

  @override
  String get measureUnitLevel => 'level';

  @override
  String get range4Weeks => '4 wks';

  @override
  String get range3Months => '3 months';

  @override
  String get rangeAll => 'All';

  @override
  String get measureNeck => 'Neck';

  @override
  String get measureChest => 'Chest';

  @override
  String get measureLeftArm => 'Left arm';

  @override
  String get measureRightArm => 'Right arm';

  @override
  String get measureLeftForearm => 'Left forearm';

  @override
  String get measureRightForearm => 'Right forearm';

  @override
  String get measureWaist => 'Waist';

  @override
  String get measureAbdomen => 'Abdomen';

  @override
  String get measureHips => 'Hips';

  @override
  String get measureLeftThigh => 'Left thigh';

  @override
  String get measureRightThigh => 'Right thigh';

  @override
  String get measureLeftCalf => 'Left calf';

  @override
  String get measureRightCalf => 'Right calf';

  @override
  String get measureBodyFat => 'Body fat';

  @override
  String get measureMuscleMass => 'Muscle mass';

  @override
  String get measureVisceralFat => 'Visceral fat';

  @override
  String get bodyNoWeightYet => 'You haven\'t logged your weight yet.';

  @override
  String get bodyNoMeasureYet => 'You haven\'t logged this measurement yet.';

  @override
  String get bodyWeightShort => 'Weight';

  @override
  String get bodyLoadError =>
      'We couldn\'t load your data. Check your connection.';

  @override
  String get bodyLogWeightButton => 'Log weight';

  @override
  String get measuresLog => 'Log measurements';

  @override
  String lastEntry(String date) {
    return 'Last entry · $date';
  }

  @override
  String get rangeIn4Weeks => 'in 4 weeks';

  @override
  String get rangeIn3Months => 'in 3 months';

  @override
  String get rangeSinceStart => 'since the start';

  @override
  String get bodyTwoEntriesHint =>
      'With two entries in this range you\'ll see the chart.';

  @override
  String bodyTrend(String title, String from, String to) {
    return '$title from $from to $to';
  }

  @override
  String bodyLast(String value) {
    return 'Last: $value';
  }

  @override
  String get measuresNoneChosen =>
      'Your coach hasn\'t chosen measurements to track yet.';

  @override
  String get measuresNoneYet => 'You haven\'t logged measurements yet';

  @override
  String get measuresSeePrevious => 'See previous entries';

  @override
  String get measuresLoadError =>
      'We couldn\'t load your measurements. Check your connection.';

  @override
  String measuresChosenBy(String coach) {
    return '$coach chose these measurements for you to track.';
  }

  @override
  String get measuresBlankHint =>
      'You can leave blank the ones you don\'t measure today.';

  @override
  String measuresPrevious(String value) {
    return 'Previous: $value';
  }

  @override
  String get measuresLogs => 'Measurement entries';

  @override
  String get measuresNoneYetDot => 'You haven\'t logged measurements yet.';

  @override
  String get yourCoach => 'Your coach';

  @override
  String get chatOpenError =>
      'Couldn\'t open the chat.\nCheck your connection.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get chatMessagesError => 'Couldn\'t load the messages.';

  @override
  String chatEmpty(String coach) {
    return 'Write to $coach. Your set videos show up here too.';
  }

  @override
  String get chatMessageHint => 'Message…';

  @override
  String feedbackWaiting(String coach) {
    return 'Waiting for feedback from $coach';
  }

  @override
  String get you => 'You';

  @override
  String repliesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
    );
    return '$_temp0';
  }

  @override
  String get feedbackSee => 'See feedback';

  @override
  String get feedbackYourVideosUpper => 'YOUR VIDEOS';

  @override
  String get feedbackRepliesError => 'Couldn\'t load the replies.';

  @override
  String get feedbackNotReviewed => 'Your coach hasn\'t reviewed it yet';

  @override
  String get feedbackTellCoach =>
      'If you want to tell them something about the exercise, write it here.';

  @override
  String feedbackReplyTo(String coach) {
    return 'Reply to $coach…';
  }

  @override
  String get feedbackYourVideos => 'Feedback on your videos';

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
  String get feedbackNoneYet => 'no feedback yet';

  @override
  String feedbackMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count feedback messages',
      one: '1 feedback message',
    );
    return '$_temp0';
  }

  @override
  String get feedbackVideoNone => 'Your video has no feedback yet';

  @override
  String messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$_temp0';
  }

  @override
  String get feedbackSeeThread => 'See thread';

  @override
  String get see => 'See';

  @override
  String get chatNotSent => 'Not sent · Retry';

  @override
  String get chatSend => 'Send';

  @override
  String get notifChatChannel => 'Messages from your coach';

  @override
  String get notifChatChannelDesc => 'Chat and feedback from your coach';

  @override
  String notifVideosOf(String exercise) {
    return 'Videos of $exercise';
  }

  @override
  String get notifSentMessage => 'Sent you a message';

  @override
  String notifFeedbackFrom(String name) {
    return 'Feedback from $name';
  }

  @override
  String get videoLoadError => 'Couldn\'t load the video.';

  @override
  String get authEmail => 'Email';

  @override
  String get authInvalidEmail => 'Enter a valid email';

  @override
  String get authPassword => 'Password';

  @override
  String get authEnterPassword => 'Enter your password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get gateCoach =>
      'This app is for athletes. As a coach, sign in at hakifit.com.';

  @override
  String get gateConnectError =>
      'Couldn\'t connect. Check your connection and try again.';

  @override
  String get authWrongCredentials => 'Wrong email or password';

  @override
  String get authConfirmEmail => 'Confirm your email before signing in';

  @override
  String get authGoogleError => 'Couldn\'t sign in with Google. Try again.';

  @override
  String get authGenericError =>
      'Couldn\'t sign in. Check your connection and try again.';

  @override
  String get sessionProgramNotCurrent =>
      'The program is no longer in progress.';

  @override
  String get commonClose => 'Close';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonSending => 'Sending…';

  @override
  String get questionnaireTitle => 'Questionnaire';

  @override
  String get questionnaireAnswer => 'Answer';

  @override
  String questionnairePendingSince(String date) {
    return 'Pending since $date · 1 min';
  }

  @override
  String questionnaireSentOn(String date) {
    return 'Sent $date · pending';
  }

  @override
  String questionnaireIntro(String coach) {
    return '$coach uses it to adjust your next week. It takes 1 minute.';
  }

  @override
  String get questionnaireWorst => 'Worst';

  @override
  String get questionnaireBest => 'Best';

  @override
  String get questionnaireDetailHint =>
      'Tell us more: where, when, which exercise…';

  @override
  String get questionnaireTextHint => 'Write your answer';

  @override
  String get questionnaireSend => 'Send';

  @override
  String questionnaireSendTo(String coach) {
    return 'Send to $coach';
  }

  @override
  String get questionnaireSent => 'Done! Your coach has your answers.';

  @override
  String get questionnaireNotFound =>
      'This questionnaire was already answered or your coach removed it.';

  @override
  String get notifQuestionnaireChannel => 'Questionnaires';

  @override
  String get notifQuestionnaireChannelDesc =>
      'Reminder when your coach sends you a questionnaire';

  @override
  String get notifQuestionnaireBody =>
      'Your coach sent you this week\'s questionnaire. It takes 1 minute.';

  @override
  String ofTotalShort(int done, int total) {
    return '$done of $total';
  }

  @override
  String get adherenceSets => 'Sets in your workouts';

  @override
  String get adherencePrevious => 'Previous block';

  @override
  String get adherenceNoPrevious => 'Your first block';

  @override
  String get adherenceByWeek => 'By week';

  @override
  String get adherenceProgramWorkouts => 'Program workouts';

  @override
  String get adherenceMissed => 'Not completed';

  @override
  String get adherenceNotLogged => 'not logged';

  @override
  String get adherenceCurrentBlock => 'CURRENT BLOCK';

  @override
  String adherenceDoneUntilToday(int done, int due) {
    return '$done of $due workouts so far';
  }

  @override
  String adherenceDoneOfTotal(int done, int total) {
    return '$done of $total workouts done';
  }

  @override
  String get adherenceLegendDone => 'Done';

  @override
  String get adherenceLegendMissed => 'Missed';

  @override
  String get adherenceLegendPending => 'Pending';

  @override
  String adherenceSetsFooter(int done, int total, int workouts) {
    String _temp0 = intl.Intl.pluralLogic(
      workouts,
      locale: localeName,
      other: 'in the $workouts you did',
      one: 'in the one you did',
      zero: 'no workouts yet',
    );
    return '$done of $total · $_temp0';
  }

  @override
  String get gateAccessEnded =>
      'Your coach ended your plan and your access to Haki has expired. If you think this is a mistake, contact them.';

  @override
  String homeAccessEnds(String date) {
    return 'Your coach ended your plan. You can keep using Haki until $date.';
  }

  @override
  String coachExperience(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years of experience',
      one: '1 year of experience',
      zero: 'Less than 1 year of experience',
    );
    return '$_temp0';
  }

  @override
  String get coachAbout => 'About me';

  @override
  String get coachCertifications => 'Certifications';

  @override
  String coachWrite(String name) {
    return 'Message $name';
  }

  @override
  String coachProfileEmpty(String name) {
    return '$name hasn\'t filled in their profile yet.';
  }

  @override
  String get authFirstTime => 'First time?';

  @override
  String get authCreateAccount => 'Create your account';

  @override
  String get authEnterCode => 'Enter the code from the email';

  @override
  String get signupTitle => 'Create your account';

  @override
  String get signupSubtitle =>
      'Use the same email your coach sent the invitation to.';

  @override
  String get signupRepeatPassword => 'Repeat the password';

  @override
  String get signupPasswordsDontMatch => 'Passwords don\'t match';

  @override
  String get signupRuleLength => 'At least 8 characters';

  @override
  String get signupRuleLetter => 'A letter';

  @override
  String get signupRuleDigit => 'A number';

  @override
  String get signupRuleNotEmail => 'Not your email';

  @override
  String get signupSubmit => 'Create account';

  @override
  String get signupHaveAccount => 'Already have an account?';

  @override
  String get signupSignIn => 'Sign in';

  @override
  String get signupWeakPassword =>
      'The password doesn\'t meet the requirements';

  @override
  String get signupError =>
      'Couldn\'t create the account. Check your connection and try again.';

  @override
  String get codeTitle => 'Check your email';

  @override
  String codeSubtitle(String email) {
    return 'We sent a 6-digit code to $email. Enter it here to confirm the email is yours.';
  }

  @override
  String get codeLabel => 'Code';

  @override
  String get codeExpires => 'The code expires in 1 hour.';

  @override
  String get codeConfirm => 'Confirm';

  @override
  String get codeResend => 'Resend code';

  @override
  String codeResendIn(int seconds) {
    return 'Resend code in $seconds s';
  }

  @override
  String get codeResent => 'We sent you a new code.';

  @override
  String get codeInvalid => 'The code is invalid or has expired.';

  @override
  String get codeHelp =>
      'Didn\'t get it? Check your spam folder. If you mistyped the email, go back and fix it.';

  @override
  String get inviteTitle => 'You have an invitation';

  @override
  String get inviteSubtitle =>
      'Once you accept, your coach builds your program and supports you from here.';

  @override
  String get inviteCoach => 'Coach';

  @override
  String get inviteFor => 'Invitation for';

  @override
  String get inviteAccept => 'Accept invitation';

  @override
  String get inviteNotMine => 'Not my coach · Sign out';

  @override
  String get inviteNoneTitle => 'We couldn\'t find your invitation';

  @override
  String inviteNoneBody(String email) {
    return 'You\'re signed in as $email and there\'s no invitation for that email.';
  }

  @override
  String get inviteNoneHint =>
      'Haki is invite-only: sign in with the email your coach wrote to, or ask them to invite this one.';

  @override
  String get inviteOtherAccount => 'Sign in with another account';

  @override
  String get inviteSearchAgain => 'I was invited · Search again';

  @override
  String get personalTitle => 'My details';

  @override
  String personalIntro(String coach) {
    return '$coach uses them to build your program.';
  }

  @override
  String get personalIntroNoCoach =>
      'Your coach uses them to build your program.';

  @override
  String get personalSection => 'PERSONAL DETAILS';

  @override
  String get personalName => 'Name';

  @override
  String get personalNameRequired => 'Enter your name';

  @override
  String get personalEmail => 'Email';

  @override
  String get personalEmailHint =>
      'It is your sign-in user. It can\'t be changed here.';

  @override
  String get personalGender => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get personalHeight => 'Height';

  @override
  String get personalHeightInvalid => 'Check your height (50–260 cm)';

  @override
  String get personalInjuriesSection => 'INJURIES AND PAIN';

  @override
  String get personalInjuries => 'Anything your coach should know?';

  @override
  String get personalInjuriesHint =>
      'An injury, some pain or something you can\'t do. Your coach sees it in your profile.';

  @override
  String get personalGoalSection => 'GOAL';

  @override
  String get personalGoalNone => 'Your coach hasn\'t set your goal yet.';

  @override
  String get personalGoalHint => 'Your coach sets it. Want to change it?';

  @override
  String get personalGoalWrite => 'Message them';

  @override
  String get personalWeightSection => 'WEIGHT';

  @override
  String get personalWeightHint => 'Logged in Body weight';

  @override
  String get personalSaved => 'Details saved';

  @override
  String get goalFatLoss => 'Fat loss';

  @override
  String get goalMuscleGain => 'Muscle gain';

  @override
  String get goalStrength => 'Strength';

  @override
  String get goalEndurance => 'Endurance';

  @override
  String get goalRecomposition => 'Body recomposition';

  @override
  String get goalGeneralHealth => 'General health';
}
