// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [messageId] = `streamMessageId` del exercise-log. Necesita red.

@ProviderFor(feedbackSummary)
final feedbackSummaryProvider = FeedbackSummaryFamily._();

/// [messageId] = `streamMessageId` del exercise-log. Necesita red.

final class FeedbackSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<FeedbackSummary>,
          FeedbackSummary,
          FutureOr<FeedbackSummary>
        >
    with $FutureModifier<FeedbackSummary>, $FutureProvider<FeedbackSummary> {
  /// [messageId] = `streamMessageId` del exercise-log. Necesita red.
  FeedbackSummaryProvider._({
    required FeedbackSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'feedbackSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedbackSummaryHash();

  @override
  String toString() {
    return r'feedbackSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FeedbackSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FeedbackSummary> create(Ref ref) {
    final argument = this.argument as String;
    return feedbackSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedbackSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedbackSummaryHash() => r'a5aee25faf6d18778e28374f551d2cd85cdca02b';

/// [messageId] = `streamMessageId` del exercise-log. Necesita red.

final class FeedbackSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FeedbackSummary>, String> {
  FeedbackSummaryFamily._()
    : super(
        retry: null,
        name: r'feedbackSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [messageId] = `streamMessageId` del exercise-log. Necesita red.

  FeedbackSummaryProvider call(String messageId) =>
      FeedbackSummaryProvider._(argument: messageId, from: this);

  @override
  String toString() => r'feedbackSummaryProvider';
}

/// Tarjeta de videos de un ejercicio del día ([dayExerciseId] =
/// BlockDayExerciseId) entre los mensajes cargados del chat. Para la Sesión:
/// el detalle del programa no se recarga durante el entreno, así que una
/// tarjeta recién publicada no trae su `streamMessageId` por ahí.

@ProviderFor(cardIdFor)
final cardIdForProvider = CardIdForFamily._();

/// Tarjeta de videos de un ejercicio del día ([dayExerciseId] =
/// BlockDayExerciseId) entre los mensajes cargados del chat. Para la Sesión:
/// el detalle del programa no se recarga durante el entreno, así que una
/// tarjeta recién publicada no trae su `streamMessageId` por ahí.

final class CardIdForProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// Tarjeta de videos de un ejercicio del día ([dayExerciseId] =
  /// BlockDayExerciseId) entre los mensajes cargados del chat. Para la Sesión:
  /// el detalle del programa no se recarga durante el entreno, así que una
  /// tarjeta recién publicada no trae su `streamMessageId` por ahí.
  CardIdForProvider._({
    required CardIdForFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cardIdForProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardIdForHash();

  @override
  String toString() {
    return r'cardIdForProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    final argument = this.argument as String;
    return cardIdFor(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CardIdForProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardIdForHash() => r'8dfd5b2521155045132cb8285b363964adfdccd1';

/// Tarjeta de videos de un ejercicio del día ([dayExerciseId] =
/// BlockDayExerciseId) entre los mensajes cargados del chat. Para la Sesión:
/// el detalle del programa no se recarga durante el entreno, así que una
/// tarjeta recién publicada no trae su `streamMessageId` por ahí.

final class CardIdForFamily extends $Family
    with $FunctionalFamilyOverride<Stream<String?>, String> {
  CardIdForFamily._()
    : super(
        retry: null,
        name: r'cardIdForProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Tarjeta de videos de un ejercicio del día ([dayExerciseId] =
  /// BlockDayExerciseId) entre los mensajes cargados del chat. Para la Sesión:
  /// el detalle del programa no se recarga durante el entreno, así que una
  /// tarjeta recién publicada no trae su `streamMessageId` por ahí.

  CardIdForProvider call(String dayExerciseId) =>
      CardIdForProvider._(argument: dayExerciseId, from: this);

  @override
  String toString() => r'cardIdForProvider';
}
