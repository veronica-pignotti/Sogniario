import 'dart:convert';
import 'dart:math';

import 'package:sogniario/it/unicam/sogniario/Report/ReportManager.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/Cache.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/Connection.dart';
import 'package:flutter_test/flutter_test.dart';

import '../init_test.dart';

void main() {

  ReportManager manager = ReportManager();
  Connection connection = Connection();
  String s1,s2,s3,s4, alfa, beta, gamma, delta;


  _create(){
    s1 = jsonEncode(Report(
        "Ho sognato di andare sulla luna e di ballare con un alieno",
        DateTime.now().subtract(Duration(days: Random().nextInt(100)))
    ).toMap());
    s2 = jsonEncode(Report(
        "La cosa più bella del nostro amore è che esso non ha razionalità né logica La cosa più bella del nostro amore è che esso cammina sull’acqua e non affonda.",
        DateTime.now().subtract(Duration(days: Random().nextInt(100)))
    ).toMap());
    s3 = jsonEncode(Report(
    "uno due tre quattro otto cinque sei sette otto uno",
        DateTime.now().subtract(Duration(days: Random().nextInt(100)))
    ).toMap());
    s4 = jsonEncode(Report(
    "Felice chi è diverso Essendo egli diverso Ma guai a chi è diverso Essendo egli comune",
        DateTime.now().subtract(Duration(days: Random().nextInt(100)))
    ).toMap());
  }

  _create();
  

  test('Report one', () async{
    fakeFirstAccess();
    await connection.call("postReport",s1).then((res) =>{expect(res.getOk(), true)});
  });

  test('Report two', () async{
    fakeFirstAccess();
    await connection.call("postReport",s2).then((res) =>{expect(res.getOk(), true)});
  });

  test('Report tree', () async{
    fakeFirstAccess();
    await connection.call("postReport",s3).then((res) =>{expect(res.getOk(), true)});
  });

  test('Report four', () async{
    fakeFirstAccess();
    await connection.call("postReport",s4).then((res) =>{expect(res.getOk(), true)});
  });

  test('Create and get report ', () async {
    fakeFirstAccess();
  DateTime randomDate = DateTime.now().subtract(Duration(days: Random().nextInt(100)));
    String dreamText = "Ho sognato di andare sulla luna e di ballare con un alieno";
   String json = jsonEncode(Report(dreamText, randomDate).toMap());
    await connection.call("postReport",json);
    await manager.getReportsOf(randomDate).then((resultJson) {
        expect(resultJson, dreamText);
    });
  });

  test('Get inexistent report', () async{
    fakeFirstAccess();
    await manager.getReportsOf(DateTime(2020,1,1)).then((resultJson) {
      expect(resultJson, "");
    });
  });
  
  test("save in cache, then sends",() async{
    fakeFirstAccess();
    Cache cache = await Cache().init();
    _create();
    await cache.insertInList("Report", s1);
    await cache.insertInList("Report" , s2);
    await cache.insertInList("Report", s3);
    await cache.insertInList("Report", s4);
    await manager.find();
    expect(cache.getValue("Report"), "");
    expect(cache.getValuesList("Report").isNotEmpty, true);
  });

  test("map for cloud", () async{
    await fakeFirstAccess();
    alfa = jsonEncode(Report("alfa alfa alfa alfa", DateTime.now()).toMap());
    beta = jsonEncode(Report("beta beta beta", DateTime.now()).toMap());
    gamma = jsonEncode(Report("gamma gamma", DateTime.now()).toMap());
    delta = jsonEncode(Report("delta", DateTime.now()).toMap());
    await connection.call("postReport",alfa).then((res) =>{expect(res, "")});
    await connection.call("postReport",beta).then((res) =>{expect(res, "")});
    await connection.call("postReport",gamma).then((res) =>{expect(res, "")});
    await connection.call("postReport",delta).then((res) =>{expect(res, "")});
    await connection.call("getReportsMap", null).then((response){
      expect(response.getOk(), true);
      Map<String, double> map = jsonDecode(response.getData())['percent'];
      expect(map['alfa'], 40.0);
      expect(map['beta'], 30.0);
      expect(map['gamma'], 20.0);
      expect(map['delta'], 10.0);
    });
  });
}

