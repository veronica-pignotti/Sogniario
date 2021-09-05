import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sogniario/it/unicam/sogniario/Management/SendableManagement.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/StaticPages/WaitPage.dart';
import 'package:sogniario/it/unicam/sogniario/Questionnaire/Reminder.dart';
import 'package:sogniario/it/unicam/sogniario/Report/ReportManager.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/Cache.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/Connection.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';
import 'package:sogniario/it/unicam/sogniario/Questionnaire/Questionnaire.dart';

import 'QuestionnairePage.dart';
import 'QuestionnaireResultPage.dart';
import 'Questionnaires/MEQQuestionnaire.dart';
import 'Questionnaires/PSQIQuestionnaire.dart';

///Un oggetto complesso come il IQuestionnaire, ha bisogno di una figura apposita
///che lo gestisce. La classe astratta IQuestionnaireManager nasce per supportare
///questa necessità, consentendo al controllore di questo elemento di:
/// - richiedere i questionari al server;
/// - restituire su richiesta widget che ne supportano la compilazione, obbligatoria o opzionale;
/// - selezionare un questionario per poi compilarlo aggiungendo risposte.
abstract class IQuestionnaireManager extends SendableManager{

  ///L'istanza della cache
  @protected
  Cache cache;

  ///Lista dei questionari disponibili
  @protected
  List<IQuestionnaire> questionnaires = [];

  /// il questionario selezionato per la compilazione
  @protected
  IQuestionnaire selected;

  ///L'istanza del [IReminder]
  @protected
  IReminder reminder;

  ///Richiede al server i questionari
  @protected
  Future<void> load();

  ///Ricarica la lista dei questionari compilati e da compilare, sfruttando la mappa passata
  ///[lastCompletedMap], dove le chiavi sono i nomi dei questionari e i valori sono
  ///la data della loro compilazione
  Future<void> reloadCache(Map<String, dynamic> lastCompletedMap);

  ///Restituisce i questionari di tipo type, il parametro only specifica se i
  ///questionari devono essere SOLO del tipo specificato (only = true) o sono
  ///ammessi altri tipi, incluso type (only == false).
  List<IQuestionnaire> getByType(int type, bool only) =>
      only?
      questionnaires.where((q) => q.getTypes().length == 1 && q.isOfType(type)).toList():
      questionnaires.where((q) => q.isOfType(type)).toList();

  /// Restituisce true se sono presenti questionari, false altrimenti.
  bool hasQuestionnaires() => questionnaires.isNotEmpty;

  ///Ignora momentaneamente il questionario con il nome passato
  Future<void> skip(String name) async =>
      await reminder.putToDoAndDone(name, true, selected);

  ///Conferma e invia il questionario [selected] solo se completo
  Future<Widget> confirm();

  ///Elabora la pagina da visualizzare dopo la conferma del questionario
  Widget getNext(IQuestionnaire questionnaire, int score, bool sent);

  ///Ritorna true se il questionario con il nome passata contiene il tipo type. false altrimenti.
  bool isOfType(String name, int type) =>
      questionnaires.firstWhere((q) => q.getName() == name).getTypes().contains(type);

  /// Risponde alla domanda con id [idQuestion], specificando il valore della
  /// risposta [answer] e se si tratta di una domanda a risposta aperta oppure no.
  void answer(String idQuestion, String answer, bool withScore) =>
      selected.add(Choice(idQuestion, answer, withScore));

  ///Restituisce la risposta fornita alla domanda con id [questionId]
  String getAnswerOf(String questionId)=>
      selected.getAnswerOf(questionId);

  /// Restituisce true se ci sono questionari da compilare, false altrimenti
  bool hasToCompile() => reminder.hasToCompile();

  ///Carica i questionari di fine report (tipo 1) facendo riferimento al report passato
  Future<void> loadReportQuestionnaireOf(IReport report) async=>
      await reminder.loadReportQuestionnaire(getByType(1, false), report);

  ///Restituisce la [ItemListPage] dedicata ai questionari da compilare
  ItemListPage getItemListToDo() =>
      ItemListPage(
          "Questionari",
          SogniarioIcons().get('questionnaire'),
          ()=>getToDoPage()
      );

  ///Restituisce un widget dedicato ai questionari da compilare
  Widget getToDoPage() =>
    hasQuestionnaires()? reminder.getToDoPage():
    FutureBuilder(
      future: init(),
      builder: (context, snap) => snap.connectionState == ConnectionState.done? reminder.getToDoPage(): WaitPage()
    );


  ///Restituisce un widget dedicato ai questionari di fine report da compilare
  Widget getReportQuestionnairePage() =>
    hasQuestionnaires()? reminder.getReportQuestionnairePage():
    FutureBuilder(
      future: init(),
      builder: (context, snap) => reminder.getReportQuestionnairePage()
    );

