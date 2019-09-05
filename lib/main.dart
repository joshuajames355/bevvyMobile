import 'package:bevvymobile/storeFront.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {   
    return MaterialApp(
      title: 'Bevvy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StoreFront(),
    );
  }
}
