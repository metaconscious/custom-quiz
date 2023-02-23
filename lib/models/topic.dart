import 'package:flutter/cupertino.dart';

import '../common/models.dart';

class TopicModel extends ChangeNotifier {
  final List<Topic> topics = [];

  Topic elementAt(int index) {
    return topics.elementAt(index);
  }

  int indexOf(Topic topic) {
    return topics.indexOf(topic);
  }

  void remove(Topic topic) {
    topics.remove(topic);
    notifyListeners();
  }

  void removeAt(int index) {
    topics.removeAt(index);
    notifyListeners();
  }

  void clear() {
    topics.clear();
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

  List<Topic> getAllByTopicType(TopicTypes topicType) {
    return topics.expand((e) => [if (e.topicType == topicType) e]).toList();
  }

  List<Topic> getAllByQuestionType(QuestionTypes questionType) {
    return topics
        .expand((e) => [if (e.questionType == questionType) e])
        .toList();
  }

  List<Topic> getAllByAnswerType(AnswerTypes answerType) {
    return topics.expand((e) => [if (e.answerType == answerType) e]).toList();
  }

  TopicModel.fromJson(Map<String, dynamic> json) {
    topics.addAll(json['topics']);
  }

  Map<String, dynamic> toJson() => {
        'topics': topics.map((e) => e.toJson()).toList(),
      };
}
