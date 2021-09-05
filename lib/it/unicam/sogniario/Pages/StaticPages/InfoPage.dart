import 'package:flutter/material.dart';

import '../GraphicElements.dart';

///InfoPage mostra una breve descrizione dell’applicazione per l’utente.
// ignore: must_be_immutable
class InfoPage extends StatelessWidget {
  InfoPage();

  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar : SogniarioBar(false, true).build(context),
    body: Padding(padding: EdgeInsets.all(10),child: ListView(
      children: [
        SogniarioPageTitle("Informazioni sull'applicazione"),
        SogniarioText(
            "Sogniario è un'app creata per registrare e catalogare i tuoi sogni.\n\n" +
            "Prende nota della qualità del tuo sonno e delle caratteristiche dei tuoi sogni. Inoltre registra vocalmente la descrizione del tuo sogno.\n\n"+
            "Analizza la complessità del sogno attraverso tecniche di neurolinguistica e riporta grafi e nuvole di parole per una visualizzazione intuitiva del contenuto del sogno. Permette di tener traccia della qualità del tuo sonno e dei sogni mediante la funzione calendario.\n\n" +
            "Sogniario nasce da una collaborazione tra il Brain and Sleep Research Laboratory dell’Università di Camerino e il Molecular Mind Laboratory della Scuola IMT Alti Studi Lucca. Ha lo scopo di aiutare gli scienziati a comprendere il funzionamento del cervello alla base dell’esperienza cosciente durante il sonno.",
            20
        ),
      ],
    ),
  ));
}
