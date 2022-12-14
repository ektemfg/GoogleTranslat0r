import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'App.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
        darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: App(),
        debugShowCheckedModeBanner: false
    );
  }
}