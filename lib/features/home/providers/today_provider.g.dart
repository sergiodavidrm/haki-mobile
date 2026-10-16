// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(today)
final todayProvider = TodayProvider._();

final class TodayProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodayState>,
          TodayState,
          FutureOr<TodayState>
        >
    with $FutureModifier<TodayState>, $FutureProvider<TodayState> {
  TodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayHash();

  @$internal
  @override
  $FutureProviderElement<TodayState> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TodayState> create(Ref ref) {
    return today(ref);
  }
}

String _$todayHash() => r'45297032dab17bbcfb84b3284e9f63bf057cf615';
