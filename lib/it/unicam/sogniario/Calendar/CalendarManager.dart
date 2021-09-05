import 'package:flutter/cupertino.dart';
import 'package:sogniario/it/unicam/sogniario/Calendar/CalendarPage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/ListPage.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/GraphicElements.dart';

import '../Report/ReportManager.dart';

///ICalendarManager è una classe astratta che stabilisce che il controllore
///dell'elemento del calendario  deve essere in grado di:
/// - ritornare una pagina che visualizza i reports registrati in una data passata,
/// collaborando con un’istanza di [IReportManager], sottoforma di grafi;
/// - ritornare una [CalendarPage] e la sua corrispondenete [ItemListPage];
/// - ritornare e impostare la data di inizio del calendario.
abstract class ICalendarManager{

  ///La data del primo utilizzo dell'applicazione dell'utente
  @protected
  DateTime startDay;

  ///L'istanza del [IReportManager], utilizzata per richiedere i report sottoforma di grafi.
  @protected
  IReportManager reportManager;

  ///Ritorna null se non l'utente non ha registrato sogni nella data [date] passata,
  ///altrimenti ritorna:
  ///- una [ReportGraphPage], se l'utente ha registrato soltanto un sogno;
  ///- una [ListPage] che raggruppa le ReportsGraphPage create se l'utente ha registrato più sogni.
  Future<Widget> getReports(DateTime date) async =>
      await reportManager.getReportsOf(date);

  ///Ritorna la [ItemListPage] relativa a [CalendarPage]
  ItemListPage getItemListCalendarPage()=>
      ItemListPage("Grafi", SogniarioIcons().get('graph'), ()=>getCalendarPage());

  ///Ritorna una [CalendarPage]
  CalendarPage getCalendarPage()=>CalendarPage(this);

  ///Ritorna la data di inizio del calendario.
  DateTime getStartDay() => startDay;

  ///Imposta la data di inizio del calendario.
  void setStartDay(DateTime date)=> startDay = date;

}

///CalendarManager è la classe concreta che implementa la ICalendarManager;
///viene inizializzata da [AccessManager], il quale imposta come data di inizio,
///la data del primo accesso dell’utente all’applicazione.
class CalendarManager extends ICalendarManager{

  static final CalendarManager _instance = CalendarManager._internal();

  CalendarManager._internal(){reportManager = ReportManager();}

  factory CalendarManager() => _instance;

}