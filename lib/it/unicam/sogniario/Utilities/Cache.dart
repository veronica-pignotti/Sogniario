import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

///Ogni volta che l’applicazione viene chiusa, la vita dei dati termina. Ci sono
///alcune informazioni, però, che devono essere persistenti, come il token relativo
///all’utente, la sua data del primo accesso o i dati da salvare nel repository
///se non è possibile connettersi al server.
/// In queste situazioni entra in gioco la classe Cache, che sfrutta l’istanza di
/// SharedPreferences, classe offerta dal plugin shared_preferences, per salvare
/// su un repository locale del dispositivo, le informazioni più utili e fungere
/// da supporto per il salvataggio momentaneo dei dati e. Tale istanza si comporta
/// come una mappa di dati semplici (stringhe o liste di stringhe) e Cache è in
/// grado di inserire coppie chiave-valore e prelevare valori, conoscendone la
/// chiave. In tal modo si possono salvare anche gli oggetti [Sendable], trasformati
/// in json, se vengono respinti dalla mancata connessione; appena possibile,
/// verranno prelevati, cancellati dalla cache per evitare duplicati e inviati.
/// Questa classe è utilizzata anche dal [Reminder], per memorizzare i questionari
/// che l’utente deve compilare.
class Cache {
  @protected
  SharedPreferences _cache;

  static final Cache instance = Cache.internal();

  factory Cache() => instance;

  Cache.internal();

  /// Inizializza la cache
  Future<Cache> init() async {
    if(_cache == null) this._cache = await SharedPreferences.getInstance();
    return this;
  }

  /// Inserisce una coppia si stringhe nella memoria locale
  Future<bool> insertValue(String key, String data) async {
    print("INSERIMENTO VALORE CON CHIAVE $key");
    return _cache.setString(key, data);
  }

  /// Ritorna la stringa con chiave [key]. Se non presentei, ritorna una stringa vuota
  String getValue(String key)=>
    _cache.containsKey(key) && checkString(key)?
        _cache.getString(key): "";

  /// Inserisce [value], nella lista con chiave [key].
  /// Se [value] è una stringa, viene aggiunta alla lista.
  /// Se value è una lista, viene concatenata a quella già presente.
  /// Se [key] non è presente, si crea una nuova lista con tale chiave
  Future<bool> insertInList(String key, dynamic value) async {
    print("INSERIMENTO VALORE NELLA LISTA CON CHIAVE $key");
    if (!_cache.containsKey(key)) return _cache.setStringList(key, value is String? [value]:value);
    if(checkString(key)) return false;
    List<String> list = _cache.getStringList(key);
    if(value is String) list.add(value);
    else if(value.isEmpty) return _cache.remove(key);
    else list.addAll(value);
    return _cache.setStringList(key, list);
  }

  /// Ritorna la lista con chiave [key]. Se non presente, ritorna una lista vuota
  List<String> getValuesList(String key)=>
      _cache.containsKey(key) ? _cache.getStringList(key) : [];


  /// Cancella il campo con chiave [key]
  Future<void> delete(String key) async => await _cache.remove(key);

  /// Controlla se il valore con chiave [key] è una stringa
  bool checkString(String key) => _cache.get(key) is String;

}