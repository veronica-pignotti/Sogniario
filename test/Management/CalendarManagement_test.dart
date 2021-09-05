import 'package:sogniario/it/unicam/sogniario/Calendar/CalendarManager.dart';
import 'package:sogniario/it/unicam/sogniario/Report/ReportGraph.dart';
import 'package:flutter_test/flutter_test.dart';
import '../init_test.dart';

void main() {

  test('Get firstAccessDate1', ()async{
    await fakeFirstAccess().whenComplete(() {
      DateTime today = DateTime.now();
      CalendarManager manager = CalendarManager();
      DateTime startDay = manager.getStartDay();
      expect(startDay.year, today.year);
      expect(startDay.month, today.month);
      expect(startDay.day, today.day);
    });
  });

  test('Get firstAccessDate2', ()async{
    await fakeFirstAccess();
    DateTime today = DateTime.now();
    CalendarManager manager = CalendarManager();
    DateTime startDay = manager.getStartDay();
    expect(startDay.year, today.year);
    expect(startDay.month, today.month);
    expect(startDay.day, today.day);
  });

  test('Poesia diverso', (){
    String txt = "Felice chi è diverso Essendo egli diverso Ma guai a chi è diverso Essendo egli comune";
    ReportGraph manager = ReportGraph(txt);
    expect(manager.getScore(), 10);
  });

  test('Poesia romantica', (){
    String txt = "La cosa più bella del nostro amore è che esso non ha razionalità né logica La cosa più bella del nostro amore è che esso cammina sull’acqua e non affonda.";
    ReportGraph manager = ReportGraph(txt);
    expect(manager.getScore(), 21);
  });

  test('test replace', (){
    String txt ="'ci#ia%ao£o-+@o";
    ReportGraph manager = ReportGraph(txt);
    expect(manager.getScore(), 5);
  });

  test("lettere accentate", (){
    String str = "éèòàùì";
    for(int i =0; i<str.length-1; i++){
      print(str.codeUnitAt(i));
    }
  });

}
