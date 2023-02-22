import 'package:custom_quiz/screens/home.dart';
import 'package:custom_quiz/screens/quiz.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/result.dart';
import 'models/result_set.dart';
import 'models/topic.dart';
import 'models/topic_set.dart';

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
