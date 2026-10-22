// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_reminders.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(questionnaireReminders)
final questionnaireRemindersProvider = QuestionnaireRemindersProvider._();

final class QuestionnaireRemindersProvider
    extends
        $FunctionalProvider<
          QuestionnaireReminders,
          QuestionnaireReminders,
          QuestionnaireReminders
        >
    with $Provider<QuestionnaireReminders> {
  QuestionnaireRemindersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questionnaireRemindersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questionnaireRemindersHash();

  @$internal
  @override
  $ProviderElement<QuestionnaireReminders> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuestionnaireReminders create(Ref ref) {
    return questionnaireReminders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestionnaireReminders value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestionnaireReminders>(value),
    );
  }
}

String _$questionnaireRemindersHash() =>
    r'948bc24cfb805d8fe7c565fd6bd34cf0e7947d27';
