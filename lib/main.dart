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
}

class TopicModel extends ChangeNotifier {
  final List<Topic> topics = [];

  Topic elementAt(int index) {
    return topics.elementAt(index);
  }

  void remove(Topic topic) {
    topics.remove(topic);
    notifyListeners();
  }

  void removeAt(int index) {
    topics.removeAt(index);
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
}

class Result {
  Result({required this.topic}) {
    if (topic.multipleChoiceAnswerList != null) {
      _multipleChoiceResultList =
          List<bool>.filled(topic.multipleChoiceAnswerList!.length, false);
    } else if (topic.blankFillingAnswerList != null) {
      _blankFillingResultList =
          List<String>.filled(topic.blankFillingAnswerList!.length, '');
    } else if (topic.shortAskAnswer != null) {
      _shortAskResult = '';
    }
  }

  final Topic topic;
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

class QuizModel extends ChangeNotifier {
  QuizModel({required this.topic}) : result = Result(topic: topic);

  final Topic topic;
  late Result result;
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
        Provider(create: (context) => null),
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
