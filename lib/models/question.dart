enum QuestionType {
  singleChoice,
  multiChoice,
  scale1to5,
  nps0to10,
  openText,
}

class Question {
  final String id;
  final String section;
  final String text;
  final QuestionType type;
  final List<String> options;
  final String? lowLabel;
  final String? highLabel;

  const Question({
    required this.id,
    required this.section,
    required this.text,
    required this.type,
    this.options = const [],
    this.lowLabel,
    this.highLabel,
  });
}
