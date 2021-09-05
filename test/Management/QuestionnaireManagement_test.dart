import 'package:sogniario/it/unicam/sogniario/Questionnaire/Questionnaire.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test('Map to Questionnaire', () {
    Map<String, dynamic> map = {
      "_id": "0",
      "name": "Questionnaire name",
      "types": [0, 2],
      "questions": [
        {
          "_id": "0",
          "question": "q0",
          "answers": [
            {"answer": "a00", "value": '0'},
            {"answer": "a01", "value": '1'},
          ]
        },
        {
          "_id": "1",
          "question": "q1",
          "answers": [
            {"answer": "a10", "value": '0'},
            {"answer": "a11", "value": '1'},
            {"answer": "a12", "value": '2'},
          ]
        },
        {
          "_id": "2",
          "question": "q2",
          "answers": []
        }
      ]};

    Questionnaire questionnaire = Questionnaire(map, DateTime.now());
    expect(questionnaire.getName(), "Questionnaire name");
    List<Question> questions = questionnaire.getQuestions();
    expect(questions[0].getQuestion(), "q0");
    expect(questions[0]
        .getAnswers()
        .length, 2);
    expect(questions[1].getQuestion(), "q1");
    expect(questions[1]
        .getAnswers()
        .length, 3);
    expect(questions[2].getQuestion(), "q2");
    expect(questions[2]
        .getAnswers()
        .length, 0);
  });

}