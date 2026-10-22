// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(questionnaireRepository)
final questionnaireRepositoryProvider = QuestionnaireRepositoryProvider._();

final class QuestionnaireRepositoryProvider
    extends
        $FunctionalProvider<
          QuestionnaireRepository,
          QuestionnaireRepository,
          QuestionnaireRepository
        >
    with $Provider<QuestionnaireRepository> {
  QuestionnaireRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questionnaireRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questionnaireRepositoryHash();

  @$internal
  @override
  $ProviderElement<QuestionnaireRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuestionnaireRepository create(Ref ref) {
    return questionnaireRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestionnaireRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestionnaireRepository>(value),
    );
  }
}

String _$questionnaireRepositoryHash() =>
    r'5c0fad1e22609103ab9bda2ae5b6b82c34b578b0';
