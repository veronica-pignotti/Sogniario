import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/AskPage.dart';

import 'it/unicam/sogniario/Management/AccessManagement.dart';
import 'it/unicam/sogniario/Pages/GraphicElements.dart';
import 'it/unicam/sogniario/Pages/DynamicPages/MessagePage.dart';
import 'it/unicam/sogniario/Pages/StaticPages/WaitPage.dart';
import 'it/unicam/sogniario/Questionnaire/QuestionnaireManager.dart';
import 'it/unicam/sogniario/Report/ReportManager.dart';
import 'it/unicam/sogniario/Report/ReportPage.dart';

void main() => runApp(SogniarioApp());

class SogniarioApp extends StatelessWidget{

  @override
  Widget build(BuildContext context) =>
    MaterialApp(
        title: "Sogniario",
        theme: ThemeData(
          primaryColor: SogniarioColors().get(1),
          fontFamily: "Arimo",
          scaffoldBackgroundColor: SogniarioColors().get(2),
        ),
        home: FutureBuilder(
          future: access(),
          builder: (context, snapshot) =>
          snapshot.hasData? snapshot.data: WaitPage(),
        )
    );

  ///Determina la prima pagina che dovrà visualizzare l'utente quando effettua
  ///l'accesso all'applicazione.
  ///Per un corretto comportamento, si fa uso di [AccessManager], il quale effettua
  ///numerosi controlli ed operazioni.
  ///In questo modo, verrà visualizzata:
  ///- Se l'utente ha effettuato il primo accesso, è stato correttamente registrato
  ///e sono stati caricati i questionari, viene presentata una pagina di benvenuto
  ///con una consecuzione di azioni per reperire le prime informazioni tramite
  ///tali questionari;
  ///- Se l'utente ha effettuato il primo accesso e almeno una delle due azioni
  ///precedentemente citate non è stata eseguita correttamente, viene visualizzata
  ///una pagina di errore;
  ///- Se l'utente non ha effettuato il primo accesso, ha questionari da compilare
  ///e sono stati scaricati dal server, verrà chiesto di completare tali questionari;
  ///- Se l'utente non ha effettuato il primo accesso e almeno una delle due azioni
  ///precedentemente citate non si verifica, viene visualizzata una [ReportPage].
  Future<Widget> access()async{
    IAccessManager accessManager = await AccessManager().access();
    print(accessManager.toString());
    bool regAndLoaded = accessManager.getRegistered() && accessManager.getLoaded();
    if(accessManager.getFirstAccess())
      return regAndLoaded?
        buildWelcomeTransition():
        MessagePage("Benvenuto!\n Connettiti ad internet per poter iniziare ad utilizzare l'applicazione!", false);

    return regAndLoaded?
      QuestionnaireManager().getToDoPage():
      buildNoConnectionPage();
  }

  ///Si occupa della costruzione e alla visualizzazione della sequenza di benvenuto.
  ///L'utente viene accolto da un'[AskPage] e viene indirizzato verso i questionari da compilare,
  ///forniti dal [IQuestionnaireManager].
  Widget buildWelcomeTransition()=>
      AskPage(
        "Benvenuto su Sogniario!\n" +
            "L'app creata per registrare i tuoi sogni!\n" +
            "Prima di cominciare ad utilizzare l'app, ti chiediamo alcune semplici informazioni.\n" +
            "Tutto ciò che ci fornirai, verrà memorizzato in modo anonimo e non sarà in alcun modo " +
            "possibile risalire alla tua identità (vedi pagina 'Informativa sulla privacy').",
        [
          SogniarioFunctionButton(
              "Ok", null, QuestionnaireManager().getToDoPage())
        ]);

  Widget buildNoConnectionPage()=>
      AskPage(
        "Bentornato/a!\nMomentaneamente non sei connesso ad internet.\nNon sarà possibile:\n"+
          "- inviare i sogni che registrerai;\n"+
          "- compilare questionari;\n"+
          "- visualizzare la nuvola delle parole e i grafi dei sogni registrati precedentemente.\n"+
          "Tali azioni saranno disponibili appena verrà ripristinata la connessione.",
        [SogniarioFunctionButton("Ok", () => AccessManager().setStart(), ReportManager().getReportPage())]
      );
}