import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/MessagePage.dart';

import 'ReportWordsCloud.dart';


///ReportsWordsCloudPage contiene la nuvola delle parole generata grazie alla
///libreria flutter_scatter, impostando la configurazione ArchimedeanSpiralScatterDelegate.
///La lista di WordsCloudItem, contenuta nello ReportsWordsCloud, viene passata
///allo Scatter, in modo da generare la composizione delle parole.
// ignore: must_be_immutable
class ReportsWordsCloudPage extends StatefulWidget {

  Map<String, dynamic> _reportsWordsCloud;

  ReportsWordsCloudPage(this._reportsWordsCloud);

  ReportsWordsCloudPageState createState() =>
      ReportsWordsCloudPageState(_reportsWordsCloud);
}

class ReportsWordsCloudPageState extends State<ReportsWordsCloudPage>{

  Map<String, dynamic> _wordsMap;
  double _inc = 0.0;
  ReportWordsCloud _reportWordsCloud;


  ReportsWordsCloudPageState(this._wordsMap){
    if(_wordsMap!= null) _reportWordsCloud = ReportWordsCloud(_wordsMap, _inc);
  }

  Widget build(BuildContext context) {

    if(_wordsMap  == null)
      return MessagePage("Nuvola di parole non dispobilile.\nConnettiti ad internet o registra almeno un sogno per visualizzarla.", true);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: SogniarioBar(false, true).build(context),
      body:Padding(padding:EdgeInsets.all(10.0), child:
          Column(children: [
            SogniarioPageTitle("Nuvola di parole"),
            Expanded(
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: EdgeInsets.all(8),
              scaleEnabled: false,
              child:Center(
                child: FittedBox(
                    child: Scatter(
                      fillGaps: true,
                      delegate: ArchimedeanSpiralScatterDelegate(ratio: size.width / size.height, a:11+_inc, b:11+_inc),
                      children: _reportWordsCloud.getWords(),
                    )
                )
              )
            )
            )]
        )),
        bottomNavigationBar:BottomNavigationBar(
            backgroundColor: SogniarioColors().get(1),
            fixedColor: Colors.black,
            unselectedItemColor: Colors.black,
            type: BottomNavigationBarType.fixed,
            elevation: 100.0,
            items: [
              BottomNavigationBarItem(
                title: Text(""),
                icon: Icon(SogniarioIcons().get("zoomout"), size: 30.0,),
              ),
              BottomNavigationBarItem(
                title: Text(""),
                icon: Icon(SogniarioIcons().get("zoomin"), size: 30.0),
              )
            ],
            onTap: (index)=> _zoom(index)
        )
    );
  }




  void _zoom(int index){
    if(index == 0){
      if(_inc == -10.0) return;
      _inc -=1.0;
    }else if(_inc==0.0)return;
    else _inc +=1.0;
    setState(() {_reportWordsCloud = ReportWordsCloud(_wordsMap, _inc);});
  }
}
