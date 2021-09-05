import 'package:flutter/material.dart';

import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';

///AskPage è una pagina che servirà per comunicare all’utente determinate azioni
///svolte o da svolgere. Infatti viene costruita passando un messaggio per l’utente
///e una lista di [SogniarioButton]. E’ utilizzata quando l’utente ha inviato dei
///dati, ossia reports e questionari, oppure durante la procedura di benvenuto
///dell'utente, durante il primo accesso.
class AskPage extends StatelessWidget{
  final String _question;
  final List<SogniarioButton> _buttons;

  AskPage(this._question, this._buttons);

  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar: SogniarioBar(false, false).build(context),
    body :Center(
      child:Container(
        child: Align(
            alignment: Alignment.center,
            child:_buildItems(context)
        )
      )
    )
  );

  ListView _buildItems(BuildContext context) {
    List<Widget> items = [Padding(padding: EdgeInsets.all(10), child:SogniarioText(_question, 26.0))];
    _buttons.forEach((button) {
      items.add(Padding(padding: EdgeInsets.all(10), child:button));
    });
    return ListView(children: items);
  }

}
