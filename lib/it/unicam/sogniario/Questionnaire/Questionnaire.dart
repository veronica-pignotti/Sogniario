import 'package:flutter/cupertino.dart';
import 'package:sogniario/it/unicam/sogniario/Management/SendableManagement.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';

///IQuestionnaire introduce la struttura di un questionario, composta da:
/// - un id;
/// - il nome del questionario;
/// - una descrizione;
/// - una lista di numeri che identificano il tipo del questionario nel seguente modo:
///   - tipo 0: questionario richiesti al primo accesso;
///   - tipo 1: questionario di fine report;
///   - tipo 2: questionario periodici (mensili);
///   - tipo 3: questionario opzionali;
/// - la lista di domande di tipo [IQuestion];
/// - la lista delle risposte fornite dall'utente di tipo [IChoice];
/// - una mappa di dati extra da allegare al questionario (opzionale)
abstract class IQuestionnaire extends Sendable{
  ///L'istanza di [StringConverter] per effettuare le conversioni ai testi
  @protected
  StringConverter stringConverter;

  /// l'id del questionario
  @protected
  String id;

  /// Il nome del questionario
  @protected
  String name;

  ///La descrizione del questionario
  @protected
  String description;
  /// La lista di tipi relativi al questionario che descrivono le caratteristiche del questionario
  @protected
  List<int> types;

  /// La lista delle domande
  @protected
  List<IQuestion> questions;

  ///La lista delle risposte dell'utente
  @protected
  List<IChoice> choices;

  ///Insieme di dati extra da allegare al questionario
  @protected
  Map<String, dynamic> data;

  @protected
  int score = 0;

  IQuestionnaire(DateTime date) : super(date);

  ///Ritorna l'id del questionario
  String getId() => id;
  ///Ritorna il nome del questionario
  String getName() => name;
  ///Ritorna la descrizione del questionario
  String getDescription() => description;
  ///Ritorna la lista dei tipi del questionario
  List<int> getTypes() => types;

  ///Ritorna la lista di domande di tipo [Question] del questionario
  List<IQuestion> getQuestions() => questions;

  /// Aggiunge una risposta
  void add(IChoice answer);

  /// Determina se il questionario è completo oppure no
  bool isComplete()=>
    questions.length == choices.length;


  /// Ritorna la risposta alla domanda con id [id]
  String getAnswerOf(String id)=>
      choices.firstWhere((a) => a.getId() == id, orElse: ()=>Choice(id, "", false)).getValue();

  ///Ritorna la lista di risposte
  List<IChoice> getAnswers() => choices;

  ///Ritorna il punteggio
  int getScore();

  IQuestionnaire setData(Map<String, dynamic> data) {
    this.data = data;
    return this;
  }

  IQuestionnaire setDescription(String newDescr) {
    this.description = newDescr;
    return this;
  }

  Map<String, dynamic> getData()=> data;

  IQuestionnaire reset(){
    choices.clear();
    return this;
  }

  bool isOfType(int type)=> types.contains(type);
}

/// [IQuestionnaire] è implementata da Questionnaire, che consente la trasformazione
/// dei questionari in formato json scaricati dal server, nell’oggetto corrispondente.
/// Ogni questionario staziona sul database dell’applicazione e può essere creato
/// dai ricercatori, personalizzando le loro richieste, o può essere già esistente,
/// come la versione italiana del Pittsburgh Sleep Quality Index e il Morningness
/// Eveningness Questionnaire.
class Questionnaire extends IQuestionnaire{

  /// Trasforma la mappa [map] nell'oggetto [Questionnaire] corrispondente.
  /// I questionari vengono creati a partire dalla loro importazione sottoforma di mappe dal server.
  /// [map], nel campo contrassegnato con 'questions', contiene a sua volta una lista di mappe, che rappresentano le domande.
  Questionnaire(dynamic map, DateTime date):super(date){
    stringConverter = StringConverter();
    id = map['id'];
    name = stringConverter.insertAccentedLetters(map['name']);
    description = stringConverter.insertAccentedLetters(map.containsKey('description')?map['description']:"");
    types = [];
    map['types'].forEach((t){types.add(t as int);});
    questions = [];
    for(int i =0; i< map['questions'].length; i++)
      questions.add(Question(map['questions'][i], i, map['questions'].length));
    choices = [];
  }

  @override
  void add(IChoice answer) {
    choices.removeWhere((c) => c.getId() == answer.getId());
    choices.add(answer);
  }

