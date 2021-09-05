import 'package:sogniario/it/unicam/sogniario/Questionnaire/QuestionnaireManager.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../Pages/GraphicElements.dart';
import 'ReportManager.dart';

///All’interno di ReportPage abbiamo l’implementazione del requisito principale
///di Sogniario: la registrazione del sogno. Presenta infatti uno spazio per la
///stesura del testo; cliccandolo, appare la tastiera del dispositivo, che contiene
///il tasto del microfono, che può essere attivato in modo da dettare il sogno
///piuttosto che scriverlo a. Inoltre, se l’utente non è soddisfatto del racconto,
///può ricominciare con il semplice click del bottone “Ricomincia”. Tale testo è
///modificabile e inviabile attraverso l’apposito bottone “Invia”. Se viene cliccato
///senza aver scritto nulla, comparirà un messaggio di errore.
///Il tasto “Invia” passa il testo al ReportManager, per trasformarlo in un istanza
///[Report] e lo invierà, tramite una codifica appropriata, alla classe [Connection].
///Se l’invio del report non va a buon fine, viene salvato in cache, per poi essere
///spedito al server solo quando si ha la buona riuscita di tale operazione; se
///l’invio del report va a buon fine, infatti, si cercano quelli salvati in locale,
///che verranno eliminati per evitare duplicati e passati a Connection.
///A questo punto l’utente viene reindirizzato su un AskPage dove si chiede quale
///sia l’azione che vuole svolgere, tra cui: registrazione di un nuovo sogno,
///navigare nel menu e, solo se il [QuestionnaireManager] ha caricato i questionari,
///compilare il questionario di fine report.
// ignore: must_be_immutable
class ReportPage extends StatefulWidget {
  ReportManager _manager;

  ReportPage(this._manager);

  _ReportPageState createState() => _ReportPageState(_manager);
}

class _ReportPageState extends State<ReportPage>{

  TextEditingController _textController = new TextEditingController();
  String _message = "";
  ReportManager _manager;
  bool _isListening = false;
  String _text = "", _temporary = "";
  bool _available = false;
  stt.SpeechToText _speech;


  _ReportPageState(this._manager);


  @override
  void initState() {
    super.initState();
    _textController.text = "";
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    if(_textController == null) return;
    _textController.dispose();
    super.dispose();
  }

  /// Se non vuoto, invia passa al [_manager] il testo fornito dall'utente,
  /// altrimenti, visualizza un messaggio di errore
  void _send() async{
    Widget next = _manager.confirm(_textController.text);
    if(next==null) setState(() {_message = "Non puoi inviare un sogno che non c'è";});
    else Navigator.push(context, MaterialPageRoute(builder: (context) => next));
  }


  ///Cancella il testo fornito dall'utente
  void _restart(){
    _textController.text = "";
    _temporary = "";
    _text = "";
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: SogniarioBar(true, false).build(context),
      body: Padding(padding: EdgeInsets.all(10.0), child: ListView(
          children: <Widget>[
            SogniarioPageTitle('Racconta un sogno'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AvatarGlow(
                  animate: false,
                  glowColor: SogniarioColors().get(1),
                  endRadius: 50.0,
                  duration: const Duration(milliseconds: 2000),
                  repeatPauseDuration: const Duration(milliseconds: 100),
                  repeat: true,
                  child: FloatingActionButton(
                    onPressed: _restart,
                    backgroundColor: SogniarioColors().get(1),
                    foregroundColor: Colors.black,
                    heroTag: "Restart",
                    child: Icon(SogniarioIcons().get("cancel")),
                  ),
                ),
                AvatarGlow(
                  animate: _isListening,
                  glowColor: Colors.black,//SogniarioColors().get(1),
                  endRadius: 50.0,
                  duration: Duration(seconds: 1),
                  repeatPauseDuration: Duration(milliseconds: 100),
                  repeat: true,
                  child: FloatingActionButton(
                    onPressed: _isListening? null : listen,
                    backgroundColor: _isListening? Colors.black:SogniarioColors().get(1),
                    foregroundColor: _isListening? SogniarioColors().get(1) : Colors.black,
                    heroTag: "Listen",
                    child: Icon(SogniarioIcons().get("mic"))
                  ),
                ),
                AvatarGlow(
                  animate: false,
                  glowColor: SogniarioColors().get(1),
                  endRadius: 50.0,
                  duration: const Duration(milliseconds: 2000),
                  repeatPauseDuration: const Duration(milliseconds: 100),
                  repeat: true,
                  child: FloatingActionButton(
                    onPressed: _send,
                    backgroundColor: SogniarioColors().get(1),
                    foregroundColor: Colors.black,
                    heroTag: "Send",
                    child: Icon(SogniarioIcons().get("send")),
                  ),
                )
              ]
            ),
            SogniarioMessage(_message),
            TextField(
              maxLines: 10,
              maxLengthEnforced: false,
              controller: _textController,
              autocorrect: false,
              style: new TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontFamily: "Arimo"
              ),
              decoration: InputDecoration(
                hintText: "Cos'hai sognato stanotte?\nScrivilo o raccontalo premendo il microfono.",
                hintStyle: TextStyle(fontSize: 18.0),
                labelText: _isListening? "Finché parli, ti ascolto...": "Pronto per ascoltare",
                labelStyle: TextStyle(fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.w600),
                alignLabelWithHint: true
              )
            ),
          ]
      ),)
    );


  void listen()async{
    print("listen");
    _available = await _speech.initialize(
      onStatus: (val)=> print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if(!_available) {
      setState(() {
        _message = "Riconoscimento vocale non disponibile";
      });
      return;
    }
    return _speech.listen(
      listenFor: Duration(minutes: 10),
      pauseFor: Duration(seconds: 5),
      onResult: (val)async{
        _temporary = val.recognizedWords;
        setState(() {
          _isListening = true;
          _textController.text = "$_text $_temporary";
        });
        if(val.finalResult) return await stop();
      },
    );
  }

  Future<void> stop() async{
    if(_text == "") _text = _temporary;
    else _text+= " " + _temporary;
    setState(() {
      _isListening = false;
      _textController.text = _text;
    });
    _temporary = "";
    await _speech.stop();
  }
}