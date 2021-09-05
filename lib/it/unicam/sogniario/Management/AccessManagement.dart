import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:sogniario/it/unicam/sogniario/Calendar/CalendarManager.dart';
import 'package:sogniario/it/unicam/sogniario/Questionnaire/QuestionnaireManager.dart';
import 'package:sogniario/it/unicam/sogniario/Report/ReportManager.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/AppSecurity.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/Cache.dart';

import 'package:sogniario/it/unicam/sogniario/Utilities/Connection.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';


abstract class Manager{

  dynamic init();
}

///Nella classe astratta IAccessManager sono raggruppati:
///- i metodi che introducono creazione, salvataggio e distribuzione di informazioni
///che devono essere eseguiti ad ogni accesso dell'utente;
///- alcuni parametri, che verranno utilizzati per determinare la prima pagina
///visualizzatta sullo schermo del dispositivo dell’utente.
abstract class IAccessManager {

  ///L'istanza di [Cache] utilizzata
  @protected
  Cache cache;
  ///L'istanza di [Connection] utilizzata
  @protected
  Connection connection;
  ///Indica se tale accesso effettuato è il primo
  @protected
  bool firstAccess;
  ///Indica se l'utente è stato registrato
  @protected
  bool registered;
  ///Indica se i questionari sono stati caricati
  @protected
  bool loaded;
  ///Indica se sono presenti questionari da compilare
  @protected
  bool toCompile;
  ///Indica se si sta eseguendo la parte di avvio
  @protected
  bool start;

  /// Esegue le azioni e i controlli necessari ad ogni accesso dell'utente.
  Future<AccessManager> access();

  ///Questo metodo viene chiamato quando non sono presenti le informazioni dell'utente nella cache.
  ///Questo può essere dovuto a due fattori:
  ///
  ///1- L'utente ha effettuato il suo primo accesso nell'applicazione. Questa è
  ///la causa che si prende subito in considerazione, quindi si procede con la
  ///registrazione dell'utente nel server, la cui risposta sarà determinante per
  ///capire l'assenza di informazioni nella [cache].
  ///Se la registrazione va a buon fine, vengono creati i dati che andranno salvati
  ///localmente e si eseguono delle azioni asincrone.
  ///Se la registrazione non è andata a buon fine, senza generare errori, allora
  ///si è verificato il caso sottostante;
  ///
  ///2- L'utente ha utilizzato normalmente l'applicazione, per poi disistallarla
  ///e installarla in un secondo momento. Ciò significa che l'utente è già presente
  ///nel server, quindi l'azione sopra citata fallisce. In questo caso la risposta
  ///del server contiene la lista degli ultimi [IQuestionnaire] compilati,
  ///uno per tipo, così da poter tener presente ciò che l'utente deve ancora compilare o meno.
  ///
  /// Se la chiamata al server genera un errore per qualche problema di connessione,
  /// non è possibile eseguire alcuna azione all’interno dell’app.
  @protected
  Future<void> isFirstAccess();

  ///Metodo chiamato quando si è cercato di registrare nel server un utente già presente.
  ///Si procede quindi nel rimpatriare la [cache] con il [token] generato e le informazioni passate dal
  ///server, quali la data del primo accesso dell'utente [firstAccessDate] e la
  ///mappa degli ultimi [IQuestionnaire] compilati [completed], uno per tipo.
  @protected
  Future<void> alreadyRegisteredUser(String token, int firstAccessDate, Map<String, dynamic> completed);

  /// Esegue alcune azioni asincrone, distribuento informazioni alle classi che
  /// le utilizzano e inizializzando dati
  @protected
  Future<void> setInformations(DateTime date, String token);

  /// Ritorna il booleano che indica se l'utente ha appena effettuato il primo accesso
  bool getFirstAccess() => firstAccess;

  ///Ritorna il booleano che indica se l'utente è stato correttamente registrato nel server
  bool getRegistered()=> registered;

  ///Ritorna il booleano che indica se i questionari sono stati scaricati dal server
  bool getLoaded()=> loaded;

  ///Ritorna il booleano che indica se ci sono questionari da compilare
  bool getToCompile()=>toCompile;

  ///Ritorna il booleano che indica se si sta eseguendo la parte di avvio
  bool getStart() => start;

  ///Segna il passaggio tra la parte di avvio e la parte del normale utilizzo dell'applicazione.
  void setStart()=> start = false;
}



