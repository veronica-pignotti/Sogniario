import 'package:flutter/material.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/ListPage.dart';


///SogniarioBar contiene l’appbar dell’applicazione; visualizza sempre il titolo
///dell’app e viene costruita specificando attraverso due booleani:
///- menuappbar indica la possibilità di andare sulla pagina del menu;
///- back indica la possibilità o meno di tornare alla pagina precedente, operazione
///che deve essere disattivata nelle parti più critiche dell’applicazione.
class SogniarioBar extends AppBar{

  ///indica se si sta richiedendo questo widget per il menu oppure no, per evitare
  ///che l’utente vada in questa pagina dalla pagina stessa.
  final bool _menu;

  ///back indica la possibilità o meno di tornare alla pagina precedente, operazione
  ///che deve essere disattivata nelle parti più critiche dell’applicazione.
  final bool _back;

  SogniarioBar(this._menu, this._back);

  Widget build(BuildContext context){
    List<Widget> opt = !_menu?[]:
    [
      IconButton(
        icon: const Icon(Icons.menu),
        color: Colors.black,
        tooltip: 'Menu',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MenuPage()),
          );
        },
      ),
    ];

    return AppBar(
      title: Text(
        "Sogniario",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 30.0,
          fontFamily: "Arimo",
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: opt,
      automaticallyImplyLeading: _back,
    );
  }

}

abstract class SogniarioButton extends StatelessWidget{
  final String text;
  final Function function;

  SogniarioButton(this.text, this.function);

}

class SogniarioBackButton extends SogniarioButton{


  SogniarioBackButton(String text, Function function) : super(text, function);

  @override
  Widget build(BuildContext context)=>
      RaisedButton(
          child:Text(text, style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w600,
          )),
          color:SogniarioColors().get(1),
          textColor:Colors.black,
          onPressed:() {
            if(function!= null) function();
            Navigator.pop(context);
          }
      );

}
///SogniarioButton contiene il bottone personalizzato utilizzato all’interno
///dell’applicazione; costruito passando il testo che lo rappresenta e la funzione
///che avvia. Se next è null, torna indietro.
class SogniarioFunctionButton extends SogniarioButton{

  final Widget _next;

  SogniarioFunctionButton(String text, Function function, this._next):super(text, function);

  @override
  Widget build(BuildContext context)=>
      RaisedButton(
          child:Text(text, style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w600,
          )),
          color:SogniarioColors().get(1),
          textColor:Colors.black,
          onPressed:() {
            if(function!= null) function();
            if(_next!=null)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _next),
                );
          }
      );
}

///SogniarioPageTitle è il titolo della pagina, che compare come primo widget della stessa
// ignore: must_be_immutable
class SogniarioPageTitle extends StatelessWidget{
  String _text;
  SogniarioPageTitle(this._text);

  @override
  Widget build(BuildContext context) =>
    Padding(
      padding:EdgeInsets.only(bottom:20),
      child: Text(
        _text,
        textAlign: TextAlign.center,
        style: new TextStyle(
            fontSize:30.0,
            height: 1.0,
            color: Colors.black,
            fontWeight:FontWeight.w600,
            fontFamily: "Arimo"
        )
      )
    );

}

///SogniarioMessage è utilizzato per segnalare un errore
class SogniarioMessage extends Text{
  SogniarioMessage(String txt):super(
      txt,
      textAlign: TextAlign.left,
      style: new TextStyle(
          fontSize:20.0,
          height: 1.0,
          color:Colors.red,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          fontFamily: "Arimo"
      )
  );
}

/// SogniarioText è un normale testo, ci sui si può perosnalizzare la font size
class SogniarioText extends Text{
  SogniarioText(String txt, double size):super(
      txt,
      style: new TextStyle(
          fontSize:size,
          height: 1.0,
          color: const Color(0xFF000000),
          fontFamily: "Arimo"
        //fontWeight: FontWeight.w700,
      )
  );
}

class SogniarioCentralText extends Text{

  SogniarioCentralText(String text, double size, bool bold):super(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: size, fontWeight: bold? FontWeight.w600:FontWeight.normal)
  );
}
///SogniarioColors contiene la lista dei colori utilizzati all'interno dell'app
class SogniarioColors{
  Map<int, Color> _colorCodes = {
    1: Color.fromRGBO(133, 181, 203, 1.0),
    2: Color.fromRGBO(176, 211, 206, 1.0)
  };

  Color get(int i) => _colorCodes[i];
}

/// Contiene la mappa delle icone utilizzate all'interno dell'app
class SogniarioIcons{
  Map<String, IconData> icons = {
    "dream": FontAwesomeIcons.solidMoon,
    "dreams" : FontAwesomeIcons.bed,
    "questionnaire": FontAwesomeIcons.tasks,
    "calendar": FontAwesomeIcons.calendarAlt,
    "graph": FontAwesomeIcons.projectDiagram,
    "info": FontAwesomeIcons.info,
    "privacy": FontAwesomeIcons.userSecret,
    "cloud": FontAwesomeIcons.cloudversify,
    "mic": FontAwesomeIcons.microphoneAlt,
    "cancel": FontAwesomeIcons.trashAlt,
    "send": FontAwesomeIcons.check,
    "owl": FontAwesomeIcons.earlybirds,
    "lark" : ModernPictograms.twitter_bird,
    "reload":Typicons.arrows_cw,
    "zoomin":ModernPictograms.zoom_in,
    "zoomout":ModernPictograms.zoom_out,
    "exit": MfgLabs.logout
  };

  IconData get(String key) => icons.containsKey(key)?icons[key]: Icons.clear;
}

///ItemListPage è un widget visualizzato in una [ListPage] che indirizza alla pagina [_next]
class ItemListPage extends StatelessWidget{
  ///il titolo attribuito a [_next]
  final String _title;
  ///l'icona attribuita a [_next]
  final IconData _icon;
  ///la pagina a cui indirizza tale widget
  Widget Function()  _next;

  ItemListPage(this._title, this._icon, this._next);

  @override
  Widget build(BuildContext context) =>
      GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => _next()));},
          child: Row(children: [
            Icon(_icon, size: 60.0, color: Colors.black),
            Flexible(
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      _title,
                      textAlign: TextAlign.left,
                      style: new TextStyle(
                          fontSize:30.0,
                          height: 1.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Arimo"
                      )
                    )
                )
            )
          ])
      );
}
