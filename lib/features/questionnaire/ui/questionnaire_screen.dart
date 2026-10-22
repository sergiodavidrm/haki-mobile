import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/haki_colors.dart';
import '../../../core/widgets/haki_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../l10n/l10n.dart';
import '../../auth/providers/auth_me_provider.dart';
import '../data/questionnaire_dtos.dart';
import '../providers/questionnaire_providers.dart';

// Responder un cuestionario (pantalla completa, mockup "Cuestionario"):
// secciones con sus preguntas (Escala 1–5, Sí/No con detalle, Texto). El botón
// se habilita cuando están todas las obligatorias.
class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key, required this.responseId});

  final String responseId;

  @override
  ConsumerState<QuestionnaireScreen> createState() =>
      _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  final _answers = <String, AnswerInput>{};
  final _texts = <String, TextEditingController>{};

  TextEditingController _text(String key) =>
      _texts.putIfAbsent(key, TextEditingController.new);

  @override
  void dispose() {
    for (final t in _texts.values) {
      t.dispose();
    }
    super.dispose();
  }

  AnswerInput _answer(String id) => _answers[id] ?? const AnswerInput();

  void _set(String id, AnswerInput a) => setState(() => _answers[id] = a);

  /// Respuestas con los textos al día (los TextField no pasan por setState).
  Map<String, AnswerInput> _collect(PendingQuestionnaire q) => {
    for (final x in q.questions)
      x.id: switch (x.answerType) {
        AnswerType.text => AnswerInput(text: _text(x.id).text),
        AnswerType.yesNo => _answer(
          x.id,
        ).copyWith(detail: _text('${x.id}:detail').text),
        AnswerType.scale => _answer(x.id),
      },
  };

  bool _complete(PendingQuestionnaire q) {
    final all = _collect(q);
    return q.questions.every((x) => !x.required || !all[x.id]!.isEmpty);
  }

  Future<void> _submit(PendingQuestionnaire q) async {
    final ok = await ref
        .read(questionnaireSubmitterProvider.notifier)
        .submit(q.responseId, _collect(q));
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      context.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.questionnaireSent)),
      );
    } else {
      final error = ref.read(questionnaireSubmitterProvider).error;
      messenger.showSnackBar(
        SnackBar(content: Text(apiErrorMessage(error ?? 'error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final q = ref.watch(pendingQuestionnaireProvider(widget.responseId));
    final sending = ref.watch(questionnaireSubmitterProvider).isLoading;
    final coach = ref.watch(authMeProvider).value?.coachName;
    final coachFirst = coach?.split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l.commonClose,
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.close, color: c.text),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q?.name ?? l.questionnaireTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            color: c.text,
                          ),
                        ),
                        if (q != null)
                          Text(
                            l.questionnaireSentOn(
                              formatShortDate(q.periodStart),
                            ),
                            style: TextStyle(fontSize: 12, color: c.textMuted),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (q == null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l.questionnaireNotFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: c.textMuted),
                    ),
                  ),
                ),
              )
            else ...[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    if (coachFirst != null)
                      HakiCard(
                        tone: HakiCardTone.turquoise,
                        radius: 14,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(
                          l.questionnaireIntro(coachFirst),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: c.text,
                          ),
                        ),
                      ),
                    for (final s in q.sections) ...[
                      if (s.title != null) ...[
                        const SizedBox(height: 18),
                        SectionLabel(s.title!),
                      ],
                      for (final x in s.questions) ...[
                        const SizedBox(height: 12),
                        _QuestionCard(
                          question: x,
                          answer: _answer(x.id),
                          onChanged: (a) => _set(x.id, a),
                          text: _text(x.id),
                          detail: _text('${x.id}:detail'),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: c.surfaceHigh)),
                ),
                child: ListenableBuilder(
                  listenable: Listenable.merge(_texts.values.toList()),
                  builder: (_, _) => FilledButton(
                    onPressed: sending || !_complete(q)
                        ? null
                        : () => _submit(q),
                    child: Text(
                      sending
                          ? l.commonSending
                          : coachFirst == null
                          ? l.questionnaireSend
                          : l.questionnaireSendTo(coachFirst),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.answer,
    required this.onChanged,
    required this.text,
    required this.detail,
  });

  final QuestionDto question;
  final AnswerInput answer;
  final ValueChanged<AnswerInput> onChanged;
  final TextEditingController text;
  final TextEditingController detail;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return HakiCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: question.text,
              children: [
                if (!question.required)
                  TextSpan(
                    text: '  ${l.commonOptional}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.textMuted,
                    ),
                  ),
              ],
            ),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
          const SizedBox(height: 10),
          switch (question.answerType) {
            AnswerType.scale => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    for (var n = 1; n <= 5; n++) ...[
                      if (n > 1) const SizedBox(width: 6),
                      Expanded(
                        child: _Choice(
                          label: '$n',
                          selected: answer.scale == n,
                          onTap: () => onChanged(AnswerInput(scale: n)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l.questionnaireWorst,
                      style: TextStyle(fontSize: 11, color: c.textMuted),
                    ),
                    Text(
                      l.questionnaireBest,
                      style: TextStyle(fontSize: 11, color: c.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            AnswerType.yesNo => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Choice(
                        label: l.commonNo,
                        selected: answer.yesNo == false,
                        onTap: () => onChanged(const AnswerInput(yesNo: false)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Choice(
                        label: l.commonYes,
                        selected: answer.yesNo == true,
                        onTap: () => onChanged(const AnswerInput(yesNo: true)),
                      ),
                    ),
                  ],
                ),
                if (question.askDetail && answer.yesNo == true) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: detail,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      hintText: l.questionnaireDetailHint,
                      counterText: '',
                    ),
                  ),
                ],
              ],
            ),
            AnswerType.text => TextField(
              controller: text,
              minLines: 3,
              maxLines: 6,
              maxLength: 2000,
              decoration: InputDecoration(
                hintText: l.questionnaireTextHint,
                counterText: '',
              ),
            ),
          },
        ],
      ),
    );
  }
}

/// Botón de opción (número de la escala, Sí/No): dorado si está elegido.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? c.goldSurface : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? c.gold : c.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? c.goldBright : c.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
