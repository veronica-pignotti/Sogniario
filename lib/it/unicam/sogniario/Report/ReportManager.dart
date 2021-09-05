import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:sogniario/it/unicam/sogniario/Calendar/CalendarManager.dart';
import 'package:sogniario/it/unicam/sogniario/Management/SendableManagement.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/AskPage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/ListPage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/MessagePage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/StaticPages/WaitPage.dart';
import 'package:sogniario/it/unicam/sogniario/Questionnaire/QuestionnaireManager.dart';
import 'package:sogniario/it/unicam/sogniario/Report/ReportDescriptionPage.dart';
import 'package:sogniario/it/unicam/sogniario/Report/ReportPage.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/Connection.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';

import 'ReportsWordsCloudPage.dart';

///La classe astratta IReportManager stabilisce le azioni che deve svolgere
///il controllore dei reports, quali creazione, invio e prelievo al/dal server,
///per poi costruirne le corrispondenti [ReportDescriptionPage], [ReportGraphPage]
///e [ReportWordsCloudPage]. Inoltre implementa [SendableManager].
abstract class IReportManager extends SendableManager{

  ///L'istanza di [ReportsWordsCloudPage] generata
  @protected
  ReportsWordsCloudPage reportsWordsCloudPage;

  ///L'istanza di [IReport] registrato
  @protected
  IReport lastReport;

  ///Crea o aggiorna [_reportsWordsCloudPage], scaricando dal server la mappa
  ///parola-valore di tutti i reports dell'utente
  @protected
  Future<bool> loadWordsCloudPage();

  ///Crea l'istanza di [Report] con il testo passato e lo invia al server.
  /// Ritorna la prossima pagina da visualizzare.
  @protected
  Widget confirm(String text);

  ///Ritorna la pagina da visualizzare dopo l'invio di un report
  Widget getNext(bool sent);

  ///Richiede al server i report dell'utente con data [date].
  ///Se non presenti, ritorna null.
  ///Se l'utente ha registrato un solo sogno, ritorna la [ReportDescriptionPage] dedicata.
  ///Se l'utente ha registrato più sogni, ritorna la lista di [ReportDescriptionPage] dedicate.
  Future<Widget> getReportsOf(DateTime date);

  ///Ritorna la [ReportDescriptionPage] del report passato
  @protected
  ReportDescriptionPage getReportDescriptionPage(IReport report) =>
      ReportDescriptionPage(report);

  ///Ritorna l'[ItemListPage] del report avente come testo [text] e data [date];
  @protected
  ItemListPage getItemListReportDescriptionPage(IReport report) =>
      ItemListPage(
        report.getText().length > 20 ? report.getText().substring(0, 20) + "..." : report.getText(),
        SogniarioIcons().get('graph'),
        ()=>getReportDescriptionPage(report)
      );

  ///Ritorna la nuvola di parole se presente, altrimenti una [MessagePage]
  @protected
  Widget getReportsWordsCloudPage() =>
      reportsWordsCloudPage!=null?
      reportsWordsCloudPage:
      FutureBuilder(
        future: loadWordsCloudPage(),
        builder: (context, snap)=>
          !snap.hasData? WaitPage():
          snap.data?reportsWordsCloudPage:
          MessagePage("Nuvola di parole non dispobilile.\nConnettiti ad internet o registra almeno un sogno per visualizzarla.", true)
    );


  ///Ritorna la [ItemListPage] della nuvola di parole
  @protected
  ItemListPage getItemListReportWordCloudPage() =>
      ItemListPage("Nuvola di parole", SogniarioIcons().get('cloud'), ()=>getReportsWordsCloudPage());

  ///Ritorna una [ReportPage]
  ReportPage getReportPage() => ReportPage(this);

  ///Ritorna l'[ItemListPage] di una [ReportPage]
  ItemListPage getItemListReportPage() =>
    ItemListPage("Racconta un sogno", SogniarioIcons().get('dream'), ()=>getReportPage());

  ///Ritorna l'[ItemListPage] della pagina con cui è possibile accedere alle
  ///diverse rappresentazioni dei report
  ItemListPage getItemListReportsRepresentation()=>
    ItemListPage(
      "I miei sogni",
      SogniarioIcons().get("dreams"),
      ()=>ListPage(
        "",
        [CalendarManager().getItemListCalendarPage(), getItemListReportWordCloudPage()],
        false,
        true
      )
    );

  ///Ritorna l'ultimo [IReport] registrato
  IReport getLastReport()=>lastReport;

}

///ReportManager è la classe concreta che estende [IReportManager] e se l’invio
///di un report va a buon fine, ricerca nella cache dei reports rimasti e li invia,
///cancellandoli per evitare duplicati.
class ReportManager extends IReportManager{
  static final ReportManager _instance = ReportManager._internal();

  factory ReportManager()=>_instance;

  ReportManager._internal();

  Future<void> init()async{
      await find();
  }

  Future<bool> loadWordsCloudPage()async{
    ConnectionResponse response = await connection.call("getReportsMap", Connection().getToken());
    reportsWordsCloudPage =
      response.getOk() && !jsonDecode(response.getData())['empty']?
        ReportsWordsCloudPage(jsonDecode(response.getData())['percent']):
        null;
    return reportsWordsCloudPage!=null;
  }

