import 'package:flutter_test/flutter_test.dart';
import 'package:haki_mobile/features/questionnaire/data/questionnaire_dtos.dart';

PendingQuestionnaire sentOn(DateTime d) => PendingQuestionnaire(
  responseId: 'r',
  questionnaireId: 'q',
  name: 'Semanal',
  isInitial: false,
  periodStart: d,
  sections: const [],
);

void main() {
  test(
    'pendingOn: el del viernes sale ese día y los siguientes, no el jueves',
    () {
      final friday = sentOn(DateTime(2026, 10, 30));
      expect(pendingOn([friday], DateTime(2026, 10, 29)), isEmpty);
      expect(pendingOn([friday], DateTime(2026, 10, 30, 9)), hasLength(1));
      expect(pendingOn([friday], DateTime(2026, 10, 31)), hasLength(1));
    },
  );
}
