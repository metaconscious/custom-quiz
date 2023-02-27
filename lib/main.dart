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

  MultipleChoiceAnswer.empty({required int length})
      : _answerList = List.filled(length, false);

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

  BlankFillingAnswer.empty({required int length})
      : _blankAnswer = List.filled(length, '');

  final List<String> _blankAnswer;

  void changeAt(int index, String value) {
    _blankAnswer[index] = value;
  }

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
  ShortAskAnswer.empty() : _multilineAnswer = List.empty();

  ShortAskAnswer.string({required String multilineAnswer})
      : _multilineAnswer =
            multilineAnswer.split('\n').map((e) => e.trim()).toList();

  ShortAskAnswer.list({required List<String> answer})
      : _multilineAnswer = answer;

  List<String> _multilineAnswer;

  void answerByList(List<String> newAnswer) {
    _multilineAnswer = newAnswer;
  }

  void answerByString(String newMultilineAnswer) {
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

enum TopicTypes {
  multipleChoice,
  trueOrFalse,
  blankFilling,
  shortAsk,
}

@immutable
class Topic extends UuidIndexable {
  Topic(
      {required this.question, required this.answer, required this.topicType});

  final String _uuid = UuidIndexable.uuidV4Crypto();
  final Question question;
  final Answer answer;
  final TopicTypes topicType;

  @override
  String get uuid => _uuid;
}

class TopicModel extends ChangeNotifier {
  TopicModel.from(Iterable<Topic> topics) : _topicList = List.from(topics);

  TopicModel.empty() : _topicList = List.empty();

  final List<Topic> _topicList;
  DateTime _lastUpdate = DateTime.now();

  get lastUpdate => _lastUpdate;

  void _update() {
    _lastUpdate = DateTime.now();
  }

  Iterable<Topic> get topicList => List.unmodifiable(_topicList);

  void add(Topic topic) {
    _topicList.add(topic);
    notifyListeners();
  }

  void emplace(
      {required Question question,
      required Answer answer,
      required TopicTypes topicType}) {
    _topicList
        .add(Topic(question: question, answer: answer, topicType: topicType));
  }

  void removeAt(int index) {
    _topicList.removeAt(index);
    notifyListeners();
    _update();
  }

  void remove(Topic topic) {
    _topicList.remove(topic);
    notifyListeners();
    _update();
  }

  Topic getByUuid(String uuid) {
    return _topicList.singleWhere((element) => element.uuid == uuid);
  }

  int getIndexByUuid(String uuid) {
    return _topicList.indexWhere((element) => element.uuid == uuid);
  }

  bool existsWithUuid(String uuid) {
    return _topicList.any((element) => element.uuid == uuid);
  }
}

class TopicSet extends ChangeNotifier implements UuidIndexable {
  final String _uuid = UuidIndexable.uuidV4Crypto();
  final Map<String, int> _uuidIndexMap;
  DateTime _lastSync = DateTime.now();

  TopicSet.empty() : _uuidIndexMap = {};

  TopicSet.notIndexed(Iterable<String> uuids)
      : _uuidIndexMap = {for (var uuid in uuids) uuid: -1};

  TopicSet.indexed(Iterable<String> uuids, {required TopicModel topicModel})
      : _uuidIndexMap = {
          for (var uuid in uuids) uuid: topicModel.getIndexByUuid(uuid)
        };

  TopicSet.from(Map<String, int> uuidIndexMap) : _uuidIndexMap = uuidIndexMap;

  void _syncWith(TopicModel topicModel) {
    _lastSync = topicModel._lastUpdate;
  }

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
    if (_lastSync == topicModel.lastUpdate) {
      return;
    }
    _uuidIndexMap.updateAll((key, _) => topicModel.getIndexByUuid(key));
    _syncWith(topicModel);
  }

  int update(String uuid, {required TopicModel topicModel}) {
    return _uuidIndexMap.update(uuid, (_) => topicModel.getIndexByUuid(uuid));
  }

  Topic getByUuid(String uuid, {required TopicModel topicModel}) {
    if (_lastSync == topicModel.lastUpdate) {
      return topicModel.topicList.elementAt(_uuidIndexMap[uuid]!);
    }
    return topicModel.topicList.elementAt(update(uuid, topicModel: topicModel));
  }

  List<Topic> getAll({required TopicModel topicModel}) {
    updateIndexes(topicModel: topicModel);
    return _uuidIndexMap.values
        .map((e) => topicModel.topicList.elementAt(e))
        .toList();
  }

  @override
  String get uuid => _uuid;

  Iterable<String> get topicUuids {
    return _uuidIndexMap.keys;
  }
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

  void emplace(Iterable<Topic> topics) {
    _topicSets.add(
        TopicSet.indexed(topics.map((e) => e.uuid), topicModel: topicModel));
  }

  void emplaceAll(Iterable<Iterable<Topic>> topicsList) {
    _topicSets.addAll(topicsList.map((e) => TopicSet.indexed(
        e.map((e) => e.uuid).toList(),
        topicModel: topicModel)));
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

  TopicSet getByUuid(String uuid) {
    return _topicSets.singleWhere((element) => element.uuid == uuid);
  }

  int getIndexByUuid(String uuid) {
    return _topicSets.indexWhere((element) => element.uuid == uuid);
  }
}

abstract class Quiz extends UuidIndexable {
  Quiz({required String topicUuid, required Answer answer})
      : _topicUuid = topicUuid,
        _answer = answer;

  final String _uuid = UuidIndexable.uuidV4Crypto();
  final String _topicUuid;
  final Answer _answer;

  @override
  String get uuid => _uuid;

  String get topicUuid => _topicUuid;

  Answer get answer => _answer;

  T cast<T extends Answer>() {
    if (_answer is T) {
      return _answer as T;
    }
    throw UnsupportedError('answer is not type ${T.runtimeType}');
  }
}

class MultipleChoiceQuiz extends Quiz {
  MultipleChoiceQuiz({required super.topicUuid, required super.answer});

  MultipleChoiceQuiz.empty({required Topic topic})
      : super(
            topicUuid: topic.uuid,
            answer: MultipleChoiceAnswer.empty(
                length:
                    (topic.answer as MultipleChoiceAnswer)._answerList.length));
}

class BlankFillingQuiz extends Quiz {
  BlankFillingQuiz({required super.topicUuid, required super.answer});

  BlankFillingQuiz.empty({required Topic topic})
      : super(
            topicUuid: topic.uuid,
            answer: BlankFillingAnswer.empty(
                length:
                    (topic.answer as BlankFillingAnswer)._blankAnswer.length));
}

class ShortAnswerQuiz extends Quiz {
  ShortAnswerQuiz({required super.topicUuid, required super.answer});

  ShortAnswerQuiz.empty({required Topic topic})
      : super(topicUuid: topic.uuid, answer: ShortAskAnswer.empty());
}

class QuizModel extends ChangeNotifier {
  late final TopicModel topicModel;

  final List<Quiz> _quizList;
  DateTime _lastUpdate = DateTime.now();

  DateTime get lastUpdate => _lastUpdate;

  QuizModel.empty() : _quizList = List.empty();

  QuizModel.from(Iterable<Quiz> quizzes) : _quizList = List.from(quizzes);

  Iterable<Quiz> get quizzes => List.unmodifiable(_quizList);

  void _add(Quiz quiz) {
    if (topicModel.existsWithUuid(quiz.topicUuid)) {
      _quizList.add(quiz);
      notifyListeners();
    }
    throw ArgumentError('Topic with uuid ${quiz.uuid} not exist');
  }

  void _dispatchAdd(Topic topic) {
    switch (topic.topicType) {
      case TopicTypes.multipleChoice:
      case TopicTypes.trueOrFalse:
        _add(MultipleChoiceQuiz.empty(topic: topic));
        break;
      case TopicTypes.blankFilling:
        _add(BlankFillingQuiz.empty(topic: topic));
        break;
      case TopicTypes.shortAsk:
        _add(ShortAnswerQuiz.empty(topic: topic));
        break;
    }
  }

  void emplace(Topic topic) {
    _dispatchAdd(topic);
    notifyListeners();
  }

  void emplaceAll(Iterable<Topic> topics) {
    topics.forEach(emplace);
    notifyListeners();
  }

  void removeAt(int index) {
    _quizList.removeAt(index);
    notifyListeners();
    _update();
  }

  void remove(Quiz quiz) {
    _quizList.remove(quiz);
    notifyListeners();
    _update();
  }

  void _update() {
    _lastUpdate = DateTime.now();
  }

  Quiz getByUuid(String uuid) {
    return _quizList.singleWhere((element) => element.uuid == uuid);
  }

  int getIndexByUuid(String uuid) {
    return _quizList.indexWhere((element) => element.uuid == uuid);
  }

  bool existsWithUuid(String uuid) {
    return _quizList.any((element) => element.uuid == uuid);
  }
}

class QuizSet extends ChangeNotifier implements UuidIndexable {
  final String _uuid = UuidIndexable.uuidV4Crypto();
  final Map<String, int> _uuidIndexMap;
  DateTime _lastSync = DateTime.now();

  QuizSet.empty() : _uuidIndexMap = {};

  QuizSet.indexed(TopicSet topicSet,
      {required TopicModel topicModel, required QuizModel quizModel})
      : _uuidIndexMap = {} {
    topicSet.getAll(topicModel: topicModel).forEach((element) {
      quizModel.emplace(element);
      _uuidIndexMap[quizModel.quizzes.last.uuid] = quizModel.quizzes.length - 1;
    });
  }

  QuizSet.from(Map<String, int> uuidIndexMap) : _uuidIndexMap = uuidIndexMap;

  void _syncWith(QuizModel quizModel) {
    _lastSync = quizModel.lastUpdate;
  }

  @override
  String get uuid => _uuid;

  void add(String uuid, {required QuizModel quizModel}) {
    _uuidIndexMap[uuid] = quizModel.getIndexByUuid(uuid);
    notifyListeners();
  }

  void addAll(List<String> uuids, {required QuizModel quizModel}) {
    _uuidIndexMap.addEntries(
        uuids.map((e) => MapEntry(e, quizModel.getIndexByUuid(e))).toList());
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

  void updateIndexes({required QuizModel quizModel}) {
    if (_lastSync == quizModel.lastUpdate) {
      return;
    }
    _uuidIndexMap.updateAll((key, _) => quizModel.getIndexByUuid(key));
    _syncWith(quizModel);
  }

  int update(String uuid, {required QuizModel quizModel}) {
    return _uuidIndexMap.update(uuid, (_) => quizModel.getIndexByUuid(uuid));
  }

  Quiz getByUuid(String uuid, {required QuizModel quizModel}) {
    if (_lastSync == quizModel.lastUpdate) {
      return quizModel.quizzes.elementAt(_uuidIndexMap[uuid]!);
    }
    return quizModel.quizzes.elementAt(update(uuid, quizModel: quizModel));
  }

  List<Quiz> getAll({required QuizModel quizModel}) {
    updateIndexes(quizModel: quizModel);
    return _uuidIndexMap.values
        .map((e) => quizModel.quizzes.elementAt(e))
        .toList();
  }
}

class QuizSetModel extends ChangeNotifier {
  late final TopicModel topicModel;
  late final QuizModel quizModel;

  QuizSetModel.empty() : _quizSets = List.empty();

  QuizSetModel.from(Iterable<QuizSet> quizSets)
      : _quizSets = List.from(quizSets);

  final List<QuizSet> _quizSets;

  Iterable<QuizSet> get quizSets => List.unmodifiable(_quizSets);

  void add(QuizSet quizSet) {
    _quizSets.add(quizSet);
    notifyListeners();
  }

  void emplace(TopicSet topicSet) {
    _quizSets.add(QuizSet.indexed(topicSet,
        quizModel: quizModel, topicModel: topicModel));
  }

  void emplaceAll(Iterable<TopicSet> quizzesList) {
    _quizSets.addAll(quizzesList.map((e) =>
        QuizSet.indexed(e, quizModel: quizModel, topicModel: topicModel)));
  }

  void addAll(Iterable<QuizSet> quizSets) {
    _quizSets.addAll(quizSets);
    notifyListeners();
  }

  void remove(QuizSet quizSet) {
    _quizSets.remove(quizSet);
    notifyListeners();
  }

  void removeAt(int index) {
    _quizSets.removeAt(index);
    notifyListeners();
  }

  QuizSet getByUuid(String uuid) {
    return _quizSets.singleWhere((element) => element.uuid == uuid);
  }

  int getIndexByUuid(String uuid) {
    return _quizSets.indexWhere((element) => element.uuid == uuid);
  }
}

void main() {
  runApp(const MyApp());
}

GoRouter router() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'topics',
            builder: (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text('All Topics'),
              ),
              body: const Placeholder(),
            ),
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text('Quiz History'),
              ),
              body: const Placeholder(),
            ),
          ),
          GoRoute(
            path: 'new-topic',
            builder: (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text('Create New Topic'),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.save),
                  ),
                ],
              ),
              body: const Placeholder(),
            ),
          ),
          GoRoute(
            path: 'user-info',
            builder: (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text('User Info'),
              ),
              body: const Placeholder(),
            ),
          ),
        ],
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
        ChangeNotifierProvider<TopicModel>(
          create: (context) => TopicModel.empty(),
        ),
        ChangeNotifierProxyProvider<TopicModel, TopicSetModel>(
          create: (context) => TopicSetModel.empty(),
          update: (context, topicModel, topicSetModel) {
            if (topicSetModel == null) {
              throw ArgumentError.notNull('topicSetModel');
            }
            topicSetModel.topicModel = topicModel;
            return topicSetModel;
          },
        ),
        ChangeNotifierProxyProvider<TopicModel, QuizModel>(
          create: (context) => QuizModel.empty(),
          update: (context, topicModel, quizModel) {
            if (quizModel == null) {
              throw ArgumentError.notNull('topicSetModel');
            }
            quizModel.topicModel = topicModel;
            return quizModel;
          },
        ),
        ChangeNotifierProxyProvider2<TopicModel, QuizModel, QuizSetModel>(
          create: (context) => QuizSetModel.empty(),
          update: (context, topicModel, quizModel, quizSetModel) {
            if (quizSetModel == null) {
              throw ArgumentError.notNull('topicSetModel');
            }
            quizSetModel.topicModel = topicModel;
            quizSetModel.quizModel = quizModel;
            return quizSetModel;
          },
        )
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
