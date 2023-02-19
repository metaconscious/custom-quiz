import 'dart:convert';

import 'package:custom_quiz/topic.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Option extends StatelessWidget {
  const Option({Key? key, required this.option, required this.index})
      : super(key: key);

  final String option;
  final int index;

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
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final mcmat = const MultipleAnswerMultipleChoiceTopic(
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
        body: const Option(
          option: 'Question',
          index: 0,
        ),
      ),
    );
  }
}
