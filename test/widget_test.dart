import 'package:flutter_test/flutter_test.dart';

import 'package:encuestas_yeti/data/questions.dart';

void main() {
  test('hay 8 preguntas con IDs q1..q8', () {
    expect(questions.length, 8);
    for (var i = 0; i < 8; i++) {
      expect(questions[i].id, 'q${i + 1}');
    }
  });
}
