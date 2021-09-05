import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

///AbstractConnection stabilisce il contratto che ogni tipo di classe che esegue
///chiamate al server deve rispettare.
abstract class AbstractConnection{

  ///Gli headers da utilizzare nelle chiamate
  Map<String, String> headers={};

  ///Effettua una chiamata get utilizzando l'url [url] passato
  Future<ConnectionResponse> buildGetCall(String url);

  ///Effettua la chiamata per registrare un nuovo utente sul server
  Future<ConnectionResponse> postNewUser(String url, String body);

  ///Effettua una chiamata post
  Future<ConnectionResponse> buildPostCall(String url,String body);

  ///Imposta gli headers [headers]
  void setHeaders(Map<String, String> h)=> headers = h;

}

///La classe Connection che si occupa di stabilire il tipo di “connessione” da
///utilizzare e la chiamata da effettuare, mediante [_urlMap], una mappa che
///associa ad una stringa identificativa, l’url della chiamata da eseguire.
class Connection{

  ///La stringa di base di connessione
  String _strConnection = "http://193.205.92.106:8765/gateway/"; // con vpn

  ///La connessione da utilizzare
  AbstractConnection _connection;

  ///mappa che associa ad una stringa identificativa, l’url della chiamata da eseguire.
  Map<String, String> _urlMap = {
    "getReports" : "reports/api/users/findReportsByNicknameAndDataRangeUser",
    "getReportsMap" : "reports/api/users/getWordsPercent",
    "postReport" : "reports/api/users/store/",
    "getQuestionnaires": "questionnaires/api/questGet/getAllQuestUsers",
    "postQuestionnaire": "questionnaires/api/store",
    "postNewUser": "auth/api/public/signupUser"
  };

  ///Gli headers da allegare ad ogni chiamata
  Map<String, String> _headers = {
    "Access-Control-Allow-Origin":"*",
    "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept",
    "Access-Control-Allow-Methods": "OPTIONS,DELETE, POST, GET, PUT",
    "token": ""
  };

  static final Connection _instance = Connection._internal();

  Connection._internal(){
    check();
  }

  factory Connection() => _instance;

  ///Tenta di istanziare una [SecureConnection] utilizzando il certificato.
  ///Se si verifica un errore, viene creata una [StandardConnection].
  Future<void> check()async{
    try{
      ByteData data = await rootBundle.load('resources/certificates/sogniario_unicam_it.pem');
      SecurityContext context = SecurityContext.defaultContext;
      context.setTrustedCertificatesBytes(data.buffer.asUint8List());
      _connection = SecureConnection(HttpClient(context: context));
      print("Connessione impostata: secure");
    }catch(e){
      _connection = StandardConnection();
      print("Connessione impostata: standard");

    }
  }

  ///Elabora la chiamata e la passa a [_connection].
  Future<ConnectionResponse> call(String action, String body)async{
    String url = _strConnection + _urlMap[action];
    try {
      if (!_urlMap.containsKey(action)) {
        print("L'azione $action non è stata trovata");
        throw ArgumentError();
      }
      ConnectionResponse connectionResponse;
      if (body == null)
        connectionResponse = await _connection.buildGetCall(url);
      else if (action == "postNewUser"){
        connectionResponse = await _connection.postNewUser(url, body);
      } else connectionResponse = await _connection.buildPostCall(url, body);

      print(connectionResponse.toString());
      return connectionResponse;
    }catch(e){
      print("Si è verificato un errore durante la chiamata con url $url: " + e.toString());
      return ConnectionResponse(url, body, false, "");
    }
  }

  /// Ritorna il token
  String getToken()=> _headers['token'];

  ///Imposta il token e gli headers
  void setToken(String token){
    _headers['token'] = token;
    _connection.setHeaders(_headers);
  }

}

///StandardConnection estende [AbstractConnection] ed effettua chiamate mediante una canale normale (HTTP)
class StandardConnection extends AbstractConnection {


  Future<ConnectionResponse> buildGetCall(String url) async =>
      await http.get(url, headers: headers)
          .then((response) async =>
          ConnectionResponse(
              url,
              null,
              response.statusCode == 200,
              response.statusCode == 200 ? response.body : ""
          )
      );


