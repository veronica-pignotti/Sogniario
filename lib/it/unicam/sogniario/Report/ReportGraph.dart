import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';

///Circle è una classe che, partendo da un numero [_len], calcola le posizioni
///esatte, istanze di [Coordinates], per la costruzione di, appunto, un cerchio
///con [_len] elementi.
///Le coordinate verrano calcolate partendo dal centro della prima riga, spostandosi
///verso il basso in modo simmetrico a sinistra e a destra, fino a toccare
///le estremità. Poi si procedirà spostandosi di nuovo verso il centro, sempre
///scorrendo verso il basso.
///Le coordinate avranno come riga un numero pari, poiché si procede incrementando
///di due per avere gli elementi ben distanziati.
class Circle{
  ///Numero di colonne del cerchio
  int _columns;
  ///Numero di righe del cerchio
  int _rows = 0;
  /// Numero di elementi da inserire
  int _len;
  /// Numero di elementi da inserire modificato
  int _n;
  ///Indica se gli elementi devono essere schiacciati ai lati del cerchio
  bool _crush;
  ///Lista di coordinate generate
  List<Coordinates> _coordinates = [];

  Circle(this._len){
    switch(_len) {
      case 1:
        {
          _columns = _rows = 1;
          _coordinates.add(Coordinates(0, 0));
        } break;
      case 2: {
        _columns = _rows = 3;
        _coordinates.addAll([Coordinates(0,1), Coordinates(2,1)]);
      } break;
      case 3:{
        _columns = 3;
        _rows = 2;
        _coordinates.addAll([Coordinates(0,1), Coordinates(1,2), Coordinates(1,0)]);
      }break;
      default: build();
    }
  }

  ///Costrisce le coordinate
  void build(){
    int c = (_len/2).ceil();
    _columns = c%2 == 1? c : c+1;
    _n = _len;
    if(_n%2 ==1) _n+=1;
    _crush = (_n/2)%2 == 1;
    int a = (_columns/2).ceil()-1;
    int b = a;
    List<Coordinates> tail = [];
    bool on = true;
    Coordinates sx, dx;
    while((_coordinates.length + tail.length)!=_len){
      dx = Coordinates(_rows, b);
      sx = Coordinates(_rows, a);
      _coordinates.add(dx);
      if(a!=b) tail.add(sx);
      if(a==0){// sono arrivato al limite
        if(_crush){
          _rows+=2;
          tail.add(Coordinates(_rows, a));
          _coordinates.add(Coordinates(_rows, b));
        }
        on = false;
      }
      if(on) {
        a -= 1;
        b += 1;
      }else{
        a+=1;
        b-=1;
      }
      _rows+=2;
    }
    _coordinates.addAll(tail.reversed);
  }

  ///Ritorna la lista di coordinate
  List<Coordinates> getCoordinates()=> _coordinates;

  String toString(){
    String str ="";
    _coordinates.forEach((c) {str += c.toString();});
    return str;
  }

  ///Ritorna il numero di righe
  int getRows()=> _rows;
  ///Ritorna il numero di colonne
  int getColumns()=>_columns;
}

///Coordinates rappresenta un elemento calcolato da [Circle], comprendendo un intero
///per la riga [_row] e uno per la colonna [_column]
class Coordinates{
  /// numero della riga
  int _r;
  /// numero della colonna
  int _c;

  Coordinates(this._r, this._c);
  ///ritorna  il numero della riga
  int getRow()=> _r;
  /// ritorna il numero della colonna
  int getColumn() => _c;

  ///Confronta questo elemento con il parametro passato
  bool equal(Coordinates other) {
    return other.getRow() == _r && other.getColumn() == _c;
  }

  String toString()=>"(${_r.toString()}, ${_c.toString()})";

}

///ReportGraph è la classe che esegue delle elaborazioni sul testo del report,
///iniziando dalla creazione della lista di [ReportGraphNode], ad ognuno dei quali
///verrà attribuita un'istanza di [Coordinates] generate da un [Circle] con numero
///di elementi pari al numero dei nodi generati.
class ReportGraph{
  ///il testo da trasformare in grafo
  String _text;
  ///lista di nodi del grafo
  List<ReportGraphNode> _nodes;
  ///l'istanza di [Circle] creata
  Circle _circle;
  ///il punteggio/numero di parole del grafo
  int _score;

  ReportGraph(this._text){
    _nodes = [];
    createNodeList(StringConverter().deleteCharacters(_text.toLowerCase()).split(" "));
    _score = _nodes.length;
    addCoordinates();
  }

  /// crea la lista di nodi
  void createNodeList(List<String> words){
    String from,to;
    ReportGraphNode node;
    for(int i=0; i<words.length-1;i++){
      from = words[i];
      to = words[i+1];
      if(from != to){
        if(!contains(from)){
          node = ReportGraphNode(from);
          node.addAdj(to);
          _nodes.add(node);
        }else addAdj(from, to);
      }
    }
    if(!contains(to)) _nodes.add(ReportGraphNode(to));
  }

  ///aggiunge le coordinate ai nodi generati
  void addCoordinates(){
    _circle = Circle(_nodes.length);
    List<Coordinates> coor = _circle.getCoordinates();
    for(int i =0; i < _nodes.length; i++) {
      _nodes[i].setCoor(coor[i]);
    }
  }

  ///Aggiunge una adiacenza al nodo con testo [from]
  void addAdj(String from, String to)=>
      _nodes.firstWhere((n) => n.getText() == from ).addAdj(to);

  ///determina se [_nodes] contiene il nodo con testo str
  bool contains(String str) =>
      _nodes.firstWhere((n) => n.getText() == str, orElse: ()=> null) != null;

  ///ritorna il testo del grafo
  String getText()=>_text;
  ///ritorna la lista di nodi
  List<ReportGraphNode> getNodes()=>_nodes;
  ///ritorna l'istanza di [Circle] generato
  Circle getCircle()=>_circle;
  /// ritorna il punteggio del grafo
  int getScore()=>_score;
}

///ReportGraphNode contiene una parola del report nel campo [_text], la lista
///delle parole precedute da text, nel campo [_adj] e le coordinate di tale nodo.
class ReportGraphNode{
  ///L'insieme delle parole immediatamente successive a [_text]
  Set<String> _adj;
  ///L'istanza di [Coordinates] assegnate a tale nodo
  Coordinates _coor;
  ///Il testo che rappresenta il nodo
  String _text;

  ReportGraphNode(this._text){
    _adj = Set<String>();
  }

  ///Ritorna [_adj] trasformata in lista
  List<String> getAdj()=> _adj.toList();
  ///Ritorna l'istanza di [Coordinates] assegnate a tale nodo
  Coordinates getCoor()=>_coor;
  ///Ritorna il testo che rappresenta il nodo
  String getText()=> _text;

  ///Aggiunge una parola all'insieme di adiacenze
  void addAdj(String str)=> _adj.add(str);

  ///Imposta le coordinate a tale nodo
  void setCoor(Coordinates coor)=> _coor = coor;

  String toString()=>
      "> text = $_text\n> adj = ${_adj.toList().toString()}\n> coor = ${_coor.toString()}";
}