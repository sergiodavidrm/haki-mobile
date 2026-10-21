import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/units/weight_unit.dart';
import 'package:haki_mobile/features/chat/data/chat_message.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

void main() {
  test('VideoCard.of: tarjeta de la API con videos ordenados por serie', () {
    final m = Message(
      text: 'Me costó la pausa',
      extraData: const {
        'exerciseName': 'Jalón vertical',
        'weekNumber': 2,
        'dayNumber': 3,
      },
      attachments: [
        Attachment(
          type: 'video',
          assetUrl: 'https://res.cloudinary.com/x/video/upload/v1/s4.mp4',
          extraData: const {'setNumber': 4, 'weight': 52.6, 'reps': 12},
        ),
        Attachment(
          type: 'video',
          assetUrl: 'https://res.cloudinary.com/x/video/upload/v1/s3.mp4',
          extraData: const {
            'setNumber': 3,
            'weight': 52.6,
            'reps': 12,
            'rir': 1,
          },
        ),
      ],
    );
    final card = VideoCard.of(m)!;
    expect(card.exerciseName, 'Jalón vertical');
    expect(card.dayLabel, 'Sem 2 · Día 3');
    expect(card.note, 'Me costó la pausa');
    expect(card.videos.map((v) => v.setNumber), [3, 4]);
    expect(card.videos.first.label(WeightUnit.lb), '116 lb × 12 · RIR 1');
    expect(card.videos.last.label(WeightUnit.kg), '52.6 kg × 12');
  });

  test('VideoCard.of: un mensaje común no es tarjeta', () {
    expect(VideoCard.of(Message(text: 'Hola')), isNull);
  });

  test('cloudinaryThumb', () {
    expect(
      cloudinaryThumb(
        'https://res.cloudinary.com/dpsomxin7/video/upload/v17/haki/sets/abc.mp4',
      ),
      'https://res.cloudinary.com/dpsomxin7/video/upload/v17/haki/sets/abc.jpg',
    );
    expect(cloudinaryThumb('https://example.com/a.mp4'), isNull);
  });

  test('daySeparator', () {
    final now = DateTime(2026, 10, 20, 18);
    expect(daySeparator(DateTime(2026, 10, 20, 8), now), 'Hoy');
    expect(daySeparator(DateTime(2026, 10, 19, 23), now), 'Ayer');
    expect(daySeparator(DateTime(2026, 9, 25), now), '25 sep');
    expect(daySeparator(DateTime(2025, 12, 31), now), '31 dic 2025');
  });
}
