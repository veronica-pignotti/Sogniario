import 'package:flutter/material.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/StaticPages/ExitPage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/StaticPages/InfoPage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/StaticPages/PrivacyInfoPage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';
import 'package:sogniario/it/unicam/sogniario/Questionnaire/QuestionnaireManager.dart';
import 'package:sogniario/it/unicam/sogniario/Report/ReportManager.dart';

///ListPage è una pagina che consente di mettere a disposizione dell’utente una
///lista di pagine, che, per essere correttamente visualizzate, devono essere
///anticipate da un ItemListPage, un widget costituito da un nome, un’icona e la
///pagina che deve aprirsi premendo sullo stesso.
// ignore: must_be_immutable
class ListPage extends StatelessWidget{
  ///Titolo della lista
  String _title;

  ///lista degli [ItemListPage] da visualizzare
  List<ItemListPage> _items;

  /// Indica se da questa lista si può accedere al menu
  bool _menu;

  ///Indica se da questa lista, si può tornare indietro
  bool _back;

  ListPage(this._title, this._items, this._menu, this._back);

  @override
  Widget build(BuildContext context){
    List<Widget> children = [];
    if(_title != null && _title!="") children.add(SogniarioPageTitle(_title));
    children.addAll(_items);
    return Scaffold(
        appBar: SogniarioBar(_menu, _back).build(context),
        body: Padding(
            padding: EdgeInsets.all(10.0),
            child: ListView(children:children)
        )
    );
  }
}

///MenuPage è la pagina del menu. Infatti, trattandosi di una lista di elementi, estende [ListPage].
// ignore: must_be_immutable
class MenuPage extends ListPage{

  MenuPage() : super(
      "",
      [
        ReportManager().getItemListReportPage(),
        ReportManager().getItemListReportsRepresentation(),
        QuestionnaireManager().getItemListToDo(),
        ItemListPage("Informazioni sull'applicazione", SogniarioIcons().get("info"), ()=>InfoPage()),
        ItemListPage("Informativa sulla privacy", SogniarioIcons().get("privacy"),()=>PrivacyInfoPage()),
        ItemListPage("Esci", SogniarioIcons().get("exit"), ()=>ExitPage())
      ],
    false,
    false
  );

}