///AccessManager è la classe concreta che implementa [IAccessManager].
///Ad ogni accesso, viene chiamato il metodo access, che, dopo aver inizializzato
///la [Cache], verifica se l’utente sta utilizzando per la prima volta l’applicazione
///oppure no, recuperando le sue informazioni dalla cache.
/// Se non presenti, provvede a generare il token e inviarlo al server per registrare
/// un nuovo utente, grazie al metodo [registerNewUser].
/// In caso di mancata connessione, non è possibile eseguire alcuna azione
/// all’interno dell’app. Se questa registrazione va a buon fine, si memorizza in
/// [Cache] il token e la data di questo primo accesso e vengono eseguite delle
/// azioni, raggruppate nel metodo setInformations, chiamato direttamente dal
/// secondo accesso in poi.
class AccessManager extends IAccessManager{
  
  static final AccessManager instance = AccessManager.internal();

  factory AccessManager()=>instance;

  AccessManager.internal(){
    cache = Cache();
    connection = Connection();
    firstAccess = false;
    registered = false;
    loaded = false;
    toCompile = false;
    start = true;
  }

  /// Esegue le azioni e i controlli necessari ad ogni accesso dell'utente.
  /// Dopo aver inizializzato la cache [cache], controlla se l'utente è stato registrato,
  /// quindi cerca di prelevare le sue informazioni dalla [cache].
  /// Se non presenti, probabilmente ha effettuato il primo accesso alla piattaforma,
  /// quindi verrà eseguito il metodo [isFirstAccess]; altrimenti si eseguono alcune
  /// azioni asincrone, racchiuse nel metodo [setInformations]
  Future<AccessManager> access() async{
    cache = await cache.init();
    String userFromCache = cache.getValue("User");

    if(userFromCache == "") await isFirstAccess();
    else {
      firstAccess = false;
      registered = true;
      Map<String, dynamic> map = jsonDecode(userFromCache);
      await setInformations(DateConverter().epochToDateTime(int.parse(map['firstAccessDate'])), map['token']);
    }
    return this;
  }

  Future<void> isFirstAccess() async {
    String token = await AppSecurity().createToken();
    ConnectionResponse response = await connection.call("postNewUser", jsonEncode({"token": token}));

    if (response.getOk()){
      print("Utente correttamente registrato");
      firstAccess = true;
      registered = true;
      await cache.insertValue("User", jsonEncode({
        "firstAccessDate": DateConverter().dateTimeToEpoch(DateTime.now()),
        "token": token
      }));

      await setInformations(DateTime.now(), token);
      return;
    }

    if (response.getData() != "") {
      Map<String, dynamic> map = jsonDecode(response.getData());
      return await alreadyRegisteredUser(token, int.parse(map['date']), jsonDecode(map['questionnaires']));
    }
    print("Si è verificato un errore durante la registrazione");
    firstAccess = true;
    registered = false;
  }

  Future<void> alreadyRegisteredUser(String token, int firstAccessDate, Map<String, dynamic> completed)async{

    print("Utente già registrato");
    firstAccess = false;
    registered = true;
    connection.setToken(token);

    await cache.insertValue("User", jsonEncode({"firstAccessDate": firstAccessDate, "token": token}));

    QuestionnaireManager qm = QuestionnaireManager();
    await qm.init();
    await qm.reloadCache(completed);

    loaded = qm.hasQuestionnaires();
    toCompile = qm.hasToCompile();

    CalendarManager().setStartDay(DateConverter().epochToDateTime(firstAccessDate));
    await ReportManager().init();
  }

  Future<void> setInformations(DateTime date, String token)async{
      connection.setToken(token);
      CalendarManager().setStartDay(date);

      QuestionnaireManager qm = QuestionnaireManager();
      await qm.init();
      loaded = qm.hasQuestionnaires();
      toCompile = qm.hasToCompile();

      if(!firstAccess && loaded) await ReportManager().init();
  }


  String toString() =>
    "ACCESS MANAGER INFO:\n"+
    "Is this the user's first login? " + (firstAccess? "Yes": "No") + "\n"+
    "Has the user been registered? "+ (registered? "Yes": "No") + "\n"+
    "Have the questionnaires been downloaded? "+ (loaded? "Yes": "No") + "\n"+
    "Are there questionnaires to fill out? "+ (toCompile? "Yes": "No") + "\n";
}