abstract class Topic<Answer> {
  const Topic({required this.question, required this.answer});

  final String question;
  final Answer answer;
}

class TrueOrFalseTopic extends Topic<bool> {
  const TrueOrFalseTopic({required super.question, required super.answer});
}

class ShortAnswerTopic extends Topic<String> {
  const ShortAnswerTopic({required super.question, required super.answer});
}

abstract class MultipleChoiceTopic<Answer> extends Topic<Answer> {
  const MultipleChoiceTopic(
      {required super.question, required super.answer, required this.options});

  final List<String> options;
}

class SingleAnswerMultipleChoiceTopic extends MultipleChoiceTopic<int> {
  const SingleAnswerMultipleChoiceTopic(
      {required super.question, required super.options, required super.answer});
}

class MultipleAnswerMultipleChoiceTopic extends MultipleChoiceTopic {
  const MultipleAnswerMultipleChoiceTopic(
      {required super.question, required super.options, required super.answer});
}
