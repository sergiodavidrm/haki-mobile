import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/agenda/data/agenda_dtos.dart';

MyAgendaEvent ev(String id, DateTime start, DateTime end) => MyAgendaEvent(
  id: id,
  kind: 'in_person',
  title: id,
  startsAt: start,
  endsAt: end,
  coachName: 'Andrés Solano',
);

void main() {
  test('eventsOn: los del día, por hora, incluido uno que cruza medianoche', () {
    final events = [
      ev('b', DateTime(2026, 11, 13, 18), DateTime(2026, 11, 13, 19)),
      ev('a', DateTime(2026, 11, 13, 6), DateTime(2026, 11, 13, 7)),
      ev('otro', DateTime(2026, 11, 14, 6), DateTime(2026, 11, 14, 7)),
      ev('noche', DateTime(2026, 11, 12, 23), DateTime(2026, 11, 13, 0, 30)),
      ev('fin', DateTime(2026, 11, 12, 23), DateTime(2026, 11, 13)),
    ];
    expect(
      eventsOn(events, DateTime(2026, 11, 13, 15)).map((e) => e.id),
      ['noche', 'a', 'b'],
    );
  });

  test('fromJson pasa a hora local y vacíos a null', () {
    final e = MyAgendaEvent.fromJson({
      'id': 'x',
      'kind': 'virtual',
      'title': 'Sesión',
      'startsAt': '2026-11-13T12:00:00Z',
      'endsAt': '2026-11-13T13:00:00Z',
      'coachName': 'Andrés Solano',
      'location': '  ',
      'meetingUrl': 'meet.google.com/abc',
      'cancelled': false,
      'declinedAt': null,
    });
    expect(e.isVirtual, isTrue);
    expect(e.location, isNull);
    expect(e.startsAt.isUtc, isFalse);
    expect(e.coachFirstName, 'Andrés');
  });

  test('meetingUri agrega https y rechaza otros esquemas', () {
    expect(meetingUri('meet.google.com/abc').toString(), 'https://meet.google.com/abc');
    expect(meetingUri('https://zoom.us/j/1')?.host, 'zoom.us');
    expect(meetingUri('javascript:alert(1)'), isNull);
    expect(meetingUri('ftp://x.com'), isNull);
  });

  test('directionsUri arma la búsqueda de Maps', () {
    final uri = directionsUri('Gym Escazú');
    expect(uri.host, 'www.google.com');
    expect(uri.queryParameters['query'], 'Gym Escazú');
  });

  test('agendaRange entra en los 62 días de la API', () {
    final (from, to) = agendaRange(DateTime(2026, 11, 11, 15));
    expect(from, DateTime(2026, 11, 4));
    expect(to.difference(from).inDays, lessThanOrEqualTo(62));
  });
}
