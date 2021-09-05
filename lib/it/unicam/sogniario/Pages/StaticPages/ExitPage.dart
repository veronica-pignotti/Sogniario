import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sogniario/it/unicam/sogniario/Pages/DynamicPages/AskPage.dart';

import '../GraphicElements.dart';

class ExitPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) =>
      AskPage(
          "Sei sicuro di voler uscire?",
          [
            SogniarioFunctionButton("Si", () => exit(0), null),
            SogniarioBackButton("No", null)
          ]
      );
}