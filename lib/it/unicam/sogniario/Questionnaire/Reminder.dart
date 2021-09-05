import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sogniario/it/unicam/sogniario/Management/AccessManagement.dart';
import 'package:sogniario/it/unicam/sogniario/Questionnaire/QuestionnaireManager.dart';
import 'package:sogniario/it/unicam/sogniario/Questionnaire/ReminderPage.dart';
import 'package:sogniario/it/unicam/sogniario/Report/ReportManager.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/Cache.dart';

import 'Questionnaire.dart';
///IReminder è il contratto che ogni gestore di oggetti [IPostIt] deve rispettare.
///Infatti deve essere in grado di:
///- salvare [IPostIt] sia in locale, sia sulla cache;
///- recuperarli dalla cache e tenerli sempre aggiornati con quelli in locale;
///- caricarli su richiesta del [IQuestionnaireManager];
///- fornire widget appropriati riguardanti i questionari da compilare, tramite un'istanza di [IReminderPage] .
abstract class IReminder extends Manager{
  /// La lista dei questionari da compilare il giorno della visita dell'utente all'applicazione
  @protected
  List<IPostIt> toDoAndDone = [];

  @protected
  Cache cache;

  @protected
  QuestionnaireManager questionnaireManager;

  @protected
  IReminderPage reminderPage;

  IReminder(this.questionnaireManager);

  /// Carica i questionari da compilare a seconda del booleano passato.
  Future<void> load(List<IQuestionnaire> questionnaires);

  ///Ritorna true se ci sono questionari da compilare nel presente. False altrimenti
  bool hasToCompile()=>getToDoToday().isNotEmpty;

  ///Crea un'istanza di [IPostIt] utilizzando le informazioni passate e lo carica nella cache.
  Future<void> putToDoAndDone(String name, bool toDo, IQuestionnaire questionnaire, {int date, Map<String, dynamic> data});

  ///Restituisce la lista dei nomi dei questionari da compilare nel giorno in cui
  ///viene chiamato tale metodo.
  List<IPostIt> getToDoToday()=>
      toDoAndDone
        .where((postIt) =>
            postIt.getTodo() &&
            postIt.getWhen() <=
                DateTime(DateTime.now().year, DateTime.now().month,
                        DateTime.now().day, 23, 59, 59)
                    .millisecondsSinceEpoch)
        .toList();

  ///Restituisce la lista di [IPostIt] riguardanti i questionari di fine report (tipo 1)
  List<IPostIt> getReportsQuestionnaireToDo()=>
    getToDoToday().where(
            (postIt) => postIt.getQuestionnaire().isOfType(1)
    ).toList();

  ///Inserisce la lista di [IPostIt] passata nella cache
  Future<void> putAllToDoAndDone(List<PostIt> list);

  ///Carica ogni questionario passato nella cache, facendo riferimento al [IReport] passato
  Future<void> loadReportQuestionnaire(List<IQuestionnaire> byType, IReport report);

  ///Restituisce un widget dedicato ai questionari da compilare
  Widget getToDoPage();

  ///Restituisce un widget dedicato ai questionari di fine report da compilare
  Widget getReportQuestionnairePage();

}

class Reminder extends IReminder{
  Reminder(QuestionnaireManager questionnaireManager) : super(questionnaireManager);


  void init(){
    cache = Cache();
    reminderPage = ReminderPage();
  }

  /// Se è stato effettuato il primo accesso, i questionari da compilare sono quelli di tipo 0,
  /// quindi vengono filtrati dai questionari scaricati dal server.
  /// Altrimenti filtra con l'aiuto del [IReminder], i questionari da compilare,
  /// ovvero quelli contrassegnati da quest'ultimo e quelli che non sono di tipo 1 (fine report).
  /// In questo modo verranno considerati anche gli ultimi questonari creati.
  /// Così si crea la mappa [toCompile].
  Future<void> load(List<IQuestionnaire> questionnaires)async{
    toDoAndDone.clear();

    if(AccessManager().getFirstAccess())
      toDoAndDone = questionnaires
          .where((q1) => q1.isOfType(0))
          .map((q2) => PostIt(
              q2.getName(), true, DateTime.now().millisecondsSinceEpoch,
              questionnaire: q2.reset()))
          .toList();
    else{

      List<IPostIt> fromcache = await _takeToDoAndDone();
      print("\n\nPost it dalla cache");
      fromcache.forEach((p) { print("Nome: "+ p.getName() + "   Da fare: " +p.getTodo().toString()); });


      //assegno i questionari solo se sono da fare
      toDoAndDone = fromcache.map((p)=>
        p.getTodo()?
          p.setQuestionnaire(questionnaires.firstWhere((q) => q.getName() == p.getName(), orElse: () => null)):
          p
      ).toList();

      //filtro i questionari nuovi
      questionnaires.forEach((q) {
        if(
          toDoAndDone.firstWhere((p) => p.getName() == q.getName(), orElse: ()=>null) == null &&
          !q.isOfType(1)
        ) toDoAndDone.add(PostIt(q.getName(), true, DateTime.now().millisecondsSinceEpoch, questionnaire: q.reset()));

      });
    }

    print("\n\nPost it caricati");
    toDoAndDone.forEach((p) { print("Nome: "+ p.getName() + "   Da fare: " +p.getTodo().toString());});

    await _putAllToDoAndDone();
  }

