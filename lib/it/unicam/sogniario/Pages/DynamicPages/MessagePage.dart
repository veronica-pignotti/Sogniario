import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../GraphicElements.dart';

///MessagePage invece visualizza un semplice messaggio, come l’assenza di questionari
///in determinate condizioni.
class MessagePage extends StatelessWidget{
  final String _message;
  final _menu;

  MessagePage(this._message, this._menu);

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: SogniarioBar(_menu, true).build(context),
      body : Center(child:
        Text(
          _message!=null && _message != ""? _message: "Nessun elemento da visualizzare",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize:36.0))
      )
    );
}