  ///Crea l'istanza di [Report] con il testo passato e lo invia al server.
  ///Se l'invio va a buon fine:
  ///- ricerca nella cache i report salvati temporaneamente e li invia;
  ///- aggiorna [_reportsWordsCloudPage];
  /// altrimenti viene salvato in cache.
  /// Ritorna la prossima pagina da visualizzare.
  Widget confirm(String text){
    if (text == "") return null;
    Function conf = ()async {
      DateTime date = DateTime.now();
      text = StringConverter().deleteAccentedLetters(text);
      lastReport = Report(text, date);
      String json = jsonEncode(lastReport.toMap());
      ConnectionResponse resp = await connection.call("postReport", json);
      bool sent = resp.getOk();
      if (sent) {
        await QuestionnaireManager().loadReportQuestionnaireOf(lastReport);
        await find();
        await loadWordsCloudPage();
      } else {
        cache.insertInList("Report", json);
        print("Qualcosa è andato storto. Il report appena registrato verrà salvato in cache con chiave \"Report\".");
      }
      return sent;
    };

    return FutureBuilder(
      future: conf(),
      builder: (context, snap)=>
        snap.hasData?
          getNext(snap.data):
          WaitPage()
    );
  }

  Widget getNext(bool sent)=>
    AskPage(
      sent?
        "Il sogno è stato inviato.":
        "Si è verificato un problema.\nIl sogno verrà inviato in un secondo momento. Non sarà possibile visualizzarlo nella nuvola dei sogni.",
     [SogniarioFunctionButton("Ok", null, QuestionnaireManager().getReportQuestionnairePage())]);


  Widget getAskPageReportRepresentation() {
    List<SogniarioFunctionButton> buttons = [SogniarioFunctionButton("Si, tramite un grafo", null, ReportDescriptionPage(lastReport)),];
    if(reportsWordsCloudPage!= null)
      buttons.add(SogniarioFunctionButton(
        "Si, tramite la nuvola delle parole (rappresentazione di tutti i tuoi sogni registrati)",
        null,
        getReportsWordsCloudPage()));
    buttons.add(SogniarioFunctionButton("No", null, getReportEndProcedure()));
    return AskPage("Vuoi vedere la rappresentazione del sogno appena registrato?", buttons);
  }

  ///Ritorna la pagina finale della parte dell'applicazione dedicata all'invio di un report
  Widget getReportEndProcedure() =>
      AskPage(
          "Cosa vuoi fare adesso?",
          [
            SogniarioFunctionButton("Raccontare un altro sogno", null, getReportPage()),
            SogniarioFunctionButton("Andare nel menu",null,MenuPage())
          ]
      );

  Future<Widget> getReportsOf(DateTime date) async{
    ConnectionResponse resp = (await connection.call("getReports", jsonEncode({
      "token" : connection.getToken(),
      "date1": (DateConverter().dateTimeToEpoch(DateTime(date.year, date.month, date.day))).toString(),
      "date2": (DateConverter().dateTimeToEpoch(DateTime(date.year, date.month, date.day, 23,59,59))).toString()
    })));
    if(!resp.getOk()|| resp.getData().isEmpty)
      return null;

    List<dynamic> reports = jsonDecode(resp.getData())[connection.getToken()];
    return reports.length==1?
       getReportDescriptionPage(
         Report(
           StringConverter().insertAccentedLetters(reports[0]['text']),
           date
         )
      ):
      ListPage(
        "Sogni registrati il giorno " + DateConverter().dateToString(date),
        reports.map((rep) =>getItemListReportDescriptionPage(Report(rep['text'], date))).toList(),
        false,
        true
      );
  }

  @override
  Future<void> find() async{
    List<String> list = cache.getValuesList("Report"), newList = [];
    if(list.isEmpty) return;
    bool sent;
    Map<String, dynamic> json;
    IQuestionnaireManager qm = QuestionnaireManager();
    list.forEach((rep)async{
      sent = (await connection.call("postReport", rep)).getOk();
      if(!sent) newList.add(rep);
      else{
        json = jsonDecode(rep);
        await qm.loadReportQuestionnaireOf(Report(json['text'], DateConverter().epochToDateTime(int.parse(json['date']))));
      }
    });
    await cache.delete("Report");
    if(newList.isNotEmpty) await cache.insertInList("Report", newList);
  }

}

///IReport è la classe astratta che stabilisce la struttura di un oggetto report;
///trattandosi della rappresentazione di un dato che deve essere salvato nel repository,
///estende [Sendable], implementando quanto necessario; ha come unico campo [text],
///che conterrà il testo del sogno, ed eredita il campo [date] dalla classe padre.
///Ad ogni report, corrispondono una lista di questionari dedicati.
abstract class IReport extends Sendable{
  /// Il testo del sogno
  String text;

  IReport(this.text, DateTime date) : super(date);

  @override
  Map<String,dynamic> toMap(){
    Map<String, dynamic> map = super.toMap();
    map["text"] = text;
    return map;
  }

  String getText()=>text;

}

///Rappresenta il report, ovvero, la registrazione del sogno
/// Il report è la registrazione del sogno, unita alla sua data e ora di creazione.
/// Estende [IReport]
class Report extends IReport{

  Report(String text, DateTime date) : super(text, date);

}