import 'package:flutter/cupertino.dart';

enum QuestionTypes {
  multipleChoice,
  trueOrFalse, // specified multipleChoice question
  blankFilling,
  shortAsk,
}

enum AnswerTypes {
  unique,
  multiple,
}

enum TopicTypes {
  single,
  multiple,
  judge,
  blank,
  ask,
}

@immutable
class Topic {
  const Topic({
    required this.question,
    required this.questionType,
    required this.answerType,
    this.multipleChoiceAnswerList,
    this.multipleChoiceOptions,
    this.blankFillingAnswerList,
    this.shortAskAnswer,
  });

  final String question;
  final QuestionTypes questionType;
  final AnswerTypes answerType;
  final List<bool>? multipleChoiceAnswerList;
  final List<String>? multipleChoiceOptions;
  final List<String>? blankFillingAnswerList;
  final String? shortAskAnswer;

  TopicTypes get topicType {
    switch (questionType) {
      case QuestionTypes.multipleChoice:
        if (answerType == AnswerTypes.unique) {
          return TopicTypes.single;
        } else {
          return TopicTypes.multiple;
        }
      case QuestionTypes.trueOrFalse:
        return TopicTypes.judge;
      case QuestionTypes.blankFilling:
        return TopicTypes.blank;
      case QuestionTypes.shortAsk:
        return TopicTypes.ask;
    }
  }
}

class Result {
  Result(Topic topic, {required this.topicIndex}) {
    switch (topic.topicType) {
      case TopicTypes.single:
      case TopicTypes.multiple:
      case TopicTypes.judge:
        _multipleChoiceResultList =
            List<bool>.filled(topic.multipleChoiceAnswerList!.length, false);
        break;
      case TopicTypes.blank:
        _blankFillingResultList =
            List<String>.filled(topic.blankFillingAnswerList!.length, '');
        break;
      case TopicTypes.ask:
        _shortAskResult = '';
        break;
    }
  }

  final int topicIndex;
  List<bool>? _multipleChoiceResultList;
  List<String>? _blankFillingResultList;
  String? _shortAskResult;

  List<bool> get multipleChoiceResultList => _multipleChoiceResultList!;

  List<String> get blankFillingResultList => _blankFillingResultList!;

  String get shortAskResult => _shortAskResult!;

  void toggleAt(int index) {
    if (index >= _multipleChoiceResultList!.length) {
      throw IndexError.withLength(
        index,
        _multipleChoiceResultList!.length,
        indexable: _multipleChoiceResultList,
      );
    } else {
      _multipleChoiceResultList![index] =
          !_multipleChoiceResultList!.elementAt(index);
    }
  }

  void changeAt(int index, String newResult) {
    if (index >= _blankFillingResultList!.length) {
      throw IndexError.withLength(
        index,
        _blankFillingResultList!.length,
        indexable: _blankFillingResultList,
      );
    } else {
      _blankFillingResultList![index] = newResult;
    }
  }

  void change(String newResult) {
    _shortAskResult = newResult;
  }
}