  Future<void> loadReportQuestionnaire(List<IQuestionnaire> questionnaires, IReport report) async {
    toDoAndDone.addAll(
      questionnaires.map(
        (q) =>
          PostIt(
            q.getName(),
            true,
            report.getDate().millisecondsSinceEpoch, data: report.toMap(), questionnaire: q.reset().setData(report.toMap())
          )
      ).toList()
    );

    await _putAllToDoAndDone();
  }

  Future<void> putToDoAndDone(String name, bool toDo, IQuestionnaire questionnaire, {int date, Map<String, dynamic> data})async{
    if(date == null) date = DateTime.now().millisecondsSinceEpoch;
    if(questionnaire.isOfType(1))
      toDoAndDone.removeWhere((p) => p.getName() == name && p.getData().toString() == data.toString());
    else toDoAndDone.removeWhere((p) => p.getName() == name);
    toDoAndDone.add(PostIt(name, toDo, date, data:data, questionnaire: questionnaire));

    await _putAllToDoAndDone();
  }

  ///Preleva dalla [cache] la lista dei json salvati
  Future<List<PostIt>> _takeToDoAndDone()async{
    List<String> jsonList = cache.getValuesList("ToDoAndDone");
    if(jsonList.isEmpty) return [];
    return jsonList.map((str){
      Map<String, dynamic> map = jsonDecode(str);
      return PostIt(map['name'], map["todo"] == "true", int.parse(map["when"]), data: map['data']);
    }).toList();
  }


  ///Inserisce nella cache la lista [list] di [PostIt], ognuno trasformato in json
  Future<void> _putAllToDoAndDone() async{
    await cache.delete("ToDoAndDone");
    await cache.insertInList("ToDoAndDone",toDoAndDone.map((p) => p.toString()).toList());
  }

  @override
  Future<void> putAllToDoAndDone(List<PostIt> list)async{
    toDoAndDone = list;
    await _putAllToDoAndDone();
  }


  @override
  Widget getToDoPage()=>
    reminderPage.getToDoPage(getToDoToday());


  @override
  Widget getReportQuestionnairePage()=>
    reminderPage.getReportQuestionnairePage(getReportsQuestionnaireToDo());

}

///Definisce la struttura base e le azioni che un promemoria deve avere.
///Infatti è composto da:
///- il nome [name] dell'oggetto che rappresenta;
///- un booleano [todo] che indica se l'oggetto è da ricordare o meno;
///- una data [when] che a seconda di [todo] indica il giorno in cui ricordare
///l'oggetto ([todo] == true) o il giorno in cui è stato completato ([todo] == false)
abstract class IPostIt{
  ///Il nome dell'oggetto che rappresenta
  @protected
  String name;
  ///Indica se l'oggetto è da ricordare o meno
  @protected
  bool todo;

  ///Se l'oggetto è da ricordare, indica la data in cui deve avvinire ciò,
  ///altrimenti indica la data della compilazione.
  @protected
  int when;

  ///Il questionario a cui si riferisce il post it
  @protected
  IQuestionnaire questionnaire;

  ///Insieme di dati da associare al postit e/o al questionario
  @protected
  Map<String, dynamic> data;

  IPostIt(this.name, this.todo, this.when, {this.data, this.questionnaire});

  ///Trasforma in json l'oggetto
  String toJson() => toString();

  String toString();

  /// Ritorna il nome dell'oggetto che rappresenta
  String getName()=> name;

  ///Indica se l'oggetto è da ricordare o meno
  bool getTodo()=>todo;

  ///Se l'oggetto è da ricordare, ritorna la data in cui deve avvinire ciò,
  ///altrimenti ritorna la data della compilazione.
  int getWhen()=>when;

  ///Ritorna l'nsieme di dati da associare al postit e/o al questionario
  Map<String, dynamic> getData()=> data;

  /// Imposta il questionario
  IPostIt setQuestionnaire(IQuestionnaire quest){
    questionnaire = quest;
    return this;
  }

  IQuestionnaire getQuestionnaire()=> questionnaire;

}

///Rappresenta un promemoria.
class PostIt extends IPostIt{

  PostIt(String name, bool todo, int when, {Map<String, dynamic> data, IQuestionnaire questionnaire}):
        super(name, todo, when, data:data, questionnaire:questionnaire);

  ///Trasforma in json l'oggetto
  String toString()=>
      jsonEncode({
        "name":name,
        "todo":todo.toString(),
        "when":when.toString(),
        "data": data
      });

}