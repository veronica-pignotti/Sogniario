import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sogniario/it/unicam/sogniario/Utilities/AppSecurity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  
  test("sha256", (){
    String s1 = "abc";
    String s2 = "ciao";
    expect(sha256.convert(utf8.encode(s1)).toString(), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
    expect(sha256.convert(utf8.encode(s2)).toString(), "b133a0c0e9bee3be20163d2ad31d6248db292aa6dcb1ee087a2aa50e0fc75ae2");
  });
}