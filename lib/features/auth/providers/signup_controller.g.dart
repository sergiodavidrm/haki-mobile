// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SignUpController)
final signUpControllerProvider = SignUpControllerProvider._();

final class SignUpControllerProvider
    extends $AsyncNotifierProvider<SignUpController, void> {
  SignUpControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpControllerHash();

  @$internal
  @override
  SignUpController create() => SignUpController();
}

String _$signUpControllerHash() => r'ab4d75a91d67495677e262926afdd2173bba16fc';

abstract class _$SignUpController extends $AsyncNotifier<void> {
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

@ProviderFor(SignUpCodeController)
final signUpCodeControllerProvider = SignUpCodeControllerProvider._();

final class SignUpCodeControllerProvider
    extends $AsyncNotifierProvider<SignUpCodeController, void> {
  SignUpCodeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpCodeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpCodeControllerHash();

  @$internal
  @override
  SignUpCodeController create() => SignUpCodeController();
}

String _$signUpCodeControllerHash() =>
    r'9fd6557989ec5031d96dcdd70657f6fe036c7a2b';

abstract class _$SignUpCodeController extends $AsyncNotifier<void> {
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
