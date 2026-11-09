import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/chat/data/voice.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

void main() {
  test('voiceOf lee duración, forma de onda y URL del adjunto', () {
    final m = Message(
      attachments: [
        Attachment(
          type: AttachmentType.voiceRecording,
          assetUrl: 'https://cdn/a.m4a',
          extraData: const {
            'duration': 42.4,
            'waveform_data': [0.1, 1.5, -1, 'x'],
          },
        ),
      ],
    );
    final v = voiceOf(m)!;
    expect(v.duration, const Duration(milliseconds: 42400));
    expect(v.waveform, [0.1, 1.0, 0.0]);
    expect(v.url, 'https://cdn/a.m4a');
    expect(v.playable, isTrue);
  });

  test('voiceOf: sin audio = null', () {
    expect(voiceOf(Message(text: 'hola')), isNull);
  });

  test('levelOf: silencio abajo de −50 dB, 0 dB = 1', () {
    expect(levelOf(-160), 0);
    expect(levelOf(-50), 0);
    expect(levelOf(-25), closeTo(.5, .001));
    expect(levelOf(0), 1);
    expect(levelOf(double.negativeInfinity), 0);
  });

  test('downsample promedia por tramo y estira si hay pocas muestras', () {
    expect(downsample([0, 1, 0, 1], 2), [.5, .5]);
    expect(downsample([.4], 3), [.4, .4, .4]);
    expect(downsample([], 2), [0, 0]);
  });

  test('formato de duración y velocidades', () {
    expect(formatVoiceDuration(const Duration(seconds: 65)), '1:05');
    expect(formatVoiceDuration(const Duration(seconds: 7)), '0:07');
    expect(nextSpeed(1), 1.5);
    expect(nextSpeed(1.5), 2);
    expect(nextSpeed(2), 1);
  });
}
