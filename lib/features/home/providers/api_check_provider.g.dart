// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_check_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(apiCheck)
final apiCheckProvider = ApiCheckProvider._();

final class ApiCheckProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  ApiCheckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiCheckProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiCheckHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return apiCheck(ref);
  }
}

String _$apiCheckHash() => r'abd140a353e99a8cbfa8a1f92aa901be8936bc0b';
