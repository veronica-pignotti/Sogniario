import 'dart:convert';
import 'dart:math';

import 'package:sogniario/it/unicam/sogniario/Management/AccessManagement.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/Cache.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> fakeFirstAccess()async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({}); // svuota la mappa, altrimenti il test si arrabbia
  String token = "b059144ded8aa40e0a49";
  DateTime date = DateTime.now();
  await (await Cache().init()).insertValue("User", jsonEncode({"firstAccessDate": DateConverter().dateTimeToString(date), "token" : token}));
  await AccessManager().access();
}