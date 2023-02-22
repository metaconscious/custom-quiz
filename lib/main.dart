import 'package:custom_quiz/screens/home.dart';
import 'package:custom_quiz/screens/quiz.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

class TopicModel extends ChangeNotifier {
  final List<Topic> topics = [];

  Topic elementAt(int index) {
    return topics.elementAt(index);
  }

  int indexOf(Topic topic) {
    return topics.indexOf(topic);
  }

  void remove(Topic topic) {
    topics.remove(topic);
    notifyListeners();
  }

  void removeAt(int index) {
    topics.removeAt(index);
    notifyListeners();
  }

  void clear() {
    topics.clear();
    notifyListeners();
  }

  void add(Topic newTopic) {
    topics.add(newTopic);
    notifyListeners();
  }

  void addAll(Iterable<Topic> newTopics) {
    topics.addAll(newTopics);
    notifyListeners();
  }

  List<Topic> getAllByTopicType(TopicTypes topicType) {
    return topics.expand((e) => [if (e.topicType == topicType) e]).toList();
  }

  List<Topic> getAllByQuestionType(QuestionTypes questionType) {
    return topics
        .expand((e) => [if (e.questionType == questionType) e])
        .toList();
  }

  List<Topic> getAllByAnswerType(AnswerTypes answerType) {
    return topics.expand((e) => [if (e.answerType == answerType) e]).toList();
  }
}

class TopicSetModel extends ChangeNotifier {
  late final TopicModel topicModel;

  final List<int> _indexes = [];

  List<int> get indexes => _indexes;

  void add(int index) {
    _indexes.add(index);
    notifyListeners();
  }

  void addAll(Iterable<int> indexes) {
    _indexes.addAll(indexes);
    notifyListeners();
  }

  void remove(int value) {
    _indexes.remove(value);
    notifyListeners();
  }

  void removeAt(int index) {
    _indexes.removeAt(index);
    notifyListeners();
  }

  List<Topic> get topics {
    return _indexes.map((e) => topicModel.elementAt(e)).toList();
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

class ResultModel extends ChangeNotifier {
  late final TopicModel topicModel;

  final List<Result> results = [];

  Result elementAt(int index) {
    return results.elementAt(index);
  }

  int indexOf(Result result) {
    return results.indexOf(result);
  }

  void remove(Result result) {
    results.remove(result);
    notifyListeners();
  }

  void removeAt(int index) {
    results.removeAt(index);
    notifyListeners();
  }

  void clear() {
    results.clear();
    notifyListeners();
  }

  void add(Result newResult) {
    results.add(newResult);
    notifyListeners();
  }

  void addAll(Iterable<Result> newResult) {
    results.addAll(newResult);
    notifyListeners();
  }

  Topic correspondedTopicAt(int index) {
    return topicModel.elementAt(results.elementAt(index).topicIndex);
  }

  Topic correspondedTopicOf(Result result) {
    return topicModel
        .elementAt(results.elementAt(results.indexOf(result)).topicIndex);
  }
}

class ResultSetModel extends ChangeNotifier {
  late final TopicModel topicModel;
  late final ResultModel resultModel;

  final List<int> _indexes = [];

  List<int> get indexes => _indexes;

  void add(int index) {
    _indexes.add(index);
    notifyListeners();
  }

  void addAll(Iterable<int> indexes) {
    _indexes.addAll(indexes);
    notifyListeners();
  }

  void remove(int value) {
    _indexes.remove(value);
    notifyListeners();
  }

  void removeAt(int index) {
    _indexes.removeAt(index);
    notifyListeners();
  }

  List<Result> get results {
    return _indexes.map((e) => resultModel.elementAt(e)).toList();
  }

  List<Topic> get topics {
    return results.map((e) => topicModel.elementAt(e.topicIndex)).toList();
  }
}

void main() {
  runApp(const MyApp());
}

GoRouter router() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const Placeholder(),
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TopicModel()),
        ChangeNotifierProxyProvider<TopicModel, TopicSetModel>(
          create: (context) => TopicSetModel(),
          update: (context, topicModel, topicSetModel) {
            if (topicSetModel == null) {
              throw ArgumentError.notNull('topicSetModel');
            }
            topicSetModel.topicModel = topicModel;
            return topicSetModel;
          },
        ),
        ChangeNotifierProxyProvider<TopicModel, ResultModel>(
          create: (context) => ResultModel(),
          update: (context, topicModel, resultModel) {
            if (resultModel == null) {
              throw ArgumentError.notNull('resultModel');
            }
            resultModel.topicModel = topicModel;
            return resultModel;
          },
        ),
        ChangeNotifierProxyProvider2<TopicModel, ResultModel, ResultSetModel>(
          create: (context) => ResultSetModel(),
          update: (context, topicModel, resultModel, resultSetModel) {
            if (resultSetModel == null) {
              throw ArgumentError.notNull('resultModel');
            }
            resultSetModel.topicModel = topicModel;
            resultSetModel.resultModel = resultModel;
            return resultSetModel;
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Custom Quiz',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerConfig: router(),
      ),
    );
  }
}
