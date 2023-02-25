import 'package:custom_quiz/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

abstract class Question {
  String get subject;

  Iterable<String> get hints;

  String get details;
}

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

class ShortAskQuestion implements Question {
  const ShortAskQuestion(
      {required String subject, Iterable<String> details = const []})
      : _subject = subject,
        _details = details;

  final String _subject;
  final Iterable<String> _details;

  @override
  String get details => _details.join('\n');

  @override
  Iterable<String> get hints => const [];

  @override
  String get subject => _subject;
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
