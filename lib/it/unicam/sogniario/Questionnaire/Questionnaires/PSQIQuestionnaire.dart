import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/AskPage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';
import 'package:sogniario/it/unicam/sogniario/Questionnaire/Questionnaire.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/Connection.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';

import '../QuestionnaireManager.dart';
import '../QuestionnaireResultPage.dart';

///PSQICompletedQuestionnaire, estendendo [AskPage], fornisce un calcolo personalizzato
///per il punteggio, essendo differente dalla semplice somma dei valori delle
///risposte dell’utente.
class PSQIQuestionnaire extends Questionnaire{
  PSQIQuestionnaire(IQuestionnaire questionnaire, DateTime date) : super(questionnaire, date);

  @override
  int getScore() {
    List<IChoice> answers = super.getAnswers();

    int c1 = answers[14].getScore();
    int c2 = answers[1].getScore() + answers[4].getScore();
    int answ3 = int.parse(answers[3].getValue());
    int c3 = answ3>7? 0: answ3>6?1:answ3>5?2:3;
    DateTime h1 = DateConverter().stringToDateTime(answers[0].getValue());
    DateTime h2 = DateConverter().stringToDateTime(answers[1].getValue());
    double perc = 100*(answ3 /(h2.difference(h1).inHours));
    int c4 = perc>84?0:perc>74?1:perc>64?2:3;
    int sum = answers[0].getScore();
    for(int i = 5; i<12; i++) sum += answers[i].getScore();
    int c5 = sum==0?0:sum<10?1:sum<19?2:3;
    int c6 = answers[15].getScore();
    int c7 = answers[16].getScore() + answers[17].getScore();
    return c1+c2+c3+c4+c5+c6+c7;
  }

  @override
  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "date": DateConverter().dateTimeToEpoch(date).toString(),
      "token": Connection().getToken(),
      "nickname":Connection().getToken()
    };
    map['idQuestionnaire'] = id;

    Function answersToMap = (){
      Map<String, String> map = {};
      Choice answ;
      for(int i =0; i< choices.length; i++){
        answ = choices[i];
        if(i<2){
          DateTime time = DateConverter().stringToDateTime(choices[i].getValue());
          map[answ.getId()] = time.hour.toString() + ":" + time.minute.toString();
        }else map[answ.getId()] = answ.getValue();
      }
      return map;
    };
    map['answers'] = answersToMap();
    map['score'] = getScore();
    return map;
  }
}

///PSQIResultPage, estendendo QuestionnaireResultPage, visualizza il risultato ottenuto dalla compilazione di tale questionario.
// ignore: must_be_immutable
class PSQIResultPage extends QuestionnaireResultPage{
  int _score;
  PSQIResultPage(this._score, bool sent) : super(sent){
    message = sent? "Il questionario è stato inviato!":"Si è verificato un problema.\nIl questionario verrà inviato in un secondo momento.";
  }

  Widget build(BuildContext context){
    List<Widget> children = [
      SogniarioPageTitle("Risultato"),
      SogniarioCentralText(message+ "\n\nIl tuo punteggio è:",20.0, false),
      SogniarioCentralText(_score.toString(),40.0, true),
    ];

    children.addAll(
        _score<5?
        [
          SogniarioCentralText("La qualità del tuo sonno è eccellente!",20.0, false),
          SogniarioFunctionButton("Ok", null, QuestionnaireManager().getToDoPage())
        ]:
        [
          SogniarioText("La qualità del tuo sonno potrebbe migliorare.\nVuoi scoprire come?",20),
          SogniarioFunctionButton("Si", null, AIMSPage()),
          SogniarioFunctionButton("No", null, QuestionnaireManager().getToDoPage())
        ]
    );

    return Scaffold(
        appBar : SogniarioBar(false, false).build(context),
        body: Padding( padding:EdgeInsets.all(10.0),child: ListView(children: children),)
    );
  }
}

///AIMSPage contiene le raccomandazioni dell’Associazione Italiana Medicina
///del Sonno, visualizzate quando l’utente ottiene un punteggio maggiore o uguale
///a 5 nel questionario “Pittsburgh Sleep Quality Index”
class AIMSPage extends StatelessWidget{
  @override
  Widget build(BuildContext context)=>
      Scaffold(
          appBar:SogniarioBar(false, true).build(context),
          body: Padding(padding: EdgeInsets.all(5), child: ListView(children: [
            SogniarioPageTitle("Raccomandazioni dell’Associazione Italiana Medicina del Sonno."),
            SogniarioText("\n1.La stanza in cui si dorme non dovrebbe ospitare altro che l’essenziale per domire. E’ da sconsigliare la collocazione nella camera da letto di televisore, computer, scrivanie per evitare di stabilire legami tra attività non rilassanti e l’ambiente in cui si deve invece stabilire una condizione di relax che favorisca l’inizio ed il mantenimento del sonno notturno.\n",18),
            SogniarioText("2.La stanza in cui si dorme deve essere sufficientemente buia, silenziosa e di temperatura adeguata (evitare eccesso di caldo o di freddo).\n",18),
            SogniarioText("3.Evitare di assumere, in particolare nelle ore serali, bevande a base di caffeina e simili (caffè, the, coca-cola, cioccolata)\n",18),
            SogniarioText("4.Evitare di assumere nelle ore serali o, peggio, a scopo ipnoinducente , bevande alcoliche (vino, birra, superalcolici).\n",18),
            SogniarioText("5.Evitare pasti serali ipercalorici o comunque abbondanti e ad alto contenuto di proteine (carne, pesce).\n",18),
            SogniarioText("6.Evitare il fumo di tabacco nelle ore serali.\n",18),
            SogniarioText("7.Evitare sonnellini diurni, eccetto un breve sonnellino post-prandiale. Evitare in particolare sonnellini dopo cena, nella fascia oraria prima di coricarsi.\n",18),
            SogniarioText("8.Evitare, nelle ore prima di coricarsi, l’esercizio fisico di medio-alta intensità ( per es. palestra). L’esercizio fisico è invece auspicabile nel tardo pomeriggio.\n",18),
            SogniarioText("9.Il bagno caldo serale non dovrebbe essere fatto nell’immediatezza di coricarsi ma a distanza di 1-2 ore.\n",18),
            SogniarioText("10.Evitare, nelle ore prima di coricarsi, di impegnarsi in attività che risultano particolarmente coinvolgenti sul piano mentale e/o emotivo (studio; lavoro al computer; video-giochi, ecc.)\n",18),
            SogniarioText("11.Cercare di coricarsi la sera e alzarsi al mattino in orari regolari e costanti e quanto più possibile consoni alla propria tendenza naturale al sonno.\n",18),
            SogniarioText("12. Non protrarre eccessivamente il tempo trascorso a letto di notte, anticipando l’ora di coricarsi e/o posticipando l’ora di alzarsi al mattino.\n",18),
            Padding(padding: EdgeInsets.all(10.0), child: SogniarioFunctionButton("Avanti", null, QuestionnaireManager().getToDoPage()))
          ]))
      );
}