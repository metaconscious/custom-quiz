import 'package:custom_quiz/models/topic.dart';
import 'package:flutter/cupertino.dart';

import '../common/models.dart';

class TopicSetModel extends ChangeNotifier {
  late final TopicModel topicModel;

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

  List<Topic> get topics {
    return _indexes.map((e) => topicModel.elementAt(e)).toList();
  }
}
