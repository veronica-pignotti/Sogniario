import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';
import 'package:widget_arrows/widget_arrows.dart';
import 'package:lazy_data_table/lazy_data_table.dart';


import 'ReportGraph.dart';

class ReportGraphPage extends StatefulWidget {

  final ReportGraph _reportGraph;

  ReportGraphPage(this._reportGraph);

  ReportGraphPageState createState()=> ReportGraphPageState(_reportGraph);
}

class ReportGraphPageState extends State<ReportGraphPage>{

  LazyDataTable _table;
  ReportGraph _reportGraph;
  double _h = 30.0,_w = 100.0, _s = 16.0;

  ReportGraphPageState(this._reportGraph){
    _table = buildTable();
  }

  LazyDataTable buildTable() =>
     LazyDataTable(
      rows: _reportGraph.getCircle().getRows(),
      columns: _reportGraph.getCircle().getColumns(),
      tableDimensions: LazyDataTableDimensions(
        cellHeight: _h,
        cellWidth: _w,
      ),
      tableTheme: LazyDataTableTheme(
        alternateRow: false,
        alternateColumn: false,
        cellColor:SogniarioColors().get(2),
        cellBorder: Border.fromBorderSide(BorderSide(color: SogniarioColors().get(2)))
      ),
      dataCellBuilder: (i, j) {
        ReportGraphNode current =_reportGraph.getNodes().firstWhere(
                (n) => n.getCoor().getRow() == i && n.getCoor().getColumn() == j,
            orElse: () => null
        );
        return current == null?
          Container():
          createArrow(current);
      }
    );


  ArrowElement createArrow(ReportGraphNode node) {
    List<ReportGraphNode> nodes = _reportGraph.getNodes();
    List<ReportGraphNode> list = [];
    node.getAdj().forEach((adj) {
      list.add(nodes.firstWhere((n) => n.getText() == adj));
    });
    return buildArrow(node, list, 0, null);
  }


  ArrowElement buildArrow(ReportGraphNode node, List<ReportGraphNode> list, int index, ArrowElement widget) {
    String from = node.getText() + (index == 0 ? "" : index.toString());
    if (index == list.length)
      return ArrowElement(id: from, child: Container(
          height: _h,
          width: _w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: SogniarioColors().get(1),
          ),
          child: buildNode(node)
      ));
    ReportGraphNode to = list[index];

    List<Alignment> al = calculate(node.getCoor(), to.getCoor());
    return ArrowElement(
      id: from,
      sourceAnchor: al[0],
      targetId: to.getText(),
      targetAnchor: al[1],
      child: buildArrow(node, list, index + 1, widget),
    );
  }

  Widget buildNode(ReportGraphNode node) =>
    SogniarioCentralText(node.getText(),_s, false);

  List<Alignment> calculate(Coordinates node, Coordinates other) {
    int r = node.getRow();
    int c = node.getColumn();
    int rt = other.getRow();
    int ct = other.getColumn();

    // caso 1:stessa riga
    if (r == rt)
      return c < ct ? [Alignment.centerRight, Alignment.centerLeft] : [
        Alignment.centerLeft,
        Alignment.centerRight
      ];

    if (c == ct)
      return r < rt ? [Alignment.bottomCenter, Alignment.topCenter] : [
        Alignment.topCenter,
        Alignment.bottomCenter
      ];
    List<Alignment> align = [];
    if (r < rt)
      align.add(Alignment.bottomCenter);
    else
      align.add(Alignment.topCenter);

    if (c < ct)
      align.add(Alignment.centerLeft);
    else
      align.add(Alignment.centerRight);
    return align;
  }

  void _zoom(int index){
    if(index==0){
      if(_h > 10)_h-=1.0;
      if(_w > 25)_w-=5.0;
      if(_s > 6) _s-=0.5;
    }else if(index == 2){
      if(_h<30.0)_h+=1.0;
      if(_w<100.0)_w+=5.0;
      if(_s<16.0)_s+=0.5;
    }
    setState(() {
      _table = buildTable();
    });
  }

  @override
  Widget build(BuildContext context) =>
      ArrowContainer(
        child:Scaffold(
          appBar: SogniarioBar(false, true).build(context),
          body: Padding(padding: EdgeInsets.all(10.0), child: Column(children: [
              Container(height: MediaQuery.of(context).size.height-180.0, child: _table),
              SogniarioText('Premi "Aggiorna" per riposizionare le frecce', 14.0)
            ])
          ),
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
                icon: Icon(SogniarioIcons().get("reload"), size: 30.0),
              ),
                BottomNavigationBarItem(
                  title: Text(""),
                  icon: Icon(SogniarioIcons().get("zoomin"), size: 30.0),
                )
              ],
              onTap: (index)=> _zoom(index)
            )
  ));

}