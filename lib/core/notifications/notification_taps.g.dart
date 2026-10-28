// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_taps.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationTaps)
final notificationTapsProvider = NotificationTapsProvider._();

final class NotificationTapsProvider
    extends
        $FunctionalProvider<
          NotificationTaps,
          NotificationTaps,
          NotificationTaps
        >
    with $Provider<NotificationTaps> {
  NotificationTapsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationTapsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationTapsHash();

  @$internal
  @override
  $ProviderElement<NotificationTaps> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotificationTaps create(Ref ref) {
    return notificationTaps(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationTaps value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationTaps>(value),
    );
  }
}

String _$notificationTapsHash() => r'6e3502c9c2ea57f784ffc1691cc891b693afb25e';
