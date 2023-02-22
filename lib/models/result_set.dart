import 'package:custom_quiz/models/result.dart';
import 'package:custom_quiz/models/topic.dart';
import 'package:flutter/cupertino.dart';

import '../common/models.dart';

class ResultSetModel extends ChangeNotifier {
  late final TopicModel topicModel;
  late final ResultModel resultModel;

  final List<int> _indexes = [];

  List<int> get indexes => _indexes;

  void add(int index) {
    _indexes.add(index);
    notifyListeners();
  }

  void addAll(Iterable<int> indexes) {
    _indexes.addAll(indexes);
    notifyListeners();
  }

  void remove(int value) {
    _indexes.remove(value);
    notifyListeners();
  }

  void removeAt(int index) {
    _indexes.removeAt(index);
    notifyListeners();
  }

  List<Result> get results {
    return _indexes.map((e) => resultModel.elementAt(e)).toList();
  }

  List<Topic> get topics {
    return results.map((e) => topicModel.elementAt(e.topicIndex)).toList();
  }
}
