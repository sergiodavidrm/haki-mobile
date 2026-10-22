// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cuestionarios pendientes (tarjetas de Hoy) + semanales asignados.

@ProviderFor(myQuestionnaires)
final myQuestionnairesProvider = MyQuestionnairesProvider._();

/// Cuestionarios pendientes (tarjetas de Hoy) + semanales asignados.

final class MyQuestionnairesProvider
    extends
        $FunctionalProvider<
          AsyncValue<AthleteQuestionnaires>,
          AthleteQuestionnaires,
          FutureOr<AthleteQuestionnaires>
        >
    with
        $FutureModifier<AthleteQuestionnaires>,
        $FutureProvider<AthleteQuestionnaires> {
  /// Cuestionarios pendientes (tarjetas de Hoy) + semanales asignados.
  MyQuestionnairesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myQuestionnairesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myQuestionnairesHash();

  @$internal
  @override
  $FutureProviderElement<AthleteQuestionnaires> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AthleteQuestionnaires> create(Ref ref) {
    return myQuestionnaires(ref);
  }
}

String _$myQuestionnairesHash() => r'374acf7db27a4052f90d65a88433ac9935271d7a';

/// Un pendiente por id de envío (pantalla para responder).

@ProviderFor(pendingQuestionnaire)
final pendingQuestionnaireProvider = PendingQuestionnaireFamily._();

/// Un pendiente por id de envío (pantalla para responder).

final class PendingQuestionnaireProvider
    extends
        $FunctionalProvider<
          PendingQuestionnaire?,
          PendingQuestionnaire?,
          PendingQuestionnaire?
        >
    with $Provider<PendingQuestionnaire?> {
  /// Un pendiente por id de envío (pantalla para responder).
  PendingQuestionnaireProvider._({
    required PendingQuestionnaireFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pendingQuestionnaireProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pendingQuestionnaireHash();

  @override
  String toString() {
    return r'pendingQuestionnaireProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<PendingQuestionnaire?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PendingQuestionnaire? create(Ref ref) {
    final argument = this.argument as String;
    return pendingQuestionnaire(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingQuestionnaire? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingQuestionnaire?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PendingQuestionnaireProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pendingQuestionnaireHash() =>
    r'7aa69f851c2b0e1e622a1306be4da66f7a7208f0';

/// Un pendiente por id de envío (pantalla para responder).

final class PendingQuestionnaireFamily extends $Family
    with $FunctionalFamilyOverride<PendingQuestionnaire?, String> {
  PendingQuestionnaireFamily._()
    : super(
        retry: null,
        name: r'pendingQuestionnaireProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Un pendiente por id de envío (pantalla para responder).

  PendingQuestionnaireProvider call(String responseId) =>
      PendingQuestionnaireProvider._(argument: responseId, from: this);

  @override
  String toString() => r'pendingQuestionnaireProvider';
}

/// Mantiene programado el aviso local de las 20:00 de cada semanal asignado y
/// recarga los pendientes al volver a primer plano. Se arranca en app.dart.

@ProviderFor(questionnaireSync)
final questionnaireSyncProvider = QuestionnaireSyncProvider._();

/// Mantiene programado el aviso local de las 20:00 de cada semanal asignado y
/// recarga los pendientes al volver a primer plano. Se arranca en app.dart.

final class QuestionnaireSyncProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Mantiene programado el aviso local de las 20:00 de cada semanal asignado y
  /// recarga los pendientes al volver a primer plano. Se arranca en app.dart.
  QuestionnaireSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questionnaireSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questionnaireSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return questionnaireSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$questionnaireSyncHash() => r'dc0e9458935ff31a315d81e4a11882695671d78d';

/// Enviar las respuestas. El estado es el envío en curso (loading / error con
/// el mensaje de la API).

@ProviderFor(QuestionnaireSubmitter)
final questionnaireSubmitterProvider = QuestionnaireSubmitterProvider._();

/// Enviar las respuestas. El estado es el envío en curso (loading / error con
/// el mensaje de la API).
final class QuestionnaireSubmitterProvider
    extends $AsyncNotifierProvider<QuestionnaireSubmitter, void> {
  /// Enviar las respuestas. El estado es el envío en curso (loading / error con
  /// el mensaje de la API).
  QuestionnaireSubmitterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questionnaireSubmitterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questionnaireSubmitterHash();

  @$internal
  @override
  QuestionnaireSubmitter create() => QuestionnaireSubmitter();
}

String _$questionnaireSubmitterHash() =>
    r'd4bf6caa306ec720cfc4e9ddd9dfcfef3d21e68d';

/// Enviar las respuestas. El estado es el envío en curso (loading / error con
/// el mensaje de la API).

abstract class _$QuestionnaireSubmitter extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
