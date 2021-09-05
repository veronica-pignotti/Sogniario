import 'package:flutter/material.dart';

import '../GraphicElements.dart';

///PrivacyInfoPage mostra la normativa sulla privacy
// ignore: must_be_immutable
class PrivacyInfoPage extends StatelessWidget {
  PrivacyInfoPage();

  Widget build(BuildContext context) =>
      Scaffold(
        appBar: SogniarioBar(false, true).build(context),
        body: Padding(
            padding: EdgeInsets.all(10.0), child: ListView(children:[
              SogniarioPageTitle("Informativa sulla privacy"),
              SogniarioText(
                "Il trattamento delle risposte e dei dati da lei forniti è finalizzato alla realizzazione di una ricerca scientifica relativa all’applicazione delle neuroscienze nella caratterizzazione dei processi decisionali.\n\n" +
                "I dati raccolti attraverso il questionario sono utilizzati solo a scopo di ricerca e verranno elaborati esclusivamente dal gruppo di ricerca dell’Università di Camerino (UNICAM).\n\n" +
                "La partecipazione al questionario è volontaria.\n\n" +
                "I dati raccolti attraverso il questionario non sono riconducibili in alcun momento alla persona che li ha forniti, da parte del team di ricerca. I report redatti per la presentazione dei risultati della ricerca non potranno contenere in nessun modo informazioni che consentano di identificare coloro che hanno conferito i dati.\n\n" +
                "Le risposte al questionario saranno raccolte mediante un canale protetto dal protocollo SSL e salvate su un server gestito dall'Università di Camerino. Si precisa che non sono richieste credenziali o altre modalità di autenticazione per la compilazione del questionario o dati che permettano l’identificazione dell’interessato nel momento della compilazione del questionario o in un momento successivo, quali ad esempio l’indirizzo e-mail: pertanto, i dati conferiti non consentono l’identificazione o l’identificabilità del soggetto che risponde al questionario e in tal senso non sono definibili come dati personali ai sensi della normativa di legge.\n\n" +
                "I risultati della ricerca saranno comunicati in pubblicazioni scientifiche e a conferenze, e resi pubblici solo in forma aggregata e totalmente anonima.\n\n" +
                "Il trattamento dei dati personali effettuato da UNICAM è improntato ai principi elencati all’art. 5 del Regolamento UE 2016/679.\n\n" +
                "Il titolare del loro trattamento è l’Università degli Studi di Camerino che ha sede legale in Camerino, Piazza Cavour 19/f – Camerino MC (la sede operativa, a seguito dell’inagibilità post- sisma della sede di Piazza Cavour, è in via D’Accorso 16 – Rettorato – Campus Universitario). I dati di contatto del titolare sono:\n" +
                "PEC: protocollo@pec.unicam.it\n\n" +
                "L’Università degli Studi di Camerino ha designato quale Responsabile della Protezione dei Dati Personali il Dott. Stefano Burotti. I suoi recapiti di contatto sono i seguenti:\n" +
                "E-mail: rpd@unicam.it\n" +
                "P.E.C.: rpd@pec.unicam.it\n\n" +
                "L’interessato ha il diritto di esercitare i diritti indicati nella sezione 2, 3 e 4 del Capo III del GDPR,  ove applicabile.\n\n" +
                "L’interessato ha il diritto di proporre reclamo al Garante per la Protezione dei Dati se ritiene che il trattamento di dati personali che lo riguardi violi il Regolamento EU 2016/2016, ai sensi e nelle modalità dell’art. 77 di detto Regolamento.",
            20.0
        )])));
}