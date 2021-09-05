import 'package:flutter/material.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';

import 'ReportGraph.dart';
import 'ReportGraphPage.dart';
import 'ReportManager.dart';

///ReportDescriptionPage fornisce una pagina descrittiva di uno specifico report,
///comprendendo data, testo, punteggio e grafo, che sarà poi rappresentato tramite
///un grafo e visualizzato premendo il bottone “Guarda grafo” nella medesima pagina.
/// Questo widget viene raggiunto dalla pagina del calendario, [CalendarPage], e,
/// trattando di report, viene creato dal [ReportManager].
class ReportDescriptionPage extends StatelessWidget{
  ///L'istanza di report descritto
  final Report _report;

  ReportDescriptionPage(this._report);

  @override
  Widget build(BuildContext context) {
    ReportGraph graph = ReportGraph(_report.getText());
    return Scaffold(
      appBar: SogniarioBar(false, true).build(context),
      body: Padding(
          padding: EdgeInsets.all(10),
          child:ListView(children: [
            SogniarioPageTitle("Sogno del giorno ${DateConverter().dateToString(_report.date)}"),
            SogniarioText('\n> Testo:\n"${StringConverter().insertAccentedLetters(_report.getText())}\n"> Numero di parole: ${graph.getScore().toString()}', 20.0),
            SogniarioFunctionButton("Guarda grafo", null,ReportGraphPage(graph))
          ])
      ));
  }

}