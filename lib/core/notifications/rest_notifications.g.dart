// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_notifications.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(restNotifications)
final restNotificationsProvider = RestNotificationsProvider._();

final class RestNotificationsProvider
    extends
        $FunctionalProvider<
          RestNotifications,
          RestNotifications,
          RestNotifications
        >
    with $Provider<RestNotifications> {
  RestNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restNotificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restNotificationsHash();

  @$internal
  @override
  $ProviderElement<RestNotifications> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RestNotifications create(Ref ref) {
    return restNotifications(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestNotifications value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestNotifications>(value),
    );
  }
}

String _$restNotificationsHash() => r'77b793a19e3a7ed0ddbefc9f0c595f3062593e4e';
