import 'dart:convert';

import 'package:get_mac/get_mac.dart';
import 'package:crypto/crypto.dart';

///La scelta dell’assenza della registrazione dell’utente, dove di solito si richiedono
///informazioni anagrafiche, con il suo conseguente accesso all’applicazione mediante
///credenziali, ha portato all’implementazione della classe AppSecurity, che si occupa
///di generare un’identificatore univoco, detto token, non rintracciabile per l’utente.
///Per far ciò, si parte dall'indirizzo MAC del dispositivo, che è già univoco,
///e lo si passa alle complesse elaborazioni previste dall’algoritmo SHA1, generando
///una stringa non reversibile; ciò significa che non verrà memorizzato alcun dato
///che possa far risalire all’utente stesso. Del token, si considereranno solo i
///primi 20 caratteri, per una migliore visualizzazione all’interno del database
///e sull’app per i ricercatori; questa parola verrà registrata sia in cache, sia
///nel server, così da poter essere inviata e controllato ad ogni chiamata,
///fungendo da credenziale.
class AppSecurity{

  Future<String> createToken()async =>
      await GetMac.macAddress.then((mac) => sha1.convert(utf8.encode(mac)).toString().substring(0, 20));

}