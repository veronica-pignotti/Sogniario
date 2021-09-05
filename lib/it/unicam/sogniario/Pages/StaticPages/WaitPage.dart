import 'package:flutter/material.dart';

import '../GraphicElements.dart';

///WaitPage rappresenta la classica pagina di attesa, utilizzata durante l’esecuzione
///di alcune chiamate asincrone.
// ignore: must_be_immutable
class WaitPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: SogniarioBar(false, false).build(context),
        body :Center(
          child: Container(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(SogniarioColors().get(1)),)
          )
        )
      );
}