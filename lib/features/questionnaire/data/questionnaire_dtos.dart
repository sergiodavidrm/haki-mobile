// GET /questionnaires/me → { pending: [...], schedule: [...] }
// Pendientes = envíos sin responder (no vencen), con las preguntas actuales.
// Schedule = semanales asignados, para programar el aviso local de las 20:00.

enum AnswerType {
  text,
  scale,
  yesNo;

  static AnswerType parse(String v) => switch (v) {
    'scale' => scale,
    'yes_no' => yesNo,
    _ => text,
  };
}

class QuestionDto {
  const QuestionDto({
    required this.id,
    required this.text,
    required this.answerType,
    required this.required,
    required this.askDetail,
  });

  final String id;
  final String text;
  final AnswerType answerType;
  final bool required;

  /// Sí/No: pide detalle si responde Sí
  final bool askDetail;

  factory QuestionDto.fromJson(Map<String, dynamic> j) => QuestionDto(
    id: j['id'] as String,
    text: j['text'] as String,
    answerType: AnswerType.parse(j['answerType'] as String),
    required: j['required'] as bool? ?? true,
    askDetail: j['askDetail'] as bool? ?? false,
  );
}

class SectionDto {
  const SectionDto({required this.title, required this.questions});

  /// Opcional: sin título no se muestra encabezado
  final String? title;
  final List<QuestionDto> questions;

  factory SectionDto.fromJson(Map<String, dynamic> j) => SectionDto(
    title: j['title'] as String?,
    questions: [
      for (final q in j['questions'] as List<dynamic>? ?? const [])
        QuestionDto.fromJson(q as Map<String, dynamic>),
    ],
  );
}

class PendingQuestionnaire {
  const PendingQuestionnaire({
    required this.responseId,
    required this.questionnaireId,
    required this.name,
    required this.isInitial,
    required this.periodStart,
    required this.sections,
  });

  final String responseId;
  final String questionnaireId;
  final String name;
  final bool isInitial;

  /// Día de envío (fecha local del coach)
  final DateTime periodStart;
  final List<SectionDto> sections;

  Iterable<QuestionDto> get questions => sections.expand((s) => s.questions);

  factory PendingQuestionnaire.fromJson(Map<String, dynamic> j) =>
      PendingQuestionnaire(
        responseId: j['responseId'] as String,
        questionnaireId: j['questionnaireId'] as String,
        name: j['name'] as String,
        isInitial: j['kind'] == 'initial',
        periodStart: DateTime.parse(j['periodStart'] as String),
        sections: [
          for (final s in j['sections'] as List<dynamic>? ?? const [])
            SectionDto.fromJson(s as Map<String, dynamic>),
        ],
      );
}

class WeeklySchedule {
  const WeeklySchedule({required this.name, required this.weekday});

  final String name;

  /// 1 = lunes … 7 = domingo (igual que DateTime.weekday)
  final int weekday;

  factory WeeklySchedule.fromJson(Map<String, dynamic> j) => WeeklySchedule(
    name: j['name'] as String,
    weekday: j['sendWeekday'] as int,
  );
}

class AthleteQuestionnaires {
  const AthleteQuestionnaires({required this.pending, required this.schedule});

  final List<PendingQuestionnaire> pending;
  final List<WeeklySchedule> schedule;

  factory AthleteQuestionnaires.fromJson(Map<String, dynamic> j) =>
      AthleteQuestionnaires(
        pending: [
          for (final p in j['pending'] as List<dynamic>? ?? const [])
            PendingQuestionnaire.fromJson(p as Map<String, dynamic>),
        ],
        schedule: [
          for (final s in j['schedule'] as List<dynamic>? ?? const [])
            WeeklySchedule.fromJson(s as Map<String, dynamic>),
        ],
      );
}

/// Respuesta a una pregunta (solo se completa el campo de su tipo).
class AnswerInput {
  const AnswerInput({this.text, this.scale, this.yesNo, this.detail});

  final String? text;
  final int? scale;
  final bool? yesNo;
  final String? detail;

  bool get isEmpty =>
      (text == null || text!.trim().isEmpty) && scale == null && yesNo == null;

  AnswerInput copyWith({
    String? text,
    int? scale,
    bool? yesNo,
    String? detail,
  }) => AnswerInput(
    text: text ?? this.text,
    scale: scale ?? this.scale,
    yesNo: yesNo ?? this.yesNo,
    detail: detail ?? this.detail,
  );
}
