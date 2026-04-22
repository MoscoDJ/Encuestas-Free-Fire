import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/questions.dart';
import '../models/question.dart';
import '../models/survey_response.dart';
import '../services/storage_service.dart';

class SurveyController extends ChangeNotifier {
  SurveyController({StorageService? storage})
      : _storage = storage ?? StorageService();

  final StorageService _storage;
  static const _uuid = Uuid();

  int _index = 0;
  final Map<String, dynamic> _answers = {};

  int get index => _index;
  int get total => questions.length;
  Question get current => questions[_index];
  bool get isFirst => _index == 0;
  bool get isLast => _index == questions.length - 1;

  dynamic answerFor(String id) => _answers[id];

  void setAnswer(String questionId, dynamic value) {
    _answers[questionId] = value;
    notifyListeners();
  }

  void toggleMulti(String questionId, String option) {
    final current = List<String>.from(_answers[questionId] as List? ?? const []);
    if (current.contains(option)) {
      current.remove(option);
    } else {
      current.add(option);
    }
    _answers[questionId] = current;
    notifyListeners();
  }

  List<String> multiSelection(String questionId) {
    return List<String>.from(_answers[questionId] as List? ?? const []);
  }

  void next() {
    if (_index < questions.length - 1) {
      _index++;
      notifyListeners();
    }
  }

  void previous() {
    if (_index > 0) {
      _index--;
      notifyListeners();
    }
  }

  Future<SurveyResponse> submit() async {
    final response = SurveyResponse(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      answers: Map<String, dynamic>.from(_answers),
    );
    await _storage.append(response);
    return response;
  }

  void reset() {
    _index = 0;
    _answers.clear();
    notifyListeners();
  }
}
