// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_push.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatPush)
final chatPushProvider = ChatPushProvider._();

final class ChatPushProvider
    extends $FunctionalProvider<ChatPush, ChatPush, ChatPush>
    with $Provider<ChatPush> {
  ChatPushProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatPushProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatPushHash();

  @$internal
  @override
  $ProviderElement<ChatPush> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatPush create(Ref ref) {
    return chatPush(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatPush value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatPush>(value),
    );
  }
}

String _$chatPushHash() => r'd7e504c7103c541a2df1afd03a3cc4ffde1d8450';
