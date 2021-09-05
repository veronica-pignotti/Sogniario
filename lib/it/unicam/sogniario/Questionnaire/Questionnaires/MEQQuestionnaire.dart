import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';

import '../QuestionnaireManager.dart';
import '../QuestionnaireResultPage.dart';


/// MEQResultPage costruisce la [QuestionnaireResultPage] dedicata al Morningness
/// Eveningness Questionnaire
// ignore: must_be_immutable
class MEQResultPage extends QuestionnaireResultPage{
  int _score;
  MEQResultPage(this._score, bool sended) : super(sended);


  Widget build(BuildContext context){
    String cronotipo =
    _score<=16?"Decisamente serotino\n(gufo)":
    _score<=41?"Moderatamente serotino":
    _score<=58?"Intermedio":
    _score<=69?"Moderatamente mattutino":"Decisamente mattutino\n(allodola)";
    IconData icon = _score<=16? SogniarioIcons().get("owl"):_score>=70?SogniarioIcons().get("lark"):null;

    List<Widget> children =[
      SogniarioPageTitle("Risultato"),
      SogniarioCentralText(message+ "\n\nIl tuo punteggio è:",20.0, false),
      SogniarioCentralText(_score.toString(),40.0, true),
      SogniarioCentralText("Il tuo cronotipo è:", 20.0, false),
      SogniarioCentralText(cronotipo, 40, true)
    ];
    if(icon!= null) children.add(Center(child: Icon(icon, size: 50)));
    children.add(SogniarioFunctionButton("Ok", null, QuestionnaireManager().getToDoPage()));

    return Scaffold(
      appBar : SogniarioBar(false, false).build(context),
      body: ListView(children:children),
    );
  }
}