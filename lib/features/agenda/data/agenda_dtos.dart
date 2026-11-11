// Agenda del coach vista por el atleta (`GET agenda/me`). Ver
// `haki-api/CLAUDE.md` § Agenda.

class MyAgendaEvent {
  const MyAgendaEvent({
    required this.id,
    required this.kind,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.coachName,
    this.location,
    this.meetingUrl,
    this.note,
    this.cancelled = false,
    this.declinedAt,
    this.declineReason,
    this.confirmedAt,
  });

  final String id;

  /// in_person | virtual (los bloqueos del coach no le llegan al atleta).
  final String kind;
  final String title;

  /// En hora local del teléfono.
  final DateTime startsAt;
  final DateTime endsAt;
  final String coachName;
  final String? location;
  final String? meetingUrl;
  final String? note;
  final bool cancelled;
  final DateTime? declinedAt;
  final String? declineReason;

  /// "Voy" (fase 2); excluyente con [declinedAt]
  final DateTime? confirmedAt;

  bool get isVirtual => kind == 'virtual';
  bool get declined => declinedAt != null;
  bool get confirmed => confirmedAt != null;

  /// Ya terminó: sin "No puedo ir" (la API tampoco lo deja).
  bool endedAt(DateTime now) => !endsAt.isAfter(now);

  String get coachFirstName {
    final name = coachName.trim();
    return name.isEmpty ? name : name.split(RegExp(r'\s+')).first;
  }

  factory MyAgendaEvent.fromJson(Map<String, dynamic> j) => MyAgendaEvent(
    id: j['id'] as String,
    kind: j['kind'] as String? ?? 'in_person',
    title: j['title'] as String? ?? '',
    startsAt: DateTime.parse(j['startsAt'] as String).toLocal(),
    endsAt: DateTime.parse(j['endsAt'] as String).toLocal(),
    coachName: j['coachName'] as String? ?? '',
    location: _text(j['location']),
    meetingUrl: _text(j['meetingUrl']),
    note: _text(j['note']),
    cancelled: j['cancelled'] as bool? ?? false,
    declinedAt: j['declinedAt'] == null
        ? null
        : DateTime.parse(j['declinedAt'] as String).toLocal(),
    declineReason: _text(j['declineReason']),
    confirmedAt: j['confirmedAt'] == null
        ? null
        : DateTime.parse(j['confirmedAt'] as String).toLocal(),
  );
}

String? _text(Object? v) {
  final s = (v as String?)?.trim();
  return s == null || s.isEmpty ? null : s;
}

/// Eventos que tocan [day] (hora local), por hora de inicio.
List<MyAgendaEvent> eventsOn(List<MyAgendaEvent> events, DateTime day) {
  final start = DateTime(day.year, day.month, day.day);
  final end = start.add(const Duration(days: 1));
  return events
      .where((e) => e.startsAt.isBefore(end) && e.endsAt.isAfter(start))
      .toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
}

/// Rango que pide la app: la semana pasada y las 5 que vienen (la tira de Hoy
/// se mueve por semanas). La API acepta hasta 62 días.
(DateTime, DateTime) agendaRange(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return (
    today.subtract(const Duration(days: 7)),
    today.add(const Duration(days: 36)),
  );
}

/// Link de Google Maps para "Cómo llegar" (abre la app de mapas si está).
Uri directionsUri(String location) => Uri.https('www.google.com', '/maps/search/', {
  'api': '1',
  'query': location,
});

/// Link de la reunión virtual; sin esquema se asume https. null = inválido.
Uri? meetingUri(String url) {
  final raw = url.contains('://') ? url : 'https://$url';
  final uri = Uri.tryParse(raw);
  if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) {
    return null;
  }
  return uri.host.isEmpty ? null : uri;
}