  ///Imposta il questionario che si va a compilare
  void setSelected(IQuestionnaire questionnaire) => selected = questionnaire;

  ///Ritorna la [QuestionnairePage] del questionario passato
  Widget getQuestionnairePage(IQuestionnaire questionnaire)=>
      QuestionnairePage(
          QuestionnaireManager(),
          questionnaire.reset(),
          SogniarioBar(!questionnaire.isOfType(0), true)
      );

}

///QuestionnaireManager, classe concreta che implementa la precedente, si occupa
///di mettere a disposizione i questionari. Dopo essere stati richiesti dal server,
///il sistema li proporrà all’utente a seconda delle situazioni; infatti vengono
///prelevati tramite i tipi, oppure tramite la collaborazione con il Reminder,
///di cui si parlerà più avanti. Solo il QM inizializza e collabora con il [IReminder].
class QuestionnaireManager extends IQuestionnaireManager{

  static final QuestionnaireManager instance = QuestionnaireManager.internal();
  factory QuestionnaireManager() => instance;
  QuestionnaireManager.internal();

  Future<void> init()async{
    cache = Cache();
    if(!hasQuestionnaires()) await load();

    if(reminder == null) reminder = Reminder(this);
    reminder.init();
    if(hasQuestionnaires()) await reminder.load(questionnaires);
  }

  Future<void> load() async {
    ConnectionResponse response = await Connection().call("getQuestionnaires", null);

    if (!response.getOk()) return false;
    List<dynamic> questionnairesList = jsonDecode(response.getData());
    if (questionnairesList.isNotEmpty)
      questionnaires = questionnairesList.map((m) => Questionnaire(m, DateTime.now())).toList();
    return questionnaires.isNotEmpty;
  }


  Future<void> reloadCache(Map<String, dynamic> lastCompletedMap)async{
    String name;
    DateTime date;
    List<PostIt> list = [];
    reminder = Reminder(this);
    await reminder.init();

    questionnaires.forEach((quest)async {
      name = quest.getName();
      if(lastCompletedMap.containsKey(quest.getName())){
        date = DateConverter().epochToDateTime(int.parse(lastCompletedMap[name]));
        if(quest.isOfType(2)) // è da ricordare tra un mese
          list.add(PostIt(name, true, date.add(Duration(days: 30)).millisecondsSinceEpoch, questionnaire: quest));
        else list.add(PostIt(name, false, date.millisecondsSinceEpoch));
      }
    });

    print("Postit dedotti:");
    list.forEach((p) {print(p.toString()); });
    await reminder.putAllToDoAndDone(list);
    await init();

  }


  /// Poiché non si possono confermare questionari incompleti, [completed] verrà
  /// inviato solo se contiene le risposte a tutte le domande.
  /// Se non viene soddisfatta questa condizione, ritorna null, per poi generare
  /// un messaggio di errore.
  /// Se, invece, l'utente compila l'intero questionario, il [IQuestionnaireManager]
  /// viene notificato di tale azione, permettendosi di cancellare [questionnaire]
  /// dalla mappa dei questionari da compilare.
  Future<Widget> confirm()async{

    if(!selected.isComplete()) return null;

    Map<String, dynamic> completedMap = {"completedQuest":selected.toMap()};
    String json = jsonEncode(completedMap);

    bool sent = (await connection.call("postQuestionnaire", json)).getOk();
    if(sent) await find();
    else await cache.insertInList("Questionnaire", json );

    String name = selected.getName();
    if(isOfType(name, 2)) await reminder.putToDoAndDone(name, true, selected, date:DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch);
    else if(isOfType(name, 1)) await reminder.putToDoAndDone(name, false, selected, data: selected.getData());
    else await reminder.putToDoAndDone(name, false, selected);


    return getNext(selected, completedMap['completedQuest']['score'] as int, sent);
  }


  Widget getNext(IQuestionnaire questionnaire, int score, bool sent){
    String name = questionnaire.getName();
    if(name == "Pittsburgh Sleep Quality Index") return PSQIResultPage(score, sent);
    if(name == "Morningness Eveningness Questionnaire") return MEQResultPage(score, sent);
    if(questionnaire.isOfType(1)) return QuestionnaireResultPage(sent, isReportQuestionnaire: true) ;
    if(!questionnaire.isOfType(3)) return reminder.getToDoPage();

    return QuestionnaireResultPage(sent);
  }

  @override
  Future<void> find() async{
    List<String> list = cache.getValuesList("Questionnaire"), newList = [];
    if(list.isEmpty) return;
    int size = list.length;
    String comp;
    for(int i = 0; i < size; i++){
      comp = list[i];
      if(!(await connection.call("postQuestionnaire", comp)).getOk())
        newList.add(comp);
    }

    await cache.delete("Questionnaire");
    if(newList.isNotEmpty) await cache.insertInList("Questionnaire", newList);
  }

}