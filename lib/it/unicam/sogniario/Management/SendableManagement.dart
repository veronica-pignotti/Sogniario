import 'package:flutter/cupertino.dart';

import '../Utilities/Cache.dart';
import '../Utilities/Connection.dart';
import '../Utilities/TypeConverter.dart';
import 'AccessManagement.dart';

///SendableManager, infatti, è la classe astratta che contiene un’istanza di Connection,
///per permettere l’invio dei dati, e un’istanza della classe [Cache], per il salvataggio e il
///recupero di essi in caso di fallimento da parte di [Connection]. I prelievi dalla cache
abstract class SendableManager extends Manager{
  Connection connection;
  Cache cache;

  SendableManager(){
    connection = Connection();
    cache = Cache();
  }

  ///Recupera dalla [cache] gli oggetti [Sendable] gestiti da tale manager
  Future<void> find();
}

/// Stabilisce un contratto che gli elementi principali dell'applicazione devono rispettare.
/// In particolar modo si presta l'attenzione sul salvataggio di questi dati su
/// un repository (database locale o dell'applicazione).
/// Da qui nasce la necessità di fornire una codifica adeguata di ogni istanza
/// sottoforma di Map<String, String>, in modo da non tralasciare nessuna informazione.
abstract class Sendable {
  /// La data di registrazione dell'elemento
  @protected
  DateTime date;

  Sendable(this.date);

  ///Converte in mappa l'elemento.
  ///Per default, viene creato il campo "date" per contenere [date], convertita in "MillisecondsSinceEpoch"
  Map<String, dynamic> toMap() =>
      {
        "date": DateConverter().dateTimeToEpoch(date).toString(),
        "token": Connection().getToken(),
        "nickname":Connection().getToken()
      };

  DateTime getDate()=> date;
}