import 'package:flutter/material.dart';
import 'main_map.dart';

void main () {
  runApp ( MaterialApp (
    debugShowCheckedModeBanner: false,
    home: MainMap(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build ( BuildContext context ) {
    return MaterialApp (
      title : 'Fultter GPS App ',
      initialRoute : '/',
      routes : {        
      },
    );
  }
}
