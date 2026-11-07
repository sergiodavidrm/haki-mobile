import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/exercise/data/exercise_video.dart';

void main() {
  const id = 'dQw4w9WgXcQ';

  test('reconoce las URLs de YouTube', () {
    for (final url in [
      'https://www.youtube.com/watch?v=$id',
      'https://m.youtube.com/watch?v=$id&t=30s',
      'http://youtube.com/watch?v=$id',
      'youtube.com/watch?v=$id',
      'https://youtu.be/$id?si=abc',
      'https://www.youtube.com/shorts/$id',
      'https://www.youtube.com/embed/$id',
      'https://www.youtube.com/live/$id?feature=share',
      '  https://youtu.be/$id  ',
    ]) {
      expect(youtubeIdOf(url), id, reason: url);
    }
  });

  test('otros sitios no son de YouTube', () {
    for (final url in [
      'https://res.cloudinary.com/dpsomxin7/video/upload/v1/haki/x.mp4',
      'https://vimeo.com/123456789',
      'https://www.instagram.com/reel/abc/',
      '',
    ]) {
      expect(youtubeIdOf(url), isNull, reason: url);
    }
  });
}
