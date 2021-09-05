import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sogniario/it/unicam/sogniario/Report/ReportManager.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/Connection.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  Connection connection = Connection();
  String token = "Token_per_test" + DateTime.now().millisecondsSinceEpoch.toString();

  test('postNewUser', () async{
    await connection.call("postNewUser", token).then((res) {
      if(res.getOk()) connection.setToken(token);
      expect(res.getOk(), true);
    });
  });

/*
 test('getReports', () async{
    await connection.call(getReports(DateTime.now().subtract(Duration(days: 1)))
        .then((list) => expect(list.isEmpty, true));
  });*/

   //forse è sbagliato l'url
  test('post & get report', () async{
    String txt1 = "prova report 1";
    DateTime date = DateTime.now();
    String report1 = jsonEncode(Report(txt1, date).toMap());
    await connection.call("postReport",report1)
    .then((response1) async{
      expect(response1.getOk(), true);
      print("ho inviato il report.\n response1 = " + response1.toString());
      await connection.call("getReports",jsonEncode({
        //"token": connection.getToken(),
        "date1": (DateConverter().dateTimeToEpoch(DateTime(date.year, date.month, date.day))).toString(),
        "date2": (DateConverter().dateTimeToEpoch(DateTime(date.year, date.month, date.day, 23,59,59))).toString()
      }))
          .then((response2){
            print("response 2 = " + response2.toString());
            List<dynamic> list = jsonDecode(response2.getData());
            print("la lista ottenuta ha " + list.length.toString() + " elementi");
            expect(list.length == 1, true);
            print("La lista ha un solo elemento");
            expect(list[0], txt1);
      });
    });
  });


  test('post & get reports', () async{
    List<String> reports = [
      jsonEncode(Report("prova report 2", DateTime.now()).toMap()),
       jsonEncode(Report("prova report 3", DateTime.now()).toMap())
  ];
    List<bool> results = [];
    reports.forEach((r) async { await connection.call("postReport",r).then((res) => results.add(res.getOk()));});
    expect(results.contains(false), false);
  });

  test('getReportsMap', () async{
    await connection.call("getReportsMap", null).then((map) => expect(map!= null, true));
  });
}