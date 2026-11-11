// Campana de avisos (`GET inbox/me`). Ver haki-api/CLAUDE.md § Campana.

class InboxItem {
  const InboxItem({
    required this.id,
    required this.kind,
    required this.data,
    required this.createdAt,
    required this.read,
    this.eventId,
  });

  final String id;

  /// event_invited | event_changed | event_cancelled | payment_reminder
  final String kind;
  final String? eventId;

  /// Mismos datos que el push (el texto se arma con `hakiPushText`).
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool read;

  /// Para `hakiPushText`, que lee el tipo de `type` como en el push.
  Map<String, dynamic> get pushData => {...data, 'type': kind};

  InboxItem markRead() => InboxItem(
    id: id,
    kind: kind,
    data: data,
    createdAt: createdAt,
    read: true,
    eventId: eventId,
  );

  factory InboxItem.fromJson(Map<String, dynamic> j) => InboxItem(
    id: j['id'] as String,
    kind: j['kind'] as String,
    eventId: j['eventId'] as String?,
    data: (j['data'] as Map?)?.cast<String, dynamic>() ?? const {},
    createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
    read: j['read'] as bool? ?? false,
  );
}

class Inbox {
  const Inbox({required this.items, required this.unread});

  final List<InboxItem> items;
  final int unread;

  static const empty = Inbox(items: [], unread: 0);

  /// Marca leídos en el teléfono (ids null = todos) sin esperar a la API.
  Inbox markRead([Set<String>? ids]) {
    final next = [
      for (final i in items)
        if (!i.read && (ids == null || ids.contains(i.id))) i.markRead() else i,
    ];
    return Inbox(items: next, unread: next.where((i) => !i.read).length);
  }

  factory Inbox.fromJson(Map<String, dynamic> j) => Inbox(
    items: [
      for (final e in j['items'] as List? ?? const [])
        InboxItem.fromJson(e as Map<String, dynamic>),
    ],
    unread: j['unread'] as int? ?? 0,
  );
}
