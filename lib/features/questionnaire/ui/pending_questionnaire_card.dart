import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../l10n/l10n.dart';
import '../data/questionnaire_dtos.dart';

/// Tarjeta de Hoy: un cuestionario sin responder (queda hasta que lo envía).
class PendingQuestionnaireCard extends StatelessWidget {
  const PendingQuestionnaireCard({super.key, required this.questionnaire});

  final PendingQuestionnaire questionnaire;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    void open() => context.push(Routes.questionnaire(questionnaire.responseId));

    return Semantics(
      button: true,
      label: '${questionnaire.name}. ${l.questionnaireAnswer}',
      excludeSemantics: true,
      child: HakiCard(
        onTap: open,
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.goldSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 20,
                color: c.goldBright,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questionnaire.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l.questionnairePendingSince(
                      formatShortDate(questionnaire.periodStart),
                    ),
                    style: TextStyle(fontSize: 12, color: c.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: open,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l.questionnaireAnswer),
            ),
          ],
        ),
      ),
    );
  }
}
