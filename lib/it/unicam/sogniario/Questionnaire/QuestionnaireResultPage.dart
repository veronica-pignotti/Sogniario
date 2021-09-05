import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/AskPage.dart';

import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';
import 'package:sogniario/it/unicam/sogniario/Questionnaire/QuestionnaireManager.dart';


///QuestionnaireResultPage è una pagina che comunica la buona riuscita o meno
///dell’invio del questionario appena compilato.
// ignore: must_be_immutable
class QuestionnaireResultPage extends StatelessWidget{
  ///indica se il questionario appena compilato è stato inviato correttamente al server
  bool sent;
  ///il messaggio da visualizzare
  String message;

  bool isReportQuestionnaire = false;


  QuestionnaireResultPage(this.sent, {this.isReportQuestionnaire}){
    message = sent?
      "Il questionario è stato inviato!":
      "Si è verificato un problema.\nIl questionario verrà inviato in un secondo momento.";
  }

  @override
  Widget build(BuildContext context) =>
      AskPage(message, [SogniarioFunctionButton("Ok", null, isReportQuestionnaire!= null && isReportQuestionnaire? QuestionnaireManager().getReportQuestionnairePage(): QuestionnaireManager().getToDoPage())]
  );

}