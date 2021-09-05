import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';

import 'QuestionnaireManager.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

import 'Questionnaire.dart';
import 'package:flutter/material.dart';

import '../Pages/GraphicElements.dart';

///Una QuestionnairePage consente di visualizzare un determinato questionario,
///che viene passato al momento dell’istanziazione, insieme al [CompletedQuestionnaireManager].
///Le opzioni delle domande a risposta chiusa compaino sottoforma di radio button,
///mentre per ogni domanda aperta, si crea una textfield.
///Il questionario può essere inviato tramite l’apposito bottone “Conferma”;
///se incompleto, viene visualizzato un messaggio di errore.
///Ogni volta che l’utente risponde ad una domanda, CompletedQuestionnaireManager
///provvede a compilare il [CompletedQuestionnaire] al suo interno, creando campi
///o modificandoli, grazie al suo metodo answer. Il click sul bottone “Conferma”
///invia al server il CQ, codificato in modo opportuno; se tale operazione non va
///a buon fine viene salvato in cache e recuperato soltanto quando si avrà la riuscita
///di un prossimo invio.
// ignore: must_be_immutable
class QuestionnairePage extends StatefulWidget {
  final IQuestionnaire _questionnaire;
  IQuestionnaireManager _manager;
  SogniarioBar _bar;
  QuestionnairePage(this._manager, this._questionnaire, this._bar );

  _QuestionnairePageState createState() =>
    _QuestionnairePageState(_manager, _questionnaire, _bar);
}

class _QuestionnairePageState extends State<QuestionnairePage>{

  IQuestionnaire _questionnaire;
  String _message = "";
  IQuestionnaireManager _manager;
  List<IQuestion> _questions = [];
  SogniarioBar _bar;

  _QuestionnairePageState(this._manager, this._questionnaire, this._bar){
    _questions = _questionnaire.getQuestions();
  }

  ///Al click del bottone conferma, se il questionario è completo, viene inviato,
  ///altrimenti viene visualizzato un messaggio di errore
  Future<void> _confirm(BuildContext context)async {
    Widget next = await _manager.confirm();
    if (next == null) setState((){_message = "Per favore, rispondi a tutte le domande"; });
    else
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => next
        )
      );
  }

  ///Permette di rispondere ad una domanda
  void _select(String idQuestion, String score, bool withScore){
    setState(() {
      _manager.answer(idQuestion, score, withScore);
    });
  }

  Widget build(BuildContext context)=>
      Scaffold(
        appBar: _bar.build(context),
        body:Padding(padding: EdgeInsets.all(5), child: buildListView()
     ));

  ///Costruisce la lista degli elementi
  ListView buildListView(){
    List<Widget> children = [
      Padding(padding: EdgeInsets.all(10), child:
        _questionnaire.getDescription()!=""?
          Text(_questionnaire.getDescription(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)):
          SogniarioPageTitle(_questionnaire.getName())
      )
    ];
    children.addAll(buildQuestions());
    children.addAll([SogniarioMessage(_message), SogniarioFunctionButton("Conferma", ()=>_confirm(context), null)]);

    return ListView(children: children,);
  }

  ///Costruisce le domande
  List<Widget> buildQuestions(){
    List<Widget> questionsList = [];
    for(int i =0;i<_questions.length;i++) {
      questionsList.add(_buildQuestion(_questions[i], i));
      if(i!= _questions.length-1) questionsList.add(Divider(
          height: 40,
          thickness: 3,
          indent: 30,
          endIndent: 30,
          color: Colors.black
      ));
    }
    return questionsList;
  }


///Costruisce una domanda
  Column _buildQuestion(IQuestion question, int index){
    List<Widget> component = [];
    component.add(
        Padding(
            padding: EdgeInsets.all(10),
            child:
            Column(children: [
                Padding(padding: EdgeInsets.only(bottom: 10), child:Text((index+1).toString() +" / "+ _questions.length.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
                SogniarioText(question.getQuestion(), 20.0)])));
    List<IAnswer> answers = question.getAnswers();
    if(answers.length==1) component.add(buildOpenAnswer(answers[0], question.getId()));
    else component.addAll(buildCloseAnswers(answers, question.getId()));
    return Column(children: component);
  }

  ///Costruisce una risposta ad una domanda aperta
  ///Non prevedono punteggio
  Widget buildOpenAnswer(IAnswer answer, String questionId){
    if(answer.getType()=="Time") // ORARIO
      return TimePickerSpinner(
        minutesInterval: 15,
        onTimeChange: (time) {
          setState(() {
            _select(questionId, DateConverter().dateTimeToString(time), false);
          });
        },
      );

    if(answer.getType()=="Year"){// ANNO
      List<DropdownMenuItem<int>> years = [];
      for(int y = DateTime.now().subtract(Duration(days:36500)).year; y<=DateTime.now().subtract(Duration(days: 3650)).year; y++)
        years.add(DropdownMenuItem<int>(
          value: y,
          child: Text(y.toString()),
        ));
      return DropdownButton(
        items: years,
        value: int.parse(_manager.getAnswerOf(questionId), onError: (str)=>DateTime.now().subtract(Duration(days: 16425)).year),
        onChanged: (v){
          setState(() {
            _select(questionId, v.toString(), false);
          });
        },
      );
    }

    if(answer.getType()=="Number") // NUMERO
      return Padding(padding: EdgeInsets.all(10.0), child:TextField(
        keyboardType: TextInputType.number,
        maxLength: answer.getLength()>0?answer.getLength(): 10,
        maxLengthEnforced: true,
        onChanged: (text)=>_select(questionId, text, false),
      ));

      return Padding(padding: EdgeInsets.all(10.0), child:TextField(
        keyboardType: TextInputType.text,
        maxLength: answer.getLength()>0?answer.getLength(): 200,
        maxLengthEnforced: false,
        onChanged: (text)=>_select(questionId, text, false),
      ));
  }

  ///Costruisce una risposta ad una domanda chiusa
  ///Può prevedere punteggio
  List<Widget> buildCloseAnswers(List<IAnswer> answers, String questionId){
    List<Widget> options =  [];
    answers.forEach((answer){
      options.add(
        Row(
          children: [
            Radio(
              onChanged: (value){_select(questionId, answer.getScore(), true);},
              value: answer.getScore(),
              groupValue: _manager.getAnswerOf(questionId)
            ),
            Flexible(child: SogniarioText(answer.getAnswer(), 20.0))
          ]
        )
      );
    });
    return options;
  }

}