  @override
  int getScore(){
    choices.forEach((a) {
      score+= a.getScore();
    });
    return score;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();
    map['idQuestionnaire'] = id;

    Function answersToMap = (){
      Map<String, String> map = {};
      choices.forEach((a) {map[a.getId()] = a.getValue(); });
      return map;
    };

    map['answers'] = answersToMap();
    map['score'] = getScore();
    if(data!= null) map.addAll(data);
    return map;
  }
}

///IQuestion rappresenta l’astrazione di ogni domanda contenuta in un [IQuestionnaire].
///Si compone di:
/// - l’id della domanda;
/// - il testo della domanda;
/// - la lista delle risposte di tipo [IAnswer]. Se la domanda è aperta, la lista
/// ha un solo elemento.
abstract class IQuestion{
  /// - l'id [id] univoco
  @protected
  String id;

  /// - il testo della domanda [question]
  @protected
  String question;

  /// - l'elenco delle risposte possibili [answers]. Se la domanda è aperta, questa lista è vuota
  @protected
  List<IAnswer> answers;

  ///Ritorna l'id della domanda
  String getId()=>id;
  ///Ritorna il testo della domanda
  String getQuestion()=> question;
  ///Ritorna la lista di risposte disponibili
  List<IAnswer> getAnswers()=> answers;
}

/// [IQuestion] è implementata dalla classe concreta Question, che trasforma ogni
/// json delle domande, nell’oggetto equivalente.
class Question extends IQuestion{

  ///Trasforma la mappa [map] della domanda corrispondente.
  /// Alla voce 'answers', [map] contiene a sua volta una lista di mappe, che rappresentano le risposte.
  Question(dynamic map, int index, int length) {
    id = map['id'];
    question = StringConverter().insertAccentedLetters(map['question']);
    answers = [];
    map['answers'].forEach((a){answers.add(Answer(a));});
  }

}

///IAnswer dichiara la struttura di una risposta ad ogni domanda; contiene infatti:
/// - il testo della risposta, se la domanda prevede opzioni, altrimenti una
/// stringa vuota se la domanda è di tipo aperto;
/// - il punteggio assegnato alla risposta;
/// - il tipo della risposta, utilizzata nel creare widget adatti a supportare
/// l’inserimento di input correti da parte dell’utente;
/// - la lunghezza della risposta, anch’essa supporta il corretto inserimento
/// dell’input dell’utente.
abstract class IAnswer{
  /// testo della risposta
  @protected
  String answer;

  /// punteggio alla risposta
  @protected
  String score;

  ///tipo della risposta se è aperta
  @protected
  String type;

  ///lunghezza della risposta
  @protected
  int length;

  ///Ritorna il testo della risposta
  String getAnswer()=>answer;
  ///Ritorna il punteggio assegnato a tale risposta
  String getScore()=> score;
  ///Ritorna il tipo della risposta
  String getType()=> type;
  ///Ritorna la lunghezza della risposta. E' -1 se si tratta di un'opzione di
  ///risposta ad una domanda chiusa
  int getLength()=>length;
}

///Answer è la classe concreta che implementa [IAnswer] anch’essa trasforma il
///json di ogni risposta in oggetto.
class Answer extends IAnswer{

  /// Trasforma la mappa [map]
  Answer(dynamic map){
    this.answer = StringConverter().insertAccentedLetters(map['answer']);
    this.score = map['value'].toString();
    this.type = map['type'];
    this.length = map['length'];
  }
}

///IChoice è la classe astratta che descrive la struttura di una risposta
///fornita dall'utente. Deve essere composta da:
/// - l’id della domanda a cui è riferita la risposta;
/// - il valore della risposta;
/// - un flag che indica se questa risposta prevede un punteggio.
abstract class IChoice{
  ///id della domanda
  @protected
  String id;

  ///valore della risposta
  @protected
  String value;

  /// Indica se a tale risposta è associato un punteggio
  @protected
  bool withScore;

  IChoice(this.id, this.value, this.withScore);

  ///Ritorna l'id della domanda
  String getId()=> id;

  ///Ritorna il valore della risposta
  String getValue()=>StringConverter().deleteAccentedLetters(value);

  ///Modifica il valore della risposta
  void setValue(String newValue)=> value = newValue;

  /// Ritorna il punteggio
  int getScore();
}

///Choice estende [IChoice].
///Il punteggio, se previsto, corrisponde al valore della risposta.
class Choice extends IChoice{

  Choice(String id, String value, bool withScore) : super(id, value, withScore);

  /// Ritorna il punteggio. se questo oggetto è una risposta ad una domanda aperta,
  /// lo score è 0, altrimenti è contenuto in [_value]
  int getScore()=> withScore ? int.parse(value, onError: (v)=>0): 0;

}
