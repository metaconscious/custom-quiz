import 'package:custom_quiz/models/topic.dart';
import 'package:custom_quiz/screens/quiz.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final samct = const SingleAnswerMultipleChoiceTopic(
      question: 'question 0',
      options: ['option 1', 'option 2', 'option 3', 'option 4'],
      answer: 2);

  final mamct = const MultipleAnswerMultipleChoiceTopic(
      question: 'question 1',
      options: ['option 1', 'option 2', 'option 3', 'option 4'],
      answer: [true, false, false, true]);

  final toft = const TrueOrFalseTopic(question: 'statement 2', answer: false);

  final sat = const ShortAnswerTopic(question: 'question 3', answer: 'answer');

  late final List<Widget> widgets = [
    SingleAnswerMultipleChoiceQuiz(
      question: samct.question,
      options: samct.options,
    ),
    MultipleAnswerMultipleChoiceQuiz(
      question: mamct.question,
      options: mamct.options,
    ),
    TrueOrFalseQuiz(
      question: toft.question,
    ),
    ShortAnswerQuiz(
      question: sat.question,
    )
  ];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: const Center(
          child: Text('Body'),
        ),
        bottomNavigationBar: const BottomAppBar(),
      ),
    );
  }
}