  Future<ConnectionResponse> buildPostCall(String url, String body) async =>
      await http.post(url, headers: headers, body: body)
          .then((response) => ConnectionResponse(url, body, response.statusCode == 200, response.body));


  Future<ConnectionResponse> postNewUser(String url, String token) async{
    return await http.post(url, body: token)
        .then((response) =>
        ConnectionResponse(
            url, token, jsonDecode(response.body)['status'] == 'true', jsonDecode(response.body)['info']
        )
    );
  }


}

///SecureConnection effettua chiamate mediante un canale protetto (HTTPS), permesso
///dal certificato SSL.
class SecureConnection extends AbstractConnection{
  ///Il client da utilizzare
  HttpClient _client;
  HttpClientRequest _request;

  SecureConnection(this._client);

  ///Imposta gli headers alla richiesta passata
  void setHeadersToRequest(HttpClientRequest request){
    headers.forEach((key, value) {request.headers.set(key,value); });
  }

  Future<ConnectionResponse> buildGetCall(String url) async {
    try{
      _request = await _client.getUrl(Uri.parse(url));
    }catch(e){
      print("Si è verificato un errore durante la chiamata con url $url: " + e.toString());
      return ConnectionResponse(url, "", false, "");
    }
    setHeadersToRequest(_request);
    return await _request.close().then((response) async{
    return ConnectionResponse(url, null, response.statusCode == 200,response.statusCode == 200 ? await readResponse(response): "");
    });
  }

  Future<ConnectionResponse> buildPostCall(String url, String body) async {
    try{
    _request = await _client.postUrl(Uri.parse(url));
    }catch(e){
      print("Si è verificato un errore durante la chiamata con url $url: " + e.toString());
      return ConnectionResponse(url, body, false, "");
    }
    setHeadersToRequest(_request);
    _request.write(body);
    return await _request.close().then((response)async=>
        ConnectionResponse(url, body, response.statusCode == 200,await readResponse(response)));
  }

  Future<ConnectionResponse> postNewUser(String url,String token) async {
    try{
    _request = await _client.postUrl(Uri.parse(url));
    }catch(e){
      print("Si è verificato un errore durante la chiamata con url $url: " + e.toString());
      return ConnectionResponse(url, token, false, "");
    }
    _request.write(token);
    HttpClientResponse response = await _request.close();
    Map<String, dynamic> map = jsonDecode(await readResponse(response));
    return ConnectionResponse(url, token, map['status']=='true', map.containsKey('info') && map['info'] is Map? jsonEncode(map['info']) : "");
  }

  ///Converte la risposta della chiamata in una stringa
  Future<String> readResponse(HttpClientResponse response) async {
    final completer = Completer<String>();
    final contents = StringBuffer();
    response.transform(utf8.decoder).listen((data) {
      contents.write(data);
    }, onDone: () async => completer.complete(contents.toString()));
    return completer.future;
  }

}

///ConnectionResponse raggruppa tutte le informazioni di una chiamata, quindi
///l’url, il body, un booleano che indica la buona riuscita e il dato ricevuto dal server.
class ConnectionResponse{
  ///L'url utilizzato per la chiamata
  String _url;
  ///Il body passato per la chiamata
  String _body;
  ///Indica la buona riuscita o meno della chiamata
  bool _ok;
  ///Il dato ricevuto dal server
  String _data;

  ConnectionResponse(this._url, this._body, this._ok, this._data);

  ///Ritorna la buona riuscita o meno della chiamata
  bool getOk()=> _ok;
  ///Ritorna il dato ricevuto dal server
  String getData()=> _data;
  ///Ritorna l'url utilizzato per la chiamata
  String getUrl()=> _url;

  String toString()=>
      "INFORMAZIONI CHIAMATA AL SERVER:\n"+
          "> URL = $_url\n"+
          (_body!= null? "> body = $_body\n": "")+
          "> ok = ${_ok.toString()}\n"+
          "> data = $_data";

}