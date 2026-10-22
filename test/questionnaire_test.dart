import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/core/notifications/questionnaire_reminders.dart';
import 'package:haki_mobile/features/questionnaire/data/questionnaire_dtos.dart';

void main() {
  group('QuestionnaireReminders.nextSends', () {
    test('mismo día antes de las 20:00 incluye hoy', () {
      final now = DateTime(2026, 10, 19, 19, 59); // lunes
      final s = QuestionnaireReminders.nextSends(1, now);
      expect(s.first, DateTime(2026, 10, 19, 20));
      expect(s, hasLength(4));
      expect(s.last, DateTime(2026, 11, 9, 20));
    });

    test('mismo día a las 20:00 o después pasa a la semana siguiente', () {
      final s = QuestionnaireReminders.nextSends(1, DateTime(2026, 10, 19, 20));
      expect(s.first, DateTime(2026, 10, 26, 20));
    });

    test('otro día de la semana', () {
      final s = QuestionnaireReminders.nextSends(
        7,
        DateTime(2026, 10, 21, 9),
      ); // miércoles → domingo
      expect(s.first, DateTime(2026, 10, 25, 20));
    });
  });

  test('parsea GET /questionnaires/me', () {
    final q = AthleteQuestionnaires.fromJson({
      'pending': [
        {
          'responseId': 'r1',
          'questionnaireId': 'q1',
          'name': 'Check-in',
          'kind': 'weekly',
          'periodStart': '2026-10-19',
          'sentAt': '2026-10-20T02:00:00Z',
          'sections': [
            {
              'id': 's1',
              'title': null,
              'questions': [
                {
                  'id': 'a',
                  'text': 'Energía',
                  'answerType': 'scale',
                  'required': true,
                  'askDetail': false,
                },
                {
                  'id': 'b',
                  'text': 'Dolor',
                  'answerType': 'yes_no',
                  'required': true,
                  'askDetail': true,
                },
              ],
            },
          ],
        },
      ],
      'schedule': [
        {'questionnaireId': 'q1', 'name': 'Check-in', 'sendWeekday': 1},
      ],
    });
    final p = q.pending.single;
    expect(p.isInitial, isFalse);
    expect(p.periodStart, DateTime(2026, 10, 19));
    expect(p.sections.single.title, isNull);
    expect(p.questions.map((x) => x.answerType), [
      AnswerType.scale,
      AnswerType.yesNo,
    ]);
    expect(q.schedule.single.weekday, 1);
  });

  test('AnswerInput.isEmpty', () {
    expect(const AnswerInput(text: '  ').isEmpty, isTrue);
    expect(const AnswerInput(scale: 3).isEmpty, isFalse);
    expect(const AnswerInput(yesNo: false).isEmpty, isFalse);
  });
}
