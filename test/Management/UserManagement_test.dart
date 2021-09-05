import 'dart:math';

import 'package:sogniario/it/unicam/sogniario/Utilities/Connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nota: I test per la registrazione dell'utente vengono eseguiti esclusivamente
/// passando dei token casuali, poiché il prelevamento dell'indirizzo mac del
/// dispositivo, durante la creazione del token effettivo, causerebbe errori.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({}); // svuota la mappa, altrimenti il test si arrabbia
  Connection connection = Connection();

  test("post new user 0", () async{
    await connection.call("postNewUser","utente di test").then((value){expect(value, false);});
  });

  test("post new user 1", () async{
    await connection.call("postNewUser","utente di test N." + (Random().nextInt(100000).toString())).then((value){expect(value, true);});
  });
  test("post new user 2", () async{
    await connection.call("postNewUser","utente di test N." + Random().nextInt(100000).toString()).then((value){expect(value, true);});
  });
  test("post new user 3", () async{
    await connection.call("postNewUser","utente di test N." + Random().nextInt(100000).toString()).then((value){expect(value, true);});
  });
  test("post new user 4", () async{
    await connection.call("postNewUser","utente di test N." + Random().nextInt(100000).toString()).then((value){expect(value, true);});
  });


}