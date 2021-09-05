import 'package:flutter/cupertino.dart';
import 'package:sogniario/it/unicam/sogniario/Management/AccessManagement.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/AskPage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/ListPage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/MessagePage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';
import 'package:sogniario/it/unicam/sogniario/Questionnaire/Questionnaire.dart';
import 'package:sogniario/it/unicam/sogniario/Questionnaire/QuestionnaireManager.dart';
import 'package:sogniario/it/unicam/sogniario/Report/ReportManager.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';

import 'QuestionnairePage.dart';
import 'Reminder.dart';

///IReminderPage è la classe astratta che stabilisce il contratto per costruire,
///in base alla lista di [IPostIt] passata, le pagine più opportune.
abstract class IReminderPage{

  ///Ritorna la pagina dei questionari da svolgere
  Widget getToDoPage(List<IPostIt> list);

  ///Ritorna la pagina dei questionari riferiti ai report da svolgere
  Widget getReportQuestionnairePage(List<IPostIt> reportPostIt);

  ///Ritorna la [QuestionnairePage] del questionario passato
  @protected
  Widget getQuestionnairePage(IQuestionnaire questionnaire)=>
      QuestionnaireManager().getQuestionnairePage(questionnaire);

}

///ReminderPage, implementando [IReminderPage], si occupa di costruire, in base alla
///lista di [IPostIt] passata, le pagine più opportune. Infatti, da priorità ai 
///questionari obbligatori, rimuovendo la possibilità di compilarli in un secondo 
///momento, come invece avviene per quelli obbligatori (questionari di tipo 3).
class ReminderPage extends IReminderPage{

  Widget getToDoPage(List<IPostIt> list) {

    print("VISUALIZZAZIONE QUESTIONARI DA COMPILARE");

    if(list.isEmpty)
      return AccessManager().getStart() ?
        AskPage(
            "Molto bene! Adesso puoi iniziare ad utilizzare Sogniario",
            [
              SogniarioFunctionButton(
                  "Ok", AccessManager().setStart, ReportManager().getReportPage())
            ]
        ) :
        MessagePage("Nessun questionario da svolgere", false);

    //estraggo prima quelli obbligatori
    List<IQuestionnaire> mandatory = list.map((p)=>p.getQuestionnaire()).where((q) => !q.isOfType(3) && !q.isOfType(1)).toList();

    print("Ho trovato ${mandatory.length} questionari obbligatori");
    if (mandatory.isNotEmpty) {
      QuestionnaireManager().setSelected(mandatory.first);
      return AccessManager().getFirstAccess() || !AccessManager().getStart() ?
        _buildPage(mandatory.first):
        AskPage("Bentornato/a!\nCi sono dei questionari da compilare.", [
              SogniarioFunctionButton("Ok", null, _buildPage(mandatory.first))
            ]);
    }

    List<IQuestionnaire> notMandatory = list.map((p)=>p.getQuestionnaire()).where((q) => q.isOfType(3) && !q.isOfType(1)).toList();
    print("Ho trovato ${notMandatory.length} questionari opzionali.");

    if(notMandatory.isNotEmpty)// non ci sono questionari obbligatori
      return !AccessManager().getStart()?
        _buildListPage(notMandatory):
        AskPage(
            "Ci sono dei questionari da compilare.\nCosa vuoi fare?",
            [
              SogniarioFunctionButton("Compilare i questionari", null, _buildListPage(notMandatory)),
              SogniarioFunctionButton("Utilizzare l'app", AccessManager().setStart, ReportManager().getReportPage())
            ]
        );

    print("I questionari rimasti riguardano i reports");
    return getReportQuestionnairePage(list);
  }

  ///Costruisce la [ListPage] per visualizzare la lista dei questionari passata
  Widget _buildListPage(List<IQuestionnaire> list)=>
    ListPage(
      "Questionari",
      list.map(
        (q) =>
        ItemListPage(
          q.getName() == "Morningness Eveningness Questionnaire"? "Questionario sul cronotipo":
          q.getName() == "Pittsburgh Sleep Quality Index"? "Questionario sulla qualità del sonno":
            q.getName(),
            SogniarioIcons().get("questionnaire"),
            (){
              QuestionnaireManager().setSelected(q);
              return _buildPage(q);
            },
        )
      ).toList(),
      !AccessManager().getStart(),
      AccessManager().getStart()
    );


