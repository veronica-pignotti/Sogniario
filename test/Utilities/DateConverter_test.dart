import 'package:sogniario/it/unicam/sogniario/Utilities/TypeConverter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  DateConverter converter = DateConverter();

  test('DateTime <--> Epoch', () {
    DateTime date1 = DateTime.now();
    int epoch = converter.dateTimeToEpoch(date1);
    DateTime date2 = converter.epochToDateTime(epoch);
    expect(date2.year, date1.year);
    expect(date2.month, date1.month);
    expect(date2.day, date1.day);
    expect(date2.hour, date1.hour);
    expect(date2.minute, date1.minute);
  });

  test('DateTime <--> String', () {
    DateTime date1 = DateTime.now();
    String str = converter.dateTimeToString(date1);
    DateTime date2 = converter.stringToDateTime(str);
    expect(date2.year, date1.year);
    expect(date2.month, date1.month);
    expect(date2.day, date1.day);
    expect(date2.hour, date1.hour);
    expect(date2.minute, date1.minute);
  });

  test("accented letters", (){
    String str = "a' e' i' o' u' a a a";
    expect(StringConverter().insertAccentedLetters(str), "à è ì ò ù a a a" );
  });

  test("delete characters", (){
    StringConverter sc = StringConverter();
    String str = " spazio come primo carattere";
    expect(sc.deleteCharacters(str), "spazio come primo carattere");
    str = "spazio come ultimo carattere ";
    expect(sc.deleteCharacters(str), "spazio come ultimo carattere");
    str = " spazio all'inizio e alla fine ";
    expect(sc.deleteCharacters(str), "spazio all'inizio e alla fine");
    str = "  doppi  spazi vari   ";
    expect(sc.deleteCharacters(str), "doppi spazi vari");
    str = "  123  abc def  ";
    expect(sc.deleteCharacters(str), "123 abc def");
  });

  test("tryparse int", (){
    expect(int.tryParse("a"), null);
    expect(int.tryParse("1"), 1);
  });
}