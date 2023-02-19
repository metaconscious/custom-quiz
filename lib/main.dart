import 'dart:convert';

import 'package:custom_quiz/topic.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Question extends StatelessWidget {
  const Question({Key? key, required this.question}) : super(key: key);

  final String question;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(question),
    );
  }
}

class Option extends StatelessWidget {
  const Option(
      {Key? key,
      required this.option,
      required this.index,
      required this.isChosen,
      required this.onOptionSelected})
      : super(key: key);

  final String option;
  final int index;
  final bool isChosen;
  final OptionSelectedCallback onOptionSelected;

  String _indexToUppercaseAlphabet() {
    if (index < 26) {
      return String.fromCharCode(ascii.encode('A').first + index);
    } else {
      return '$index';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            child: Text(_indexToUppercaseAlphabet()),
          )
        ],
      ),
      title: Text(option),
      selected: isChosen,
      selectedColor: Colors.lightBlueAccent,
      selectedTileColor: Colors.blueGrey,
      onTap: () {
        onOptionSelected(index);
      },
    );
  }
}

typedef OptionSelectedCallback = void Function(int index);

class OptionList extends StatelessWidget {
  const OptionList(
      {Key? key,
      required this.options,
      required this.selections,
      required this.onOptionSelected})
      : super(key: key);

  final List<String> options;
  final List<bool> selections;
  final OptionSelectedCallback onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options
          .asMap()
          .entries
          .map((e) => Option(
                option: e.value,
                index: e.key,
                isChosen: selections.elementAt(e.key),
                onOptionSelected: onOptionSelected,
              ))
          .toList(),
    );
  }
}

class MultipleAnswerMultipleChoiceQuiz extends StatefulWidget {
  const MultipleAnswerMultipleChoiceQuiz(
      {Key? key, required this.question, required this.options})
      : super(key: key);

  final String question;
  final List<String> options;

  @override
  State<MultipleAnswerMultipleChoiceQuiz> createState() =>
      _MultipleAnswerMultipleChoiceQuizState();
}

class _MultipleAnswerMultipleChoiceQuizState
    extends State<MultipleAnswerMultipleChoiceQuiz> {
  final List<bool> selections = [false, false, false, false];

  void _handleOptionSelected(int index) {
    setState(() {
      selections[index] = !selections[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Question(question: widget.question),
          const Divider(),
          OptionList(
              options: widget.options,
              selections: selections,
              onOptionSelected: _handleOptionSelected),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final mamct = const MultipleAnswerMultipleChoiceTopic(
      question: 'question 1',
      options: ['option 1', 'option 2', 'option 3', 'option 4'],
      answer: [0, 1, 2, 3]);

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
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text('Hello Flutter'),
        ),
        body: MultipleAnswerMultipleChoiceQuiz(
          question: mamct.question,
          options: mamct.options,
        ),
      ),
    );
  }
}