  ///In base al questionario passato. ne ritorna la pagina più opportuna
  Widget _buildPage(IQuestionnaire questionnaire){

    String name = questionnaire.getName();
    Widget page = getQuestionnairePage(questionnaire);

    if(name == "Morningness Eveningness Questionnaire")
      return AskPage(
          "Vuoi compilare il questionario per scoprire a quale cronotipo appartieni (gufo o allodola)?\nNon è obbligatorio e puoi compilarlo in un secondo momento.",
          [
            SogniarioFunctionButton("Si", null, page),
            SogniarioBackButton(
                "No",
                    () async => QuestionnaireManager().skip("Morningness Eveningness Questionnaire")
            )
          ]);

    if(name == "Pittsburgh Sleep Quality Index")
      return AskPage(
          "Vuoi completare il questionario sulla qualità del sonno?\nNon è obbligatorio e puoi compilarlo in un secondo momento.\nQuesto è un questionario mensile e, dopo averlo compilato, verrà richiesto tra 30 giorni.",
          [
            SogniarioFunctionButton("Si", null, page),
            SogniarioBackButton("No", null)
          ]
      );

    return questionnaire.isOfType(3)? AskPage(
      "Hai il questionario \"$name\" da compilare. Vuoi farlo adesso?",
      [
        SogniarioFunctionButton("Si", null, page),
        SogniarioBackButton("No", ()async=>await QuestionnaireManager().skip(name))
      ]
    ):page;
  }

  Widget getReportQuestionnairePage(List<IPostIt> reportPostIt){

    if(reportPostIt.isEmpty) return ReportManager().getAskPageReportRepresentation();

    List<IPostIt> mandatory = reportPostIt.where((p) => !p.getQuestionnaire().isOfType(3)).toList();

    if(mandatory.isNotEmpty) {
      QuestionnaireManager().setSelected(mandatory.first
          .getQuestionnaire()
          .setDescription(
          "Questo questionario è relativo al sogno:\n\n\"${mandatory.first.getData()['text']}\"\n\nregistrato il ${DateConverter().dateToString(DateConverter().epochToDateTime(int.parse(mandatory.first.getData()['date'])))}")
          .setData(mandatory.first.getData()));
      return AskPage(
          "Ci sono dei questionari relativi ai sogni che hai registrato", [
        SogniarioFunctionButton(
            "Ok",
            null,
            getQuestionnairePage(mandatory.first.getQuestionnaire()))
      ]);
    }

    return
      AskPage(
        "Ci sono dei questionari relativi ai sogni che hai registrato. Cosa vuoi fare?",
        [
          SogniarioFunctionButton(
            "Compilare i questionari",
            null,
            ListPage(
              "Questionari sui reports",
              reportPostIt.map((p) => _buildItemListPageReport(p)).toList(),
              false,
              false
            )
        ),
          SogniarioFunctionButton("Utilizzare l'app", null, ReportManager().getAskPageReportRepresentation())
        ]
      );
  }


  ///In base al postit passato. ne ritorna la pagina più opportuna
  ItemListPage _buildItemListPageReport(IPostIt postIt)=>
    ItemListPage(
      postIt.getName(),
      SogniarioIcons().get("questionnaire"),
      (){
          QuestionnaireManager().setSelected(postIt.getQuestionnaire()
              .setDescription(
                  "Questo questionario è relativo al sogno:\n\n\"${postIt.getData()['text']}\"\n\nregistrato il ${DateConverter().dateToString(DateConverter().epochToDateTime(int.parse(postIt.getData()['date'])))}")
              .setData(postIt.getData())
          );
          return getQuestionnairePage(postIt.getQuestionnaire());
      }
    );

}
