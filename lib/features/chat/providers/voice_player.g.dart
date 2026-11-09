// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_player.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VoicePlayback)
final voicePlaybackProvider = VoicePlaybackProvider._();

final class VoicePlaybackProvider
    extends $NotifierProvider<VoicePlayback, VoicePlaybackState> {
  VoicePlaybackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voicePlaybackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voicePlaybackHash();

  @$internal
  @override
  VoicePlayback create() => VoicePlayback();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoicePlaybackState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoicePlaybackState>(value),
    );
  }
}

String _$voicePlaybackHash() => r'e28bb80d52b927064726cb275874fbdd48765bb3';

abstract class _$VoicePlayback extends $Notifier<VoicePlaybackState> {
  VoicePlaybackState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VoicePlaybackState, VoicePlaybackState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoicePlaybackState, VoicePlaybackState>,
              VoicePlaybackState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
