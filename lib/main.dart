import 'dart:convert';

import 'package:custom_quiz/topic.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
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

class MultipleChoiceQuiz extends StatelessWidget {
  const MultipleChoiceQuiz(
      {Key? key,
      required this.question,
      required this.options,
      required this.onOptionSelected,
      required this.selections})
      : super(key: key);

  final String question;
  final List<String> options;
  final List<bool> selections;
  final OptionSelectedCallback onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Question(question: question),
          const Divider(),
          OptionList(
            options: options,
            selections: selections,
            onOptionSelected: onOptionSelected,
          ),
        ],
      ),
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
  late final List<bool> selections;

  @override
  void initState() {
    super.initState();
    selections = List<bool>.filled(widget.options.length, false);
  }

  void _handleOptionSelected(int index) {
    setState(() {
      selections[index] = !selections[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultipleChoiceQuiz(
        question: widget.question,
        options: widget.options,
        onOptionSelected: _handleOptionSelected,
        selections: selections);
  }
}

class SingleAnswerMultipleChoiceQuiz extends StatefulWidget {
  const SingleAnswerMultipleChoiceQuiz(
      {Key? key, required this.question, required this.options})
      : super(key: key);

  final String question;
  final List<String> options;

  @override
  State<SingleAnswerMultipleChoiceQuiz> createState() =>
      _SingleAnswerMultipleChoiceQuizState();
}

class _SingleAnswerMultipleChoiceQuizState
    extends State<SingleAnswerMultipleChoiceQuiz> {
  bool firstChange = true;
  int lastIndex = 0;
  late final List<bool> selections;

  @override
  void initState() {
    super.initState();
    selections = List<bool>.filled(widget.options.length, false);
  }

  void _handleOptionSelected(int index) {
    setState(() {
      if (firstChange) {
        firstChange = false;
      } else {
        selections[lastIndex] = !selections[lastIndex];
      }
      lastIndex = index;
      selections[index] = !selections[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultipleChoiceQuiz(
        question: widget.question,
        options: widget.options,
        onOptionSelected: _handleOptionSelected,
        selections: selections);
  }
}

class TrueOrFalseQuiz extends StatefulWidget {
  const TrueOrFalseQuiz({Key? key, required this.question}) : super(key: key);

  final String question;
  final List<String> options = const ['False', 'True'];

  @override
  State<TrueOrFalseQuiz> createState() => _TrueOrFalseQuizState();
}

class _TrueOrFalseQuizState extends State<TrueOrFalseQuiz> {
  bool firstChange = true;
  int lastIndex = 0;
  late final List<bool> selections;

  @override
  void initState() {
    super.initState();
    selections = List<bool>.filled(widget.options.length, false);
  }

  void _handleOptionSelected(int index) {
    setState(() {
      if (firstChange) {
        firstChange = false;
      } else {
        selections[lastIndex] = !selections[lastIndex];
      }
      lastIndex = index;
      selections[index] = !selections[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultipleChoiceQuiz(
        question: widget.question,
        options: widget.options,
        onOptionSelected: _handleOptionSelected,
        selections: selections);
  }
}

typedef TextFieldChangedCallback = void Function(String text);

class ShortAnswerQuiz extends StatefulWidget {
  const ShortAnswerQuiz({Key? key, required this.question}) : super(key: key);

  final String question;

  @override
  State<ShortAnswerQuiz> createState() => _ShortAnswerQuizState();
}

class _ShortAnswerQuizState extends State<ShortAnswerQuiz> {
  String userInput = '';

  void _handleTextFieldChanged(String text) {
    setState(() {
      userInput = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Question(question: widget.question),
          const Divider(),
          TextField(
            onChanged: (text) => {_handleTextFieldChanged(text)},
          ),
        ],
      ),
    );
  }
}

typedef QuizButtonClickedCallback = void Function();

class UserAnswerArea extends StatelessWidget {
  const UserAnswerArea(
      {Key? key,
      required this.quizWidgets,
      required this.index,
      required this.onPrevButtonClicked,
      required this.onNextButtonClicked})
      : super(key: key);

  final List<Widget> quizWidgets;
  final int index;

  final QuizButtonClickedCallback onPrevButtonClicked;
  final QuizButtonClickedCallback onNextButtonClicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        quizWidgets.elementAt(index),
        const Divider(),
        ButtonBar(
          children: [
            FloatingActionButton(
              onPressed: onPrevButtonClicked,
              child: const Text('Prev'),
            ),
            FloatingActionButton(
              onPressed: onNextButtonClicked,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }
}

typedef QuickToQuizTapped = void Function();

class QuickToQuiz extends StatelessWidget {
  const QuickToQuiz(
      {Key? key,
      required this.question,
      required this.isAnswered,
      required this.onQuickToQuizTapped})
      : super(key: key);

  final String question;
  final bool isAnswered;

  final QuickToQuizTapped onQuickToQuizTapped;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        question,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const CircleAvatar(
        child: Text('D'),
      ),
      onTap: onQuickToQuizTapped,
    );
  }
}

class QuizStateList extends StatelessWidget {
  QuizStateList({Key? key, required List<Widget> quickToQuizWidgets})
      : super(key: key) {
    widgets = [
      const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Text('header'),
      ),
    ];
    widgets.addAll(quickToQuizWidgets);
  }

  late final List<Widget> widgets;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: widgets,
      ),
    );
  }
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
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text('Quiz Set Title'),
        ),
        body: UserAnswerArea(
          quizWidgets: widgets,
          index: 0,
          onPrevButtonClicked: () {},
          onNextButtonClicked: () {},
        ),
        drawer: QuizStateList(
          quickToQuizWidgets: [
            QuickToQuiz(
              question: samct.question,
              isAnswered: false,
              onQuickToQuizTapped: () {},
            ),
            QuickToQuiz(
              question: mamct.question,
              isAnswered: false,
              onQuickToQuizTapped: () {},
            ),
            QuickToQuiz(
              question: toft.question,
              isAnswered: false,
              onQuickToQuizTapped: () {},
            ),
            QuickToQuiz(
              question: sat.question,
              isAnswered: false,
              onQuickToQuizTapped: () {},
            ),
          ],
        ),
        bottomNavigationBar: const BottomAppBar(),
      ),
    );
  }
}
