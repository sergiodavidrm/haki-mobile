import '../../../core/format/dates.dart';
import '../../../core/units/weight_unit.dart';
import '../../../l10n/l10n.dart';

// Textos de los stickers (números con el separador del idioma).

bool get _en => appLocale.languageCode == 'en';

String _group(int n) {
  final s = n.abs().toString();
  final b = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(_en ? ',' : ' ');
    b.write(s[i]);
  }
  return b.toString();
}

String _decimal(double v) {
  final s = v.toStringAsFixed(1);
  final t = s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  return _en ? t : t.replaceAll('.', ',');
}

/// "142 kg"
String stickerWeight(double kg, WeightUnit unit) =>
    '${_en ? formatWeight(unit.fromKg(kg)) : formatWeight(unit.fromKg(kg)).replaceAll('.', ',')} ${unit.label}';

/// "9 480 kg"; desde 10 t en kg, "38,2 t"
String stickerVolume(double kg, WeightUnit unit) {
  final v = unit.fromKg(kg);
  if (unit == WeightUnit.kg && v >= 10000) return '${_decimal(v / 1000)} t';
  return '${_group(v.round())} ${unit.label}';
}

/// "1 h 2 min" / "45 min"
String stickerDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return h == 0 ? '$m min' : (m == 0 ? '$h h' : '$h h $m min');
}

/// Series por músculo (los secundarios suman ½): "9" / "4,5"
String stickerSets(double v) =>
    v == v.roundToDouble() ? v.round().toString() : _decimal(v);

/// "↑ 4" / "↓ 2" / "= igual"
String stickerDelta(num now, num before, String Function(num) fmt) {
  final d = now - before;
  if (d.abs() < 0.0001) return l10n.shareSame;
  return '${d > 0 ? '↑' : '↓'} ${fmt(d.abs())}';
}

/// "↑ 6 %"
String stickerPercent(double change) {
  final p = (change * 100).round();
  if (p == 0) return l10n.shareSame;
  return '${p > 0 ? '↑' : '↓'} ${p.abs()} %';
}

/// "9 – 15 nov" / "30 oct – 5 nov"
String stickerWeekRange(DateTime monday) {
  final sunday = monday.add(const Duration(days: 6));
  if (monday.month == sunday.month) {
    return _en
        ? '${formatDayMonth(monday)} – ${sunday.day}'
        : '${monday.day} – ${formatDayMonth(sunday)}';
  }
  return '${formatDayMonth(monday)} – ${formatDayMonth(sunday)}';
}
