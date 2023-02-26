import 'package:collection/collection.dart';
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

abstract class UuidIndexable {
  static const _uuidGen = Uuid();

  static String uuidV4() {
    return _uuidGen.v4();
  }

  static String uuidV4Crypto() {
    return _uuidGen.v4(options: {'rng': UuidUtil.cryptoRNG()});
  }

  String get uuid;
}

@immutable
class Topic extends UuidIndexable {
  Topic({required this.question, required this.answer});

  final String _uuid = UuidIndexable.uuidV4Crypto();
  final Question question;
  final Answer answer;

  @override
  String get uuid => _uuid;
}

class TopicModel extends ChangeNotifier {
  TopicModel.from(Iterable<Topic> topics) : _topicList = List.from(topics);

  TopicModel.empty() : _topicList = List.empty();

  final List<Topic> _topicList;

  Iterable<Topic> get topicList => List.unmodifiable(_topicList);

  void add(Topic topic) {
    _topicList.add(topic);
    notifyListeners();
  }

  void emplace({required Question question, required Answer answer}) {
    _topicList.add(Topic(question: question, answer: answer));
    notifyListeners();
  }

  void removeAt(int index) {
    _topicList.removeAt(index);
    notifyListeners();
  }

  void remove(Topic topic) {
    _topicList.remove(topic);
    notifyListeners();
  }

  Topic getByUuid(String uuid) {
    return _topicList.singleWhere((element) => element.uuid == uuid);
  }

  int getIndexByUuid(String uuid) {
    return _topicList.indexWhere((element) => element.uuid == uuid);
  }
}

class TopicSet extends ChangeNotifier implements UuidIndexable {
  final String _uuid = UuidIndexable.uuidV4Crypto();
  final Map<String, int> _uuidIndexMap;

  TopicSet.empty() : _uuidIndexMap = {};

  TopicSet.notIndexed(Iterable<String> uuids)
      : _uuidIndexMap = {for (var uuid in uuids) uuid: -1};

  TopicSet.indexed(Iterable<String> uuids, {required TopicModel topicModel})
      : _uuidIndexMap = {
          for (var uuid in uuids) uuid: topicModel.getIndexByUuid(uuid)
        };

  TopicSet.from(Map<String, int> uuidIndexMap) : _uuidIndexMap = uuidIndexMap;

  void add(String uuid, {required TopicModel topicModel}) {
    _uuidIndexMap[uuid] = topicModel.getIndexByUuid(uuid);
    notifyListeners();
  }

  void addAll(List<String> uuids, {required TopicModel topicModel}) {
    _uuidIndexMap.addEntries(
        uuids.map((e) => MapEntry(e, topicModel.getIndexByUuid(e))).toList());
    notifyListeners();
  }

  void remove(String uuid) {
    _uuidIndexMap.remove(uuid);
    notifyListeners();
  }

  void removeFrom(List<String> uuids) {
    _uuidIndexMap.removeWhere((key, value) => uuids.contains(key));
    notifyListeners();
  }

  void updateIndexes({required TopicModel topicModel}) {
    _uuidIndexMap.updateAll((key, _) => topicModel.getIndexByUuid(key));
  }

  int update(String uuid, {required TopicModel topicModel}) {
    return _uuidIndexMap.update(uuid, (_) => topicModel.getIndexByUuid(uuid));
  }

  Topic getByUuid(String uuid, {required TopicModel topicModel}) {
    var index = update(uuid, topicModel: topicModel);
    return topicModel.topicList.elementAt(index);
  }

  List<Topic> getAll({required TopicModel topicModel}) {
    updateIndexes(topicModel: topicModel);
    return _uuidIndexMap.values
        .map((e) => topicModel.topicList.elementAt(e))
        .toList();
  }

  @override
  String get uuid => _uuid;
}

class TopicSetModel extends ChangeNotifier {
  late final TopicModel topicModel;

  TopicSetModel.empty() : _topicSets = List.empty();

  TopicSetModel.from(Iterable<TopicSet> topicSets)
      : _topicSets = List.from(topicSets);

  final List<TopicSet> _topicSets;

  Iterable<TopicSet> get topicSets => List.unmodifiable(_topicSets);

  void add(TopicSet topicSet) {
    _topicSets.add(topicSet);
    notifyListeners();
  }

  void addAll(Iterable<TopicSet> topicSets) {
    _topicSets.addAll(topicSets);
    notifyListeners();
  }

  void remove(TopicSet topicSet) {
    _topicSets.remove(topicSet);
    notifyListeners();
  }

  void removeAt(int index) {
    _topicSets.removeAt(index);
    notifyListeners();
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
