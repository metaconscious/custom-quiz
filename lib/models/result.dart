import 'package:custom_quiz/models/topic.dart';
import 'package:flutter/cupertino.dart';

import '../common/models.dart';

class ResultModel extends ChangeNotifier {
  late final TopicModel topicModel;

  final List<Result> results = [];

  Result elementAt(int index) {
    return results.elementAt(index);
  }

  int indexOf(Result result) {
    return results.indexOf(result);
  }

  void remove(Result result) {
    results.remove(result);
    notifyListeners();
  }

  void removeAt(int index) {
    results.removeAt(index);
    notifyListeners();
  }

  void clear() {
    results.clear();
    notifyListeners();
  }

  void add(Result newResult) {
    results.add(newResult);
    notifyListeners();
  }

  void addAll(Iterable<Result> newResult) {
    results.addAll(newResult);
    notifyListeners();
  }

  Topic correspondedTopicAt(int index) {
    return topicModel.elementAt(results.elementAt(index).topicIndex);
  }

  Topic correspondedTopicOf(Result result) {
    return topicModel
        .elementAt(results.elementAt(results.indexOf(result)).topicIndex);
  }
}
