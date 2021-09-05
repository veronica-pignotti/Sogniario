import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/MessagePage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/StaticPages/WaitPage.dart';

import '../Pages/GraphicElements.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

import 'CalendarManager.dart';

///CalendarPage è la pagina del calendario, creato grazie la libreria di Flutter
///table_calendar (https://pub.dev/packages/table_calendar) e gestita da un istanza di[ICalendarManager].
/// L’utente, quindi, può visualizzare sottoforma di grafo i report da lui registrati
/// in un determinato giorno, semplicemente cliccando sul medesimo. Grazie a questo
/// evento, il manager li chiederà al [ReportManager], il quale passerà
/// la richiesta a [Connection]. Se non esistono racconti dell’utente con quella
/// data, viene visualizzato un messaggio di errore; altrimenti, per ogni testo
/// ritornato, RM provvederà a creare la propria [ReportDescriptionPage], con la
/// quale poi si potrà passare alla [ReportGraphPage] dedicata.
/// La pagina visualizzata quindi sarà:
/// • una [ReportDescriptionPage], se è stato ritornato soltanto un testo;
/// • una [ListPage] che raggruppa le ReportDescriptionPage create se l'utente ha registrato più sogni.
// ignore: must_be_immutable
class CalendarPage extends StatefulWidget{
  /// Il manager che gestisce il calendario
  ICalendarManager _manager;

  CalendarPage(this._manager);

  @override
  _CalendarPageState createState() => _CalendarPageState(_manager);
}

class _CalendarPageState extends State<CalendarPage> {
  /// Il manager che gestisce il calendario
  ICalendarManager _manager;

  ///Il messaggio di errore da visualizzare
  String _message = "";

  /// Il controller necessario per il funzionamento del calendario
  CalendarController _calendarController;

  ///La data del primo accesso dell'utente
  DateTime _start;

  _CalendarPageState(this._manager) {
    _manager = CalendarManager();
    _start = _manager.getStartDay();
    initializeDateFormatting('it');
    _calendarController = CalendarController();
  }

  /// Visualizza un messaggio di errore se non esistono reports registrati
  /// dall'utente nella data [date] passata, altrimenti la pagina adeguata.
  void _getReports(DateTime date) async {
    try{
      setState(() => _message = "");
      Widget next = FutureBuilder(
        future: _manager.getReports(date),
        builder: (BuildContext context, AsyncSnapshot snap)=>
        snap.connectionState != ConnectionState.done? WaitPage():
            snap.data == null?
              MessagePage("In questo giorno non hai registrato alcun sogno, oppure la sua visualizzazione non è al momento disponibile.", false):
                snap.data
      );
      Navigator.push(context, MaterialPageRoute(builder: (context)  => next));
    }catch(e){
      setState(() {_message = "Al momento non è possibile visualizzare alcun grafo.";});
    }
  }

  Widget build(BuildContext context) =>
    Scaffold(
      appBar: SogniarioBar(false, true).build(context),
      body:
      Padding(padding: EdgeInsets.all(10), child:ListView(children: [
        SogniarioPageTitle("Calendario"),
        SogniarioText("Seleziona un giorno per vedere i grafi relativi ai sogni che hai registrato durante tale giornata", 20),
        TableCalendar(
          locale: "it_IT",
          calendarController: _calendarController,
          calendarStyle: CalendarStyle(
            weekdayStyle: TextStyle(fontSize: 22.0, fontFamily: "Arimo"),
            selectedColor: SogniarioColors().get(1),
            selectedStyle: TextStyle(color: Colors.black, fontSize: 24.0)
          ),
          startDay: _start,
          endDay: DateTime.now(),
          onDaySelected: (date, list1, list2) => _getReports(date),
        ),
        SogniarioMessage(_message)
      ])
    ));
}