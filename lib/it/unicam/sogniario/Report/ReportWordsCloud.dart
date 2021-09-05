import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///Partendo dalla mappa parola-valore [_wordsMap] scaricata dal server, costruisce la lista
///dei widget che andreanno a comporre la nuvola di parole
class ReportWordsCloud{
  ///la mappa parole-valore scaricata dal server
  Map<String, dynamic> _wordsMap;
  ///incremento della grandezza delle parole
  double _inc;
  ///lista dei widget che compongono la nuvola di parole
  List<Widget> _words;

  ReportWordsCloud(this._wordsMap, this._inc){
   buildWords();
  }

  ///costruisce la lista [_words]
  void buildWords(){
    _words = [];
    double max = 0.0;
    List<dynamic> values = _wordsMap.values.toList();
    values.forEach((n) {
      if((n as double)>max) max = n;
    });
    double range = max/5;
    _wordsMap.forEach((key, value) {
      for(double i=1.0; i<=5.0;i++) {
        if (value <= i * range) {
          _words.add(buildWord(key, i.floor()));
          break;
        }
      }
    });
  }

///costruisce il widget con parola text
  Widget buildWord(String text, int index){
    Color color;
    double size;
    switch(index){
      case 5:{color = Colors.red; size = 36.0 + _inc; break;}
      case 4:{color = Colors.orange; size = 32.0 + _inc; break;}
      case 3:{color = Colors.green; size = 28.0 + _inc; break;}
      case 2:{color = Colors.blue; size = 24.0 + _inc; break;}
      case 1:{color = Colors.purple; size = 20.0 + _inc;}
    }
    return Text(
        text,
        style: TextStyle(
            fontSize: size,
            color: color
        )
    );
  }
/// restituisce la lista [_words]
  List<Widget> getWords()=>_words;




}