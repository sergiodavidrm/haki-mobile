import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/l10n.dart';
import '../theme/haki_colors.dart';

/// Términos, Privacidad y Ayuda publicados en hakifit.com (haki-site). Ayuda
/// abre la guía del atleta (el resto de la ayuda es para el coach).
abstract final class LegalUrls {
  static final terms = Uri.parse('https://hakifit.com/terms');
  static final privacy = Uri.parse('https://hakifit.com/privacy');
  static final help = Uri.parse('https://hakifit.com/docs/app/la-app-del-atleta');
}

/// Abre la página en el navegador del teléfono.
Future<void> openLegal(Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

/// "Términos · Privacidad · Ayuda", chico y gris (Login).
class LegalLinksRow extends StatelessWidget {
  const LegalLinksRow({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final style = TextStyle(color: c.textMuted, fontSize: 12);
    Widget link(String text, Uri uri) => InkWell(
          onTap: () => openLegal(uri),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Text(text, style: style),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        link(l.legalTerms, LegalUrls.terms),
        Text('·', style: style),
        link(l.legalPrivacy, LegalUrls.privacy),
        Text('·', style: style),
        link(l.legalHelp, LegalUrls.help),
      ],
    );
  }
}

/// Texto con los links a Términos y Política de privacidad intercalados:
/// "{before} Términos {middle} Política de privacidad{after}".
class LegalSentence extends StatelessWidget {
  const LegalSentence({
    super.key,
    required this.before,
    required this.middle,
    required this.after,
    this.fontSize = 12,
    this.textAlign = WrapAlignment.center,
    this.color,
  });

  final String before;
  final String middle;
  final String after;
  final double fontSize;
  final WrapAlignment textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final base = TextStyle(color: color ?? c.textMuted, fontSize: fontSize, height: 1.45);
    final linkStyle = base.copyWith(color: c.goldBright, fontWeight: FontWeight.w600);
    Widget link(String text, Uri uri) => GestureDetector(
          onTap: () => openLegal(uri),
          child: Text(text, style: linkStyle),
        );
    // Una palabra por Text para que el Wrap corte línea como un párrafo
    List<Widget> words(String s) => [
          for (final w in s.split(' ').where((w) => w.isNotEmpty)) Text('$w ', style: base),
        ];
    return Wrap(
      alignment: textAlign,
      children: [
        ...words(before),
        link(l.legalTerms, LegalUrls.terms),
        Text(' ', style: base),
        ...words(middle),
        link(l.legalPrivacyPolicy, LegalUrls.privacy),
        Text(after, style: base),
      ],
    );
  }
}
