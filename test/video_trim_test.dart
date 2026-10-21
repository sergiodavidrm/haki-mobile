import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/session/data/video_trim.dart';

void main() {
  test('initial: video entero o los primeros 90 s', () {
    final short = TrimRange.initial(35400);
    expect((short.startMs, short.endMs), (0, 35400));
    final long = TrimRange.initial(150000);
    expect((long.startMs, long.endMs), (0, 90000));
  });

  test('withStart: de a 1 s, deja mínimo 1 s y máximo 90', () {
    const r = TrimRange(0, 30000);
    expect(r.withStart(12400).startMs, 12000);
    expect(r.withStart(29900).startMs, 29000);
    expect(r.withStart(-500).startMs, 0);
    expect(const TrimRange(0, 120000).withStart(10000).startMs, 30000);
  });

  test('withEnd: de a 1 s, el final exacto y máximo 90', () {
    const r = TrimRange(10000, 20000);
    expect(r.withEnd(25600, 35400).endMs, 26000);
    expect(r.withEnd(40000, 35400).endMs, 35400);
    expect(r.withEnd(10200, 35400).endMs, 11000);
    expect(const TrimRange(0, 10000).withEnd(200000, 150000).endMs, 90000);
  });

  test('isWhole', () {
    expect(const TrimRange(0, 35400).isWhole(35400), isTrue);
    expect(const TrimRange(1000, 35400).isWhole(35400), isFalse);
  });

  test('compressTrimArgs: iOS duración del tramo, Android corte del final', () {
    const r = TrimRange(12000, 47000);
    expect(compressTrimArgs(r, 60000, android: false), (
      start: 12,
      duration: 35,
    ));
    expect(compressTrimArgs(r, 60000, android: true), (
      start: 12,
      duration: 13,
    ));
    // fin = final exacto: en Android no se corta nada del final
    expect(
      compressTrimArgs(const TrimRange(5000, 35400), 35400, android: true),
      (start: 5, duration: 0),
    );
  });

  test('clockOf', () {
    expect(clockOf(65000), '1:05');
    expect(clockOf(9000), '0:09');
  });
}
