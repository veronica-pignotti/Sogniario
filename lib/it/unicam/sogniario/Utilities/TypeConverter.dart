///Poichè durante l’utilizzo dell’applicazione c’è bisogno di tre formati di data, è stato necessario implementare una classe apposita, DateConverter, che adatti tale informazione in base alle situazioni; Dart mette a disposizione il tipo DateTime, che deve essere converito:
///• in millisecondi, quindi un numero intero, per essere salvato nel database;
///• in una stringa semplice, per essere letto dall’utente e per essere inserito come parte delle chiavi nella cache.
///Ogni conversione deve essere adeguatamente reversibile.
class DateConverter{

  ///Trasforma un oggetto da [DateTime] a [int]
  int dateTimeToEpoch(DateTime date)=> date.millisecondsSinceEpoch;

  ///Trasforma un oggetto da [int] a [DateTime]
  DateTime epochToDateTime(int epoch) => new DateTime.fromMillisecondsSinceEpoch(epoch);

  ///Trasforma un oggetto da [DateTime] a [String]
  String dateTimeToString(DateTime date) =>
      date.year.toString()+"/"+ date.month.toString()+"/"+date.day.toString()+" "+
      date.hour.toString()+":"+date.minute.toString()+":"+date.second.toString();

  ///Trasforma un oggetto da [DateTime] a [String], omettendo l'orario
  String dateToString(DateTime date)=> date.day.toString()+"/"+ date.month.toString()+"/"+date.year.toString();

  ///Trasforma un oggetto da [String] a [DateTime]
  DateTime stringToDateTime(dynamic date){
    List<String> arr = date.replaceAll("/", " ").replaceAll(":"," ").split(" ");
    return DateTime(
        int.parse(arr[0]),int.parse(arr[1]),int.parse(arr[2]),
        int.parse(arr[3]),int.parse(arr[4]),int.parse(arr[5])
    );
  }
}

///StringConverter adatta e trasforma delle stringhe che devono subire cambiamenti
///per alcune elaborazioni o semplicemente per essere adeguatamente visualizzate
///sull’interfaccia utente o sul server.alcune classi, devono adattare delle stringhe.
class StringConverter{

  String insertAccentedLetters(String str)=>
    str.replaceAll("e'", "è")
      .replaceAll("a'", "à")
      .replaceAll("i'", "ì")
      .replaceAll("o'", "ò")
      .replaceAll("u'", "ù")
      .replaceAll("/n" , "\n");

  String deleteAccentedLetters(String str) =>
      str.replaceAll("è", "e'")
        .replaceAll("é", "e'")
        .replaceAll("à", "a'")
        .replaceAll("ì", "i'")
        .replaceAll("ò", "o'")
        .replaceAll("ù", "u'");

  String deleteCharacters(String str){
    bool repl1, repl2;
    int c1, c2;
    Function isNumber = (int x) => x>=48 && x<=57;
    Function isLetter = (int x) => x>=97 && x<=122;
    Function isAccentedLetter = (int x) => [233, 232, 242, 224, 249].contains(x);
    Function isSymbol = (int x) => x == 32 || x == 39;
    Function toReplace = (int x) => !(isNumber(x) || isLetter(x) || isAccentedLetter(x) || isSymbol(x));

    for(int i = 0; i < str.length-1; i++){
      c1 = str.codeUnitAt(i);
      c2 = str.codeUnitAt(i+1);
      repl1 = toReplace(c1);
      repl2 = toReplace(c2);
      if(repl1) str = str.replaceAll(String.fromCharCode(c1), " ");
      if(repl2) str = str.replaceAll(String.fromCharCode(c2), " ");
      if(repl1 && repl2) str = str.replaceFirst("  ", " ");
      if(str.startsWith(" ")) str = str.substring(1); // il primo carattere è uno spazio
      if(repl1||repl2) i-=1;
    }
    while(str.endsWith(" ")){
      str = str.substring(0, str.length-1);
    }
    return str;
  }
}