import 'package:custom_quiz/screens/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

import 'common/utils.dart';

abstract class Question {
  String get subject;

  Iterable<String> get hints;

  String get details;
}

@immutable
class MultipleChoiceQuestion implements Question {
  const MultipleChoiceQuestion(
      {required String subject, required Iterable<String> options})
      : _subject = subject,
        _options = options;

  final String _subject;
  final Iterable<String> _options;

  @override
  String get details => '';

  @override
  Iterable<String> get hints => _options;

  @override
  String get subject => _subject;
}

@immutable
class TrueOrFalseQuestion implements Question {
  const TrueOrFalseQuestion({required String subject}) : _subject = subject;

  final String _subject;

  @override
  String get details => '';

  @override
  Iterable<String> get hints => const ['False', 'True'];

  @override
  String get subject => _subject;
}

@immutable
class BlankFillingQuestion implements Question {
  const BlankFillingQuestion(
      {required String subject, required Iterable<String> contexts})
      : _subject = subject,
        _contexts = contexts;

  final String _subject;
  final Iterable<String> _contexts;

  @override
  String get details => '';

  @override
  Iterable<String> get hints => _contexts;

  @override
  String get subject => _subject;
}

@immutable
class ShortAskQuestion implements Question {
  const ShortAskQuestion(
      {required String subject,
      Iterable<String> details = const Iterable.empty()})
      : _subject = subject,
        _details = details;

  final String _subject;
  final Iterable<String> _details;

  @override
  String get details => _details.join('\n');

  @override
  Iterable<String> get hints => const Iterable.empty();

  @override
  String get subject => _subject;
}

abstract class Answer extends Comparable<Answer> {
  String get answer;
}

class MultipleChoiceAnswer extends Answer {
  MultipleChoiceAnswer({required List<bool> answer}) : _answerList = answer;

  final List<bool> _answerList;

  @override
  String get answer =>
      _answerList.asMap().entries.map(_toAnswerString).toList().join();

  @override
  int compareTo(Object other) {
    if (other is MultipleChoiceAnswer) {
      return listEquals(_answerList, other._answerList) ? 0 : 1;
    }
    throw TypeError();
  }

  void toggleAt(int index) {
    _answerList[index] = !_answerList[index];
  }

  void setAt(int index) {
    _answerList[index] = true;
  }

  void resetAt(int index) {
    _answerList[index] = false;
  }

  void setAll() {
    _answerList.map((e) => e = true);
  }

  void resetAll() {
    _answerList.map((e) => e = false);
  }

  _toAnswerString(MapEntry<int, bool> e) {
    if (e.value) {
      return indexToUppercaseAlphabet(e.key);
    }
  }
}

class BlankFillingAnswer extends Answer {
  BlankFillingAnswer({required List<String> blankAnswer})
      : _blankAnswer = blankAnswer;

  final List<String> _blankAnswer;

  @override
  String get answer => _blankAnswer.join(';');

  @override
  int compareTo(Object other) {
    if (other is BlankFillingAnswer) {
      if (_blankAnswer.length != other._blankAnswer.length) {
        throw Exception('Length of two answers not equal');
      }
      return listEquals(_blankAnswer, other._blankAnswer) ? 0 : 1;
    }
    throw TypeError();
  }
}

class ShortAskAnswer extends Answer {
  ShortAskAnswer.string({required String multilineAnswer})
      : _multilineAnswer =
            multilineAnswer.split('\n').map((e) => e.trim()).toList();

  ShortAskAnswer.list({required List<String> answer})
      : _multilineAnswer = answer;

  List<String> _multilineAnswer;

  set answerByList(List<String> newAnswer) {
    _multilineAnswer = newAnswer;
  }

  set answerByString(String newMultilineAnswer) {
    _multilineAnswer =
        newMultilineAnswer.split('\n').map((e) => e.trim()).toList();
  }

  @override
  String get answer => _multilineAnswer.join('\n');

  @override
  int compareTo(Object other) {
    if (other is ShortAskAnswer) {
      var a = removeNonPrintable(answer).trim();
      var b = removeNonPrintable(other.answer).trim();
      return a == b ? 0 : 1;
    }
    throw TypeError();